using System.Security.Claims;
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
    public bool checkAuth() { return true; }

    [Authorize(Roles = "Admin")]
    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Transaction>>> GetUsers()
    {
        return await _context.Transactions.ToListAsync();
    }


    [HttpGet("MyTransactions")]
    public async Task<ActionResult<IEnumerable<Transaction>>> GetUserTransactions()
    {
        var userId = GetCurrentUserId();
        
        var userTransactions = await _context.UserAccounts
            .Where(ua => ua.UserId == userId)
            .SelectMany(ua => ua.Account!.Transactions)
            .OrderByDescending(t => t.Date)
            .ToListAsync();

        return Ok(userTransactions);
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Transaction>> GetTransaction(int Id)
    {
        if (!await AuthorizeUser(Id)) return Forbid();

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

        // Ensure the DateTime is in UTC
        transaction.Date = transaction.Date.Kind == DateTimeKind.Unspecified 
            ? DateTime.SpecifyKind(transaction.Date, DateTimeKind.Utc)
            : transaction.Date.ToUniversalTime();

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTransaction), new { Id = transaction.Id }, transaction);
    }    [HttpPut()]

    
    public async Task<IActionResult> PutTransaction(Transaction transaction)
    {
        if (!TransactionExists(transaction.Id)) return NotFound($"No transaction found to update with Id: {transaction.Id}");
        
        if (!AccountExists(transaction.AccountId)) return NotFound($"Account does not exist with Id: {transaction.AccountId}");

        if (!await AuthorizeUser(transaction.Id)) return Forbid();

        // Ensure the DateTime is in UTC
        transaction.Date = transaction.Date.Kind == DateTimeKind.Unspecified 
            ? DateTime.SpecifyKind(transaction.Date, DateTimeKind.Utc)
            : transaction.Date.ToUniversalTime();

        _context.Entry(transaction).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!TransactionExists(transaction.Id))
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
        if (!await AuthorizeUser(Id)) return Forbid();

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
   
    private async Task<bool> BelongsToUser(int transactionId, int userId)
    {
        var transaction = await _context.Transactions.FindAsync(transactionId);

        if (transaction == null) return false;

        var existingJoin = await _context.UserAccounts
            .FirstOrDefaultAsync(ua => ua.UserId == userId && ua.AccountId == transaction.AccountId);

        if (existingJoin == null) return false;
        else return true;
    }

    private async Task<bool> AuthorizeUser(int transactionId)
    {
        if (User.IsInRole("Admin")) return true;

        return await BelongsToUser(transactionId, GetCurrentUserId());
    }
    
    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.Parse(userIdClaim ?? "0");
    }
}