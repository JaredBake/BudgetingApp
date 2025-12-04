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

            // Special handling for Transaction entities to set default Type if not specified
            if (typeof(T) == typeof(Transaction))
            {
                var transactions = entities as List<Transaction>;
                if (transactions != null)
                {
                    var random = new Random();
                    foreach (var transaction in transactions)
                    {
                        // Set Type to Expense by default if not set (default enum value is 0 which is Expense)
                        // Randomly assign some as Income for variety in seed data
                        if (transaction.Type == default(TransactionType))
                        {
                            transaction.Type = random.Next(0, 10) < 3 ? TransactionType.Income : TransactionType.Expense;
                        }
                    }
                }
            }

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
                await SeedUsers("users"); // Special function for password handling

                await SeedEntity<Category>("categories");
                await SeedEntity<Fund>("funds");
                await SeedEntity<Account>("accounts");
                await SeedEntity<Transaction>("transactions");
                await SeedEntity<UserAccount>("userAccounts");
               
                Console.WriteLine("Database Re-seeded!");
            }
            catch (NullReferenceException e)
            {
                Console.WriteLine("Cannot load data: " + e.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Seeding error: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> CanConnect()
        {
            try
            {
                return await _db.Database.CanConnectAsync();
            }
            catch
            {
                return false;
            }
        }
        
        public async Task EnsureDbExists()
        {
            try
            {
                if (!await CanConnect())
                {
                    await _db.Database.EnsureCreatedAsync();
                    await SeedAsync();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating database: {ex.Message}");
            }
        }
    }
}
