using App.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]

public class TransactionsController : ControllerBase
{
    private readonly BudgetDbContext _context;
    public TransactionsController(BudgetDbContext context)
    {
        _context = context;
    }

    [AllowAnonymous]
    [HttpGet()]
    public bool check() { return true; }

    [Authorize]
    [HttpGet("auth")]


    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Transaction>>> GetUsers()
    {
        return await _context.Transactions.ToListAsync();
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Transaction>> GetTransaction(int Id)
    {
        var fund = await _context.Transactions.FindAsync(Id);

        if (fund == null)
        {
            return NotFound();
        }

        return fund;
    }

    [HttpPost()]
    public async Task<ActionResult<Account>> PostTransaction(Transaction transaction)
    {
        var account = await _context.Accounts.Include(a => a.Transactions).FirstOrDefaultAsync(a => a.Id == transaction.AccountId);
        if (account == null) return NotFound($"Account does not exist with Id: {transaction.AccountId}");

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTransaction), new { Id = transaction.Id }, transaction);
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutTransaction(int Id, Transaction transaction)
    {
        if (Id != transaction.Id) return BadRequest($"Id: {Id} parameter doesn't equal fund.Id: {transaction.Id}");

        if (!TransactionExists(Id)) return NotFound($"No transaction found to update with Id: {transaction.Id}");

        if (!AccountExists(transaction.AccountId)) return NotFound($"Account does not exist with Id: {transaction.AccountId}");

        _context.Entry(transaction).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!TransactionExists(Id))
            {
                return NotFound($"No transaction found to update with Id: {transaction.Id}");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteTransaction(int Id)
    {
        var transaction = await _context.Transactions.FindAsync(Id);
        if (transaction == null)
        {
            return NotFound($"No transaction found to delete with Id: {Id}");
        }

        _context.Transactions.Remove(transaction);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool TransactionExists(int Id)
    {
        return _context.Transactions.Any(e => e.Id == Id);
    }

    private bool AccountExists(int Id)
    {
        return _context.Accounts.Any(e => e.Id == Id);
    }
    
    private bool UserExists(int Id)
    {
        return _context.Users.Any(e => e.Id == Id);
    }
}