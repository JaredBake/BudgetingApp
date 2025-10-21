using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Linq.Expressions;

namespace App.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]

public class AccountsController : ControllerBase
{
    private readonly BudgetDbContext _context;

    public AccountsController(BudgetDbContext context)
    {
        _context = context;
    }

    [AllowAnonymous]
    [HttpGet()]
    public bool check() { return true; }

    [Authorize]
    [HttpGet("auth")]
    public bool checkAuth() { return true; }
    
    [Authorize(Roles = "Admin")]
    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Account>>> GetAccounts()
    {
        return await _context.Accounts
            .Include(a => a.Transactions)
            .Include(a => a.UserAccounts)
            .ToListAsync();
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Account>> GetAccount(int Id)
    {
        if (!await AuthorizeUser(Id)) return Forbid();

        var account = await _context.Accounts
            // .Include(a => a.Transactions)
            // .Include(a => a.UserAccounts)
            .FindAsync(Id);

        if (account == null)
        {
            return NotFound();
        }

        return account;
    }

    [HttpPost()]
    public async Task<ActionResult<Account>> PostAccount(Account account)
    {       

        _context.Accounts.Add(account);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAccount), new { Id = account.Id }, account);
    }

    public class bodyObject { public int userId { get; set; } public int accountId { get; set; } }
    [HttpPost("User")]
    public async Task<ActionResult> JoinUserAccount([FromBody] bodyObject request)
    {
        if (!await AuthorizeUser(request.accountId)) return Forbid();

        var user = await _context.Users.FindAsync(request.userId);
        var account = await _context.Accounts.FindAsync(request.accountId);

        if (user == null) return NotFound($"User: {request.userId} not found");
        if (account == null) return NotFound($"Account: {request.accountId} not found");


        if (await BelongsToUser(request.accountId, request.userId))
        {
            return BadRequest($"User: {request.userId} is already connected to this account: {request.accountId}");
        }

        var userAccount = new UserAccount
        {
            UserId = request.userId,
            AccountId = request.accountId
        };

        _context.UserAccounts.Add(userAccount);
        await _context.SaveChangesAsync();

        return Ok("User association successfully created");
    }

    [HttpDelete("User")]
    public async Task<ActionResult> DeleteUserAccount([FromBody] bodyObject request)
    {
        if (!await AuthorizeUser(request.accountId)) return Forbid();

        var userAccount = new UserAccount
        {
            UserId = request.userId,
            AccountId = request.accountId
        };

        try
        {
            _context.UserAccounts.Remove(userAccount);
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await BelongsToUser(request.accountId, request.userId))
            {
                return BadRequest($"Association doesn't exist! User: {request.userId} Account: {request.accountId}");
            }
            if (!AccountExists(request.userId))
            {
                return NotFound($"No account found to update with Id: {request.accountId}");
            }
            if (!UserExists(request.userId))
            {
                return NotFound($"No user found to update with Id: {request.userId}");
            }
            else
            {
                throw;
            }
        }

        return Ok("User association successfully deleted");
        
    }
    
    [HttpGet("User")]
    public async Task<ActionResult<bool>> TestBelongs([FromBody] bodyObject request)
    {
        if (!await AuthorizeUser(request.accountId)) return Forbid();
        return await BelongsToUser(request.accountId, request.userId);       
    }


    [HttpPut()]
    public async Task<IActionResult> PutAccount(Account account)
    {

        if (!await AuthorizeUser(account.Id)) return Forbid();            

        if (!AccountExists(account.Id)) return NotFound($"No account found to update with Id: {account.Id}");
        
        _context.Entry(account).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!AccountExists(account.Id))
            {
                return NotFound($"No account found to update with Id: {account.Id}");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteAccount(int Id)
    {
        if (!await AuthorizeUser(Id)) return Forbid(); 

        var account = await _context.Accounts.FindAsync(Id);
        if (account == null)
        {
            return NotFound($"No account found to delete with Id: {Id}");
        }

        // _context.UserAccounts.RemoveRange(userAccounts); // ???

        _context.Accounts.Remove(account);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool UserExists(int Id)
    {
        return _context.Users.Any(e => e.Id == Id);
    }

    private bool AccountExists(int Id)
    {
        return _context.Accounts.Any(e => e.Id == Id);
    }

    
    public async Task<bool> BelongsToUser(int accountId, int userId)
    {
        var existingJoin = await _context.UserAccounts
            .FirstOrDefaultAsync(ua => ua.UserId == userId && ua.AccountId == accountId);

        if (existingJoin == null) return false;
        else return true;
    }

    public async Task<bool> AuthorizeUser(int accountId)
    {
        if (User.IsInRole("Admin")) return true;

        return await BelongsToUser(accountId, GetCurrentUserId());
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.Parse(userIdClaim ?? "0");
    }
}