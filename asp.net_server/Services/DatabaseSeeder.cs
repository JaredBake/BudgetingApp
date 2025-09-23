using App.Models;
using Microsoft.EntityFrameworkCore;

namespace App.Services
{
    public class DatabaseSeeder
    {
        private readonly BudgetDbContext _db;

        public DatabaseSeeder(BudgetDbContext db)
        {
            _db = db;
        }

        public async Task SeedAsync()
        {
            
            await _db.Database.EnsureDeletedAsync();
            await _db.Database.EnsureCreatedAsync();

            // Prevent duplicate seeding
            if (await _db.Users.AnyAsync()) return;

            var user = new User()
            {
                CreatedAt = DateTime.UtcNow,
                Credentials = new Credentials
                {
                    UserName = "demo",
                    Name = "Demo User",
                    Password = "password123",
                    Email = "demo@example.com"                    
                }
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            var account = new Account()
            {
                Name = "Checking",
                AccountType = AccountType.Checking,
                Balance = new Money { Amount = 1000, Currency = "USD" }
            };

            _db.Accounts.Add(account);
            await _db.SaveChangesAsync();

            var userAccount = new UserAccount()
            {
                UserId = user.Id,
                AccountId = account.Id,
            };

            _db.UserAccounts.Add(userAccount);
            await _db.SaveChangesAsync();

            var fund = new Fund()
            {
                Description = "Emergency Fund",
                GoalAmount = new Money()
                {
                    Amount = 100.12M,
                    Currency = "$USD"
                },
                Current = new Money()
                {
                    Amount = 0.00M,
                    Currency = "$USD"
                }
            };

            _db.Funds.Add(fund);
            await _db.SaveChangesAsync();

            var userFund = new UserFund()
            {
                UserId = user.Id,
                FundId = fund.Id,
            };

            _db.UserFunds.Add(userFund);
            await _db.SaveChangesAsync();

            var transaction = new Transaction()
            {
                AccountId = account.Id,
                Date = DateTime.UtcNow,
                Money = new Money { Amount = -50, Currency = "$USD" },
                Account = account
            };

            _db.Transactions.Add(transaction);
            await _db.SaveChangesAsync();
        }
    }
}
