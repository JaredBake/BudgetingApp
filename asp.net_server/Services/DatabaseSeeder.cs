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
            List<Account>? accounts;

            using (StreamReader r = new StreamReader("Services/MockData/accounts.json"))
            {
                string json = r.ReadToEnd();
                accounts = JsonConvert.DeserializeObject<List<Account>>(json);
            }

            if (accounts == null) throw new NullReferenceException("Accounts were not read properly");

            await _db.Accounts.AddRangeAsync(accounts);
            await _db.SaveChangesAsync();
        }
        public async Task SeedTransactions() {
            List<Transaction>? transactions;

            using (StreamReader r = new StreamReader("Services/MockData/transactions.json"))
            {
                string json = r.ReadToEnd();
                transactions = JsonConvert.DeserializeObject<List<Transaction>>(json);
            }

            if (transactions == null) throw new NullReferenceException("Transactions were not read properly");

            await _db.Transactions.AddRangeAsync(transactions);
            await _db.SaveChangesAsync();
        }
        
        public async Task SeedUserAccounts()
        {
            List<UserAccount>? userAccounts;

            using (StreamReader r = new StreamReader("Services/MockData/userAccounts.json"))
            {
                string json = r.ReadToEnd();
                userAccounts = JsonConvert.DeserializeObject<List<UserAccount>>(json);
            }

            if (userAccounts == null) throw new NullReferenceException("UserAccounts were not read properly");

            await _db.UserAccounts.AddRangeAsync(userAccounts);
            await _db.SaveChangesAsync();
        }
        public async Task SeedUserFunds()
        {
            List<UserFund>? userFunds;

            using (StreamReader r = new StreamReader("Services/MockData/userFunds.json"))
            {
                string json = r.ReadToEnd();
                userFunds = JsonConvert.DeserializeObject<List<UserFund>>(json);
            }

            if (userFunds == null) throw new NullReferenceException("UserFunds were not read properly");

            await _db.UserFunds.AddRangeAsync(userFunds);
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
                await SeedAccounts();
                await SeedTransactions();
                await SeedUserAccounts();
                await SeedUserFunds();
            }
            catch (NullReferenceException e)
            {
                Console.WriteLine("Cannot load data: " + e.Message);
            }
        }
    }
}
