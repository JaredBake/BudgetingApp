// using App.Models;
// using Microsoft.EntityFrameworkCore;

// namespace App.Services
// {
//     public class DatabaseSeeder
//     {
//         private readonly BudgetDbContext _db;

//         public DatabaseSeeder(BudgetDbContext db)
//         {
//             _db = db;
//         }

//         public async Task SeedAsync()
//         {
//             // Apply migrations first
//             await _db.Database.MigrateAsync();

//             // Prevent duplicate seeding
//             if (await _db.Users.AnyAsync()) return;

//             var user = new User
//             {
//                 CreatedAt = DateTime.UtcNow,
//                 UserName = "demo",
//                 Name = "Demo User",
//                 Password = "password123", // ⚠️ plain text only for fake/demo data
//                 Email = "demo@example.com",
//                 Accounts = new List<Account>
//                 {
//                     new Account
//                     {
//                         Name = "Checking",
//                         AccountType = AccountType.Checking,
//                         Balance = new Money { Amount = 1000, Currency = "USD" }
//                     }
//                 },
//                 Funds = new List<Fund>
//                 {
//                     new Fund
//                     {
//                         Description = "Vacation Fund",
//                         GoalAmount = new Money { Amount = 2000, Currency = "USD" },
//                         Current = new Money { Amount = 500, Currency = "USD" }
//                     }
//                 },
//                 Transactions = new List<Transaction>
//                 {
//                     new Transaction
//                     {
//                         Date = DateTime.UtcNow,
//                         Money = new Money { Amount = -50, Currency = "USD" }
//                     }
//                 }
//             };

//             _db.Users.Add(user);
//             await _db.SaveChangesAsync();
//         }
//     }
// }
