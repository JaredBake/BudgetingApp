using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

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
    [HttpPost("joinUserAccount")]
    public async Task<ActionResult> JoinUserAccount([FromBody] bodyObject request)
    {
        var user = await _context.Users.FindAsync(request.userId);
        var account = await _context.Accounts.FindAsync(request.accountId);

        if (user == null) return NotFound($"User: {request.userId} not found");
        if (account == null) return NotFound($"Account: {request.accountId} not found");

        var existingJoin = await _context.UserAccounts
            .FirstOrDefaultAsync(ua => ua.UserId == request.userId && ua.AccountId == request.accountId);

        if (existingJoin != null) return BadRequest($"User: {request.userId} is already connected to this account: {request.accountId}");

        var userAccount = new UserAccount
        {
            UserId = request.userId,
            AccountId = request.accountId
        };

        _context.UserAccounts.Add(userAccount);
        await _context.SaveChangesAsync();

        return Ok("User association successfully created");        
    }


    [HttpPut("{Id}")]
    public async Task<IActionResult> PutAccount(int Id, Account account)
    {
        if (Id != account.Id) return BadRequest($"Id: {Id} parameter doesn't equal account.Id: {account.Id}");        

        if (!AccountExists(Id)) return NotFound($"No account found to update with Id: {account.Id}");
        
        _context.Entry(account).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!AccountExists(Id))
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
        var account = await _context.Accounts.FindAsync(Id);
        if (account == null)
        {
            return NotFound($"No account found to delete with Id: {Id}");
        }

        _context.Accounts.Remove(account);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool AccountExists(int Id)
    {
        return _context.Accounts.Any(e => e.Id == Id);
    }
}