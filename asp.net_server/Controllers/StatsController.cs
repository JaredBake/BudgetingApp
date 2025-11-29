using App.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class StatsController : ControllerBase
{
    private readonly BudgetDbContext _db;

    public StatsController(BudgetDbContext db)
    {
        _db = db;
    }

    [AllowAnonymous]
    [HttpGet()]
    public bool check() { return true; }

    [Authorize]
    [HttpGet("auth")]


    [HttpGet("overview")]
    public async Task<ActionResult<OverviewStatistics>> GetOverview()
    {                   

            var stats = new OverviewStatistics
            {
                TotalUsers = await _db.Users.CountAsync(),
                TotalAccounts = await _db.Accounts.CountAsync(),
                TotalFunds = await _db.Funds.CountAsync(),

                TotalTransactions = await _db.Transactions.CountAsync(),
                TotalUserAccountLinks = await _db.UserAccounts.CountAsync(),
            };

            stats.AverageAccountsPerUser = stats.TotalUsers > 0 ? Math.Round((double)stats.TotalUserAccountLinks / stats.TotalUsers, 2) : 0;
            stats.AverageFundsPerUser = stats.TotalUsers > 0 ? Math.Round((double)stats.TotalFunds / stats.TotalUsers, 2) : 0;
            stats.AverageTransactionsPerAccount = stats.TotalAccounts > 0 ? Math.Round((double)stats.TotalTransactions / stats.TotalAccounts, 2) : 0;

            
            return Ok(stats);
    }

    [HttpGet("users/count")]
    public async Task<ActionResult<int>> GetUserCount()
    {
        var count = await _db.Users.CountAsync();
        return Ok(count);
    }

    [HttpGet("accounts/count")]
    public async Task<ActionResult<int>> GetAccountCount()
    {
        var count = await _db.Accounts.CountAsync();
        return Ok(count);
    }

    [HttpGet("funds/count")]
    public async Task<ActionResult<int>> GetFundCount()
    {
        var count = await _db.Funds.CountAsync();
        return Ok(count);
    }
    
    [HttpGet("transactions/count")]
    public async Task<ActionResult<int>> GetTransactionCount()
    {
        var count = await _db.Transactions.CountAsync();
        return Ok(count);
    }

    [HttpGet("users/{userId}/accounts")]
        public async Task<ActionResult<UserAccountStatistics>> GetUserAccountStats(int userId)
        {
            var userExists = await _db.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
                return NotFound($"User with ID {userId} not found");

            var accountCount = await _db.UserAccounts
                .Where(ua => ua.UserId == userId)
                .CountAsync();

            var accountIds = await _db.UserAccounts
                .Where(ua => ua.UserId == userId)
                .Select(ua => ua.AccountId)
                .ToListAsync();

            var totalBalance = await _db.Accounts
                .Where(a => accountIds.Contains(a.Id))
                .SumAsync(a => a.Balance.Amount);

            var accountsByType = await _db.Accounts
                .Where(a => accountIds.Contains(a.Id))
                .GroupBy(a => a.AccountType)
                .Select(g => new { AccountType = g.Key.ToString(), Count = g.Count() })
                .ToListAsync();

            return Ok(new UserAccountStatistics
            {
                UserId = userId,
                TotalAccounts = accountCount,
                TotalBalance = totalBalance,
                AccountsByType = accountsByType.ToDictionary(x => x.AccountType, x => x.Count)
            });
        }

    [HttpGet("users/{userId}/funds")]
    public async Task<ActionResult<UserFundStatistics>> GetUserFundStats(int userId)
    {
        var userExists = await _db.Users.AnyAsync(u => u.Id == userId);
        if (!userExists)
            return NotFound($"User with ID {userId} not found");

        var fundCount = await _db.Funds
            .Where(f => f.UserId == userId)
            .CountAsync();

        var totalGoals = await _db.Funds
            .Where(f => f.UserId == userId)
            .SumAsync(f => f.GoalAmount.Amount);

        var totalCurrent = await _db.Funds
            .Where(f => f.UserId == userId)
            .SumAsync(f => f.Current.Amount);

        var progressPercentage = totalGoals > 0 ? (totalCurrent / totalGoals) * 100 : 0;

        return Ok(new UserFundStatistics
        {
            UserId = userId,
            TotalFunds = fundCount,
            TotalGoalAmount = totalGoals,
            TotalCurrentAmount = totalCurrent,
            OverallProgressPercentage = progressPercentage
        });
    }

    // GET: api/statistics/accounts/5/transactions
    [HttpGet("accounts/{accountId}/transactions")]
    public async Task<ActionResult<AccountTransactionStatistics>> GetAccountTransactionStats(int accountId)
    {
        var accountExists = await _db.Accounts.AnyAsync(a => a.Id == accountId);
        if (!accountExists)
            return NotFound($"Account with ID {accountId} not found");

        var transactions = await _db.Transactions
            .Where(t => t.AccountId == accountId)
            .ToListAsync();

        var transactionCount = transactions.Count;
        var totalAmount = transactions.Sum(t => t.Money.Amount);
        var averageAmount = transactionCount > 0 ? totalAmount / transactionCount : 0;
        var maxTransaction = transactions.MaxBy(t => Math.Abs(t.Money.Amount));
        var minTransaction = transactions.MinBy(t => Math.Abs(t.Money.Amount));

        var positiveTransactions = transactions.Where(t => t.Money.Amount > 0).ToList();
        var negativeTransactions = transactions.Where(t => t.Money.Amount < 0).ToList();

        return Ok(new AccountTransactionStatistics
        {
            AccountId = accountId,
            TotalTransactions = transactionCount,
            TotalAmount = totalAmount,
            AverageAmount = averageAmount,
            MaxTransactionAmount = maxTransaction?.Money.Amount ?? 0,
            MinTransactionAmount = minTransaction?.Money.Amount ?? 0,
            PositiveTransactionCount = positiveTransactions.Count,
            NegativeTransactionCount = negativeTransactions.Count,
            TotalDeposits = positiveTransactions.Sum(t => t.Money.Amount),
            TotalWithdrawals = Math.Abs(negativeTransactions.Sum(t => t.Money.Amount))
        });
    }

    // GET: api/statistics/accounts/top-by-balance?limit=5
    [HttpGet("accounts/top-by-balance")]
    public async Task<ActionResult<IEnumerable<AccountSummary>>> GetTopAccountsByBalance([FromQuery] int limit = 10)
    {
        var topAccounts = await _db.Accounts
            .OrderByDescending(a => a.Balance.Amount)
            .Take(limit)
            .Select(a => new AccountSummary
            {
                AccountId = a.Id,
                Name = a.Name,
                AccountType = a.AccountType.ToString(),
                Balance = a.Balance.Amount,
                TransactionCount = a.Transactions.Count
            })
            .ToListAsync();

        return Ok(topAccounts);
    }

    // GET: api/statistics/accounts/most-active?limit=5
    [HttpGet("accounts/most-active")]
    public async Task<ActionResult<IEnumerable<AccountActivity>>> GetMostActiveAccounts([FromQuery] int limit = 10)
    {
        var mostActive = await _db.Accounts
            .Select(a => new AccountActivity
            {
                AccountId = a.Id,
                Name = a.Name,
                TransactionCount = a.Transactions.Count,
                Balance = a.Balance.Amount
            })
            .OrderByDescending(a => a.TransactionCount)
            .Take(limit)
            .ToListAsync();

        return Ok(mostActive);
    }

    // GET: api/statistics/funds/progress
    [HttpGet("funds/progress")]
    public async Task<ActionResult<IEnumerable<FundProgress>>> GetFundProgress()
    {
        var fundProgress = await _db.Funds
            .Select(f => new FundProgress
            {
                FundId = f.Id,
                Description = f.Description,
                GoalAmount = f.GoalAmount.Amount,
                CurrentAmount = f.Current.Amount,
                ProgressPercentage = f.GoalAmount.Amount > 0 
                    ? (f.Current.Amount / f.GoalAmount.Amount) * 100 
                    : 0,
                RemainingAmount = f.GoalAmount.Amount - f.Current.Amount
            })
            .OrderByDescending(f => f.ProgressPercentage)
            .ToListAsync();

        return Ok(fundProgress);
    }

    // GET: api/statistics/users/top-by-accounts?limit=5
    [HttpGet("users/top-by-accounts")]
    public async Task<ActionResult<IEnumerable<UserSummary>>> GetTopUsersByAccounts([FromQuery] int limit = 10)
    {
        var topUsers = await _db.Users
            .Select(u => new UserSummary
            {
                UserId = u.Id,
                Name = u.Credentials.Name,
                Email = u.Credentials.Email,
                AccountCount = u.UserAccounts.Count,
                FundCount = u.Funds.Count
            })
            .OrderByDescending(u => u.AccountCount)
            .Take(limit)
            .ToListAsync();

        return Ok(topUsers);
    }

    // GET: api/statistics/transactions/recent?limit=10
    [HttpGet("transactions/recent")]
    public async Task<ActionResult<IEnumerable<TransactionSummary>>> GetRecentTransactions([FromQuery] int limit = 20)
    {
        var recentTransactions = await _db.Transactions
            .OrderByDescending(t => t.Date)
            .Take(limit)
            .Select(t => new TransactionSummary
            {
                TransactionId = t.Id,
                AccountId = t.AccountId,
                Amount = t.Money.Amount,
                Date = t.Date,
                AccountName = t.Account != null ? t.Account.Name : null
            })
            .ToListAsync();

        return Ok(recentTransactions);
    }
}

public class OverviewStatistics
{
    public int TotalUsers { get; set; }
    public int TotalAccounts { get; set; }
    public int TotalFunds { get; set; }
    public int TotalTransactions { get; set; }
    public int TotalUserAccountLinks { get; set; }
    public double AverageAccountsPerUser { get; set; }
    public double AverageFundsPerUser { get; set; }
    public double AverageTransactionsPerAccount { get; set; }
}

public class UserAccountStatistics
{
    public int UserId { get; set; }
    public int TotalAccounts { get; set; }
    public decimal TotalBalance { get; set; }
    public Dictionary<string, int> AccountsByType { get; set; } = new();
}

public class UserFundStatistics
{
    public int UserId { get; set; }
    public int TotalFunds { get; set; }
    public decimal TotalGoalAmount { get; set; }
    public decimal TotalCurrentAmount { get; set; }
    public decimal OverallProgressPercentage { get; set; }
}

public class AccountTransactionStatistics
{
    public int AccountId { get; set; }
    public int TotalTransactions { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal AverageAmount { get; set; }
    public decimal MaxTransactionAmount { get; set; }
    public decimal MinTransactionAmount { get; set; }
    public int PositiveTransactionCount { get; set; }
    public int NegativeTransactionCount { get; set; }
    public decimal TotalDeposits { get; set; }
    public decimal TotalWithdrawals { get; set; }
}

public class AccountSummary
{
    public int AccountId { get; set; }
    public string? Name { get; set; }
    public string AccountType { get; set; } = string.Empty;
    public decimal Balance { get; set; }
    public int TransactionCount { get; set; }
}

public class AccountActivity
{
    public int AccountId { get; set; }
    public string? Name { get; set; }
    public int TransactionCount { get; set; }
    public decimal Balance { get; set; }
}

public class FundProgress
{
    public int FundId { get; set; }
    public string? Description { get; set; }
    public decimal GoalAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public decimal ProgressPercentage { get; set; }
    public decimal RemainingAmount { get; set; }
}

public class UserSummary
{
    public int UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Email { get; set; }
    public int AccountCount { get; set; }
    public int FundCount { get; set; }
}

public class TransactionSummary
{
    public int TransactionId { get; set; }
    public int AccountId { get; set; }
    public string? AccountName { get; set; }
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
}
