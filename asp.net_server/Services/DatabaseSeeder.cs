using App.Models;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;

namespace App.Services
{
    public class DatabaseSeeder
    {
        private readonly BudgetDbContext _db;

        public DatabaseSeeder(BudgetDbContext db)
        {
            _db = db;
        }

        public async Task SeedUsers()
        {
            List<User>? users;           
            
            using (StreamReader r = new StreamReader("Services/MockData/users.json"))
            {
                string json = r.ReadToEnd();
                users = JsonConvert.DeserializeObject<List<User>>(json);
            }

            if (users == null) throw new NullReferenceException("Creds were not read properly");
            
            await _db.Users.AddRangeAsync(users);
            await _db.SaveChangesAsync();}

        public async Task SeedFunds()
        {
            List<Fund>? funds;

            using (StreamReader r = new StreamReader("Services/MockData/funds.json"))
            {
                string json = r.ReadToEnd();
                funds = JsonConvert.DeserializeObject<List<Fund>>(json);
            }

            if (funds == null) throw new NullReferenceException("Funds were not read properly");

            await _db.Funds.AddRangeAsync(funds);
            await _db.SaveChangesAsync();
        }
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

            try
            {
                await SeedUsers();
                await SeedFunds();
                // await SeedAccounts();
                // await SeedTransactions();
                // await SeedUserAccounts();
                // await SeedUserFunds();
            }
            catch (NullReferenceException e)
            {
                Console.WriteLine("Cannot load data: " + e.Message);
            }
        }
    }
}
