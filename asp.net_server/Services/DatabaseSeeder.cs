using App.Controllers;
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

        private async Task SeedEntity<T>(string entityName) where T : class
        {
            List<T>? entities;

            using (StreamReader r = new StreamReader($"Services/MockData/{entityName}.json"))
            {
                string json = r.ReadToEnd();
                entities = JsonConvert.DeserializeObject<List<T>>(json);
            }

            if (entities == null) throw new NullReferenceException($"{entityName} was not read properly");

            await _db.Set<T>().AddRangeAsync(entities);
            await _db.SaveChangesAsync();
        }
        
        private async Task SeedUsers(string entityName)
        {
            List<User>? entities;

            using (StreamReader r = new StreamReader($"Services/MockData/{entityName}.json"))
            {
                string json = r.ReadToEnd();
                entities = JsonConvert.DeserializeObject<List<User>>(json);
            }

            if (entities == null) throw new NullReferenceException($"{entityName} was not read properly");

            for (int i = 0; i < entities.Count; i++)
            {
                var user = entities[i];

                if (user.Credentials.Password == null) continue;
            

                string newPassword = AuthController.HashPassword(user.Credentials.Password);
                
                entities[i].Credentials.Password = newPassword;
            }
            
            await _db.Set<User>().AddRangeAsync(entities);
            await _db.SaveChangesAsync();
        }
       
        public async Task SeedAsync()
        {

            await _db.Database.EnsureDeletedAsync();
            await _db.Database.EnsureCreatedAsync();

            try
            {
                await SeedUsers("Users"); // Special function for password handling

                await SeedEntity<Fund>("Funds");
                await SeedEntity<Account>("Accounts");
                await SeedEntity<Transaction>("Transactions");
                await SeedEntity<UserAccount>("UserAccounts");
                await SeedEntity<UserFund>("UserFunds");
            }
            catch (NullReferenceException e)
            {
                Console.WriteLine("Cannot load data: " + e.Message);
            }
        }
    }
}
