using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using App.Models;
using Microsoft.AspNetCore.Identity.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.VisualBasic;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly BudgetDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(BudgetDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpGet()]
    public bool check() { return true; }

    public struct LoginRequest
    {
        public int UserId { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
    }

    public class LoginResponse
    {
        public bool Authenticated { get; set; }
        public string? Username { get; set; }
        public string? Token { get; set; }
        public int? UserId { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class RegisterRequest {
        public required string Name { get; set; }
        public required string Username { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
    }

    [HttpPost("register")]
    public async Task<ActionResult<LoginResponse>> Register([FromBody] RegisterRequest request)
    {
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u =>
                u.Credentials.UserName == request.Username ||
                u.Credentials.Email == request.Email);

        if (existingUser != null)
            return BadRequest(new { message = "Username or email already exists!" });

        string hashed = HashPassword(request.Password);

        var user = new User
        {
            Credentials = new Credentials
            {
                Name = request.Name,
                UserName = request.Username,
                Email = request.Email,
                Password = hashed
            }
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var token = GenerateJwtToken(user);
        var expiresAt = DateTime.UtcNow.AddDays(1);

        return Ok(new LoginResponse
        {
            Authenticated = true,
            Username = user.Credentials.UserName,
            UserId = user.Id,
            Token = token,
            ExpiresAt = expiresAt,
        });
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var badRequest = new LoginResponse
        {
            Authenticated = false,
            Username = null,
            Token = null
        };

        User? user = null;

        if (request.UserId != 0)
        {
            user = await _context.Users
                .Where(u => u.Id == request.UserId)
                .FirstOrDefaultAsync();
        }
        else if (!string.IsNullOrEmpty(request.Username))
        {
            user = await _context.Users
                .Where(u => u.Credentials.UserName == request.Username)
                .FirstOrDefaultAsync();
        }
        else if (!string.IsNullOrEmpty(request.Email))
        {
            user = await _context.Users
                .Where(u => u.Credentials.Email == request.Email)
                .FirstOrDefaultAsync();
        }
        else
        {
            return Unauthorized(badRequest);
        }

        if (user == null || string.IsNullOrEmpty(request.Password))
            return Unauthorized(badRequest);

        if (!VerifyPassword(request.Password, user.Credentials.Password ?? ""))
            return Unauthorized(badRequest);
              

        return Ok(new LoginResponse
        {
            Authenticated = true,
            Username = user.Credentials.UserName,
            UserId = user.Id,
            Token = GenerateJwtToken(user),
            ExpiresAt = DateTime.UtcNow.AddDays(1)
        });
    }

    [HttpPost("logout")]
    public IActionResult Logout() {
        return Ok(new { message = "Logged out successfully" });
        // Don't have a way to token blacklist yet...
    }

    private static string HashPassword(string password) {

        using var sha256 = SHA256.Create();
        var saltBytes = RandomNumberGenerator.GetBytes(16);
        var passwordBytes = Encoding.UTF8.GetBytes(password);
        var combinedBytes = new byte[saltBytes.Length + passwordBytes.Length];

        Buffer.BlockCopy(saltBytes, 0, combinedBytes, 0, saltBytes.Length);
        Buffer.BlockCopy(passwordBytes, 0, combinedBytes, saltBytes.Length, passwordBytes.Length);

        var hashBytes = sha256.ComputeHash(combinedBytes);
        var hashWithSalt = new byte[saltBytes.Length + hashBytes.Length];

        Buffer.BlockCopy(saltBytes, 0, hashWithSalt, 0, saltBytes.Length);
        Buffer.BlockCopy(hashBytes, 0, hashWithSalt, saltBytes.Length, hashBytes.Length);

        return Convert.ToBase64String(hashWithSalt);
    }
    private static bool VerifyPassword(string password, string hashedPassword)
    {
        try
        {
            // if (hashedPassword == "1234567!" && password == hashedPassword) return true;

            var hashWithSalt = Convert.FromBase64String(hashedPassword);

            if (hashWithSalt.Length < 16) return false;

            var saltBytes = new byte[16];
            Buffer.BlockCopy(hashWithSalt, 0, saltBytes, 0, 16);

            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var combinedBytes = new byte[saltBytes.Length + passwordBytes.Length];

            Buffer.BlockCopy(saltBytes, 0, combinedBytes, 0, saltBytes.Length);
            Buffer.BlockCopy(passwordBytes, 0, combinedBytes, saltBytes.Length, passwordBytes.Length);

            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(combinedBytes);

            for (int i = 0; i < hashBytes.Length; i++)
            {
                if (hashWithSalt[i + 16] != hashBytes[i])
                    return false;
            }

            return true;
        }
        catch
        {
            return false;
        }

    }
    
    private string GenerateJwtToken(User user)
    {
        var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") ?? throw new InvalidOperationException("JWT SecretKey not configured");
        
        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Credentials.UserName ?? ""),
            new Claim(JwtRegisteredClaimNames.Email, user.Credentials.Email ?? ""),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _configuration.GetSection("JwtSettings")["Issuer"] ?? "BudgetApp",
            audience: _configuration.GetSection("JwtSettings")["Audience"] ?? "BudgetAppUsers",
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

}