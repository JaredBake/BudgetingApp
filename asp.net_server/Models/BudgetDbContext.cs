using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace App.Models
{
    public class BudgetDbContext : DbContext
    {
        public BudgetDbContext(DbContextOptions<BudgetDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Fund> Funds { get; set; }
        public DbSet<Transaction> Transactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Account>().OwnsOne(a => a.Balance);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.GoalAmount);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.Current);
            modelBuilder.Entity<Transaction>().OwnsOne(t => t.Money);          

             modelBuilder.Entity<User>()
                .HasMany(u => u.Accounts)
                .WithOne(a => a.User)
                .HasForeignKey(a => a.UserId);

            modelBuilder.Entity<User>()
                .HasMany(u => u.Funds)
                .WithOne()
                .HasForeignKey(f => f.UserId);

            modelBuilder.Entity<Account>()
                .HasMany(a => a.Transactions)
                .WithOne(t => t.Account)
                .HasForeignKey(t => t.AccountId);
        }       
    }

    public class Money
    {
        public required decimal Amount { get; set; }
        public string? Currency { get; set; }
    }

    public enum AccountType
    {
        Checking, Saving
    }

    public class Account
    {
        public required int Id { get; set; }
        public required int UserId { get; set; }
        public string? Name { get; set; }
        public required AccountType AccountType { get; set; }
        public required Money Balance { get; set; }

        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();

        [JsonIgnore]
        public virtual User? User { get; set; } = null!;
                
    }

    public class Fund
    {
        public required int Id { get; set; }
        public required int UserId { get; set; }
        public string? Description { get; set; }
        public required Money GoalAmount { get; set; }
        public required Money Current { get; set; }
    }

    public class Transaction
    {
        public required int Id { get; set; }
        public required int AccountId { get; set; }
        public DateTime Date { get; set; }
        public required Money Money { get; set; }

        [JsonIgnore]
        public virtual Account? Account { get; set; } = null!;
               
    }

    public class User
    {
        public required int Id { get; set; }
        public DateTime CreatedAt { get; set; }

        public string? UserName { get; set; }
        public string? Name { get; set; }
        [JsonIgnore]
        public string? Password { get; set; }
        public string? Email { get; set; }

        public virtual ICollection<Account> Accounts { get; set; } = new List<Account>();
        public virtual ICollection<Fund> Funds { get; set; } = new List<Fund>();
        
    }
}
