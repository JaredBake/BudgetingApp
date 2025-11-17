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
        // Validate positive amount
        if (transaction.Money.Amount <= 0)
        {
            return BadRequest("Transaction amount must be greater than zero.");
        }

        var account = await _context.Accounts.Include(a => a.Transactions).FirstOrDefaultAsync(a => a.Id == transaction.AccountId);
        if (account == null) return NotFound($"Account does not exist with Id: {transaction.AccountId}");

        // Ensure the DateTime is in UTC
        transaction.Date = transaction.Date.Kind == DateTimeKind.Unspecified 
            ? DateTime.SpecifyKind(transaction.Date, DateTimeKind.Utc)
            : transaction.Date.ToUniversalTime();

        // Start a database transaction for atomicity
        using var dbTransaction = await _context.Database.BeginTransactionAsync();

        try
        {
            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            // Update fund balance if a fund is assigned
            if (transaction.FundId != null)
            {
                var fund = await _context.Funds.FindAsync(transaction.FundId);
                if (fund == null)
                {
                    await dbTransaction.RollbackAsync();
                    return NotFound($"Fund does not exist with Id: {transaction.FundId}");
                }

                // Income adds to fund, Expense subtracts from fund
                if (transaction.Type == TransactionType.Income)
                {
                    fund.Current.Amount += transaction.Money.Amount;
                }
                else // Expense
                {
                    fund.Current.Amount -= transaction.Money.Amount;
                }

                await _context.SaveChangesAsync();
            }

            await dbTransaction.CommitAsync();

            return CreatedAtAction(nameof(GetTransaction), new { Id = transaction.Id }, transaction);
        }
        catch (Exception)
        {
            await dbTransaction.RollbackAsync();
            throw;
        }
    }    [HttpPut()]
    public async Task<IActionResult> PutTransaction(Transaction transaction)
    {
        if (transaction.Money.Amount <= 0)
        {
            return BadRequest("Transaction amount must be greater than zero.");
        }

        if (!TransactionExists(transaction.Id)) return NotFound($"No transaction found to update with Id: {transaction.Id}");
        
        if (!AccountExists(transaction.AccountId)) return NotFound($"Account does not exist with Id: {transaction.AccountId}");

        if (!await AuthorizeUser(transaction.Id)) return Forbid();

        // Ensure the DateTime is in UTC
        transaction.Date = transaction.Date.Kind == DateTimeKind.Unspecified 
            ? DateTime.SpecifyKind(transaction.Date, DateTimeKind.Utc)
            : transaction.Date.ToUniversalTime();

        // Start a database transaction for atomicity
        using var dbTransaction = await _context.Database.BeginTransactionAsync();

        try
        {
            // Fetch the existing transaction from the database (this will be tracked)
            var existingTransaction = await _context.Transactions.FindAsync(transaction.Id);
            
            if (existingTransaction == null)
            {
                await dbTransaction.RollbackAsync();
                return NotFound($"No transaction found to update with Id: {transaction.Id}");
            }

            // Store old values before updating for fund balance reversal
            var oldFundId = existingTransaction.FundId;
            var oldAmount = existingTransaction.Money.Amount;
            var oldType = existingTransaction.Type;

            // Revert the old fund balance if it had a fund assigned
            if (oldFundId != null)
            {
                var oldFund = await _context.Funds.FindAsync(oldFundId);
                if (oldFund != null)
                {
                    // Reverse the previous transaction effect
                    if (oldType == TransactionType.Income)
                    {
                        oldFund.Current.Amount -= oldAmount;
                    }
                    else // Expense
                    {
                        oldFund.Current.Amount += oldAmount;
                    }
                }
            }

            // Update the existing transaction's properties
            existingTransaction.AccountId = transaction.AccountId;
            existingTransaction.Date = transaction.Date;
            existingTransaction.Money = transaction.Money;
            existingTransaction.FundId = transaction.FundId;
            existingTransaction.Type = transaction.Type;

            // Apply the new fund balance if a fund is assigned
            if (transaction.FundId != null)
            {
                var newFund = await _context.Funds.FindAsync(transaction.FundId);
                if (newFund == null)
                {
                    await dbTransaction.RollbackAsync();
                    return NotFound($"Fund does not exist with Id: {transaction.FundId}");
                }

                // Income adds to fund, Expense subtracts from fund
                if (transaction.Type == TransactionType.Income)
                {
                    newFund.Current.Amount += transaction.Money.Amount;
                }
                else // Expense
                {
                    newFund.Current.Amount -= transaction.Money.Amount;
                }
            }

            await _context.SaveChangesAsync();

            await dbTransaction.CommitAsync();

            return NoContent();
        }
        catch (DbUpdateConcurrencyException)
        {
            await dbTransaction.RollbackAsync();
            if (!TransactionExists(transaction.Id))
            {
                return NotFound($"No transaction found to update with Id: {transaction.Id}");
            }
            else
            {
                throw;
            }
        }
        catch (Exception)
        {
            await dbTransaction.RollbackAsync();
            throw;
        }
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