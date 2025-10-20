using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly BudgetDbContext _context;

    public UsersController(BudgetDbContext context)
    {
        _context = context;
    }

    [HttpGet()]
    public bool check()
    {
        return true;
    }

    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<User>>> GetUsers()
    {
        var users = await _context.Users
            .Include(u => u.UserAccounts)
                .ThenInclude(ua => ua.Account)
                    .ThenInclude(a => a!.Transactions)
            .Include(u => u.UserFunds)
                .ThenInclude(uf => uf.Fund)
            .ToListAsync();

        return users;     
    }   

    [HttpGet("{Id}")]
    public async Task<ActionResult<User>> GetUser(int Id)
    {
        var user = await _context.Users
            .Include(u => u.UserAccounts)
                .ThenInclude(ua => ua.Account)
                    .ThenInclude(a => a!.Transactions)
            .Include(u => u.UserFunds)
                .ThenInclude(uf => uf.Fund)
            .FirstOrDefaultAsync(u => u.Id == Id);

        if (user == null)
        {
            return NotFound();
        }

        return user;
    }

    [HttpPost("PostUser")]
    public async Task<ActionResult<User>> PostUser(Credentials cred)
    {

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Credentials.UserName == cred.UserName);

        user ??= await _context.Users.FirstOrDefaultAsync(u => u.Credentials.Email == cred.Email);

        if (user != null)
        {
            return BadRequest("Username already exists");
        }
        
        user = new User { Credentials = cred };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUser), new { Id = user.Id }, user);
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutUser(int Id, User user)
    {
        //TODO: Update this to make more sense with credentials class
        if (Id != user.Id)
        {
            return BadRequest();
        }

        _context.Entry(user).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!UserExists(Id))
                return NotFound();

            else
                throw;
        }

        return NoContent();
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteUser(int Id)
    {
        var user = await _context.Users.FindAsync(Id);
        if (user == null)
        {
            return NotFound();
        }

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool UserExists(int Id)
    {
        return _context.Users.Any(e => e.Id == Id);
    }
}