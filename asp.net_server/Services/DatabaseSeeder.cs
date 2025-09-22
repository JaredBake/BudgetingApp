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
                Id = 10001,
                CreatedAt = DateTime.UtcNow,
                UserName = "demo",
                Name = "Demo User",
                Password = "password123",
                Email = "demo@example.com"
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            var account = new Account()
            {
                Id = 10001,
                Name = "Checking",
                AccountType = AccountType.Checking,
                Balance = new Money { Amount = 1000, Currency = "USD" },
                UserId = 10001,
                User = user
            };

            _db.Accounts.Add(account);
            await _db.SaveChangesAsync();

            var fund = new Fund()
            {
                Id = 30001,
                UserId = 10001,
                Description = "n/a",
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

            var transaction = new Transaction()
            {
                UserId = 10001,
                AccountId = 10001,
                Id = 40001,
                Date = DateTime.UtcNow,
                Money = new Money { Amount = -50, Currency = "$USD" },
                Account = account
            };

            _db.Transactions.Add(transaction);
            await _db.SaveChangesAsync();
        }
    }
}
