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
        
        public async Task SeedUsers(){
            var users = new List<User>();

            var user1 = new User()
            {
                Credentials = new Credentials
                {
                    UserName = "demo",
                    Name = "Demo User",
                    Password = "password123",
                    Email = "demo@example.com"
                }
            };

            var user2 = new User()
            {
                Credentials = new Credentials
                {
                    UserName = "demo2",
                    Name = "Demo User2",
                    Password = "password123",
                    Email = "demo@example.com"
                }
            };

            users.Add(user1);
            users.Add(user2);

            await _db.Users.AddRangeAsync(users);
            await _db.SaveChangesAsync();}

        public async Task SeedAccounts()
        {
            var account = new Account()
            {
                Name = "Checking",
                AccountType = AccountType.Checking,
                Balance = new Money { Amount = 1000, Currency = "USD" }
            };

            _db.Accounts.Add(account);
            await _db.SaveChangesAsync();
        }
        public async Task SeedTransactions(){
            var transaction = new Transaction()
            {
                AccountId = 1,
                Date = DateTime.UtcNow,
                Money = new Money { Amount = -50, Currency = "$USD" },
            };

            _db.Transactions.Add(transaction);
            await _db.SaveChangesAsync();}
        public async Task SeedFunds()
        {
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
        }
        public async Task SeedUserAccounts()
        {
            var userAccount = new UserAccount()
            {
                UserId = 1,
                AccountId = 1,
            };

            _db.UserAccounts.Add(userAccount);
            await _db.SaveChangesAsync();
        }
        public async Task SeedUserFunds()
        {
            var userFund = new UserFund()
            {
                UserId = 1,
                FundId = 1,
            };

            _db.UserFunds.Add(userFund);
            await _db.SaveChangesAsync();
        }

        public async Task SeedAsync()
        {

            await _db.Database.EnsureDeletedAsync();
            await _db.Database.EnsureCreatedAsync();

            await SeedUsers();
            await SeedFunds();
            await SeedAccounts();
            await SeedTransactions();
            await SeedUserAccounts();
            await SeedUserFunds();                     
        }
    }
}
