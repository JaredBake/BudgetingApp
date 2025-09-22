using App.Models;
using Microsoft.AspNetCore.Mvc;
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

    [HttpGet()]
    public bool check()
    {
        return true;
    }
    
    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Account>>> GetAccounts()
    {
        return await _context.Accounts
            .Include(a => a.Transactions)
            .ToListAsync();
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Account>> GetAccount(int Id)
    {
        var account = await _context.Accounts.FindAsync(Id);

        if (account == null)
        {
            return NotFound();
        }

        return account;
    }

    [HttpPost("PostAccount")]
    public async Task<ActionResult<Account>> PostAccount(Account account)
    {

        var a = await _context.Accounts.FindAsync(account.Id);
        if (a != null) return BadRequest($"Account already exists with Id: {account.Id}");        

        var user = await _context.Users.Include(u => u.Accounts).FirstOrDefaultAsync(u => u.Id == account.UserId);
        if (user == null) return NotFound($"User does not exist with Id: {account.UserId}");

        account.User = user;

        _context.Accounts.Add(account);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAccount), new { Id = account.Id }, account);
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutAccount(int Id, Account account)
    {
        if (Id != account.Id) return BadRequest($"Id: {Id} parameter doesn't equal account.Id: {account.Id}");        

        var a = await _context.Accounts.FindAsync(Id);
        if (a == null) return NotFound($"No account found to update with Id: {account.Id}");

        var u = await _context.Users.FindAsync(account.UserId);
        if (u == null) return NotFound($"User does not exist with Id: {account.UserId}");
        
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
        return _context.Users.Any(e => e.Id == Id);
    }
}