using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

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
        public required int UserId { get; set; }
        public required int Id { get; set; }
        public string? Name { get; set; }
        public required AccountType AccountType { get; set; }
        public required Money Balance { get; set; }

        public List<Transaction>? Transactions { get; set; }
        
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
        public required int AccountId { get; set; }       
        public required int Id { get; set; }
        public DateTime Date { get; set; }
        public required Money Money { get; set; }

        public required int UserId { get; set; }
        
    }

    public class User
    {
        public required int id { get; set; }
        public DateTime CreatedAt { get; set; }

        public string? UserName { get; set; }
        public string? Name { get; set; }
        public string? Password { get; set; }
        public string? Email { get; set; }

        public List<Account>? Accounts { get; set; }
        public List<Fund>? Funds { get; set; }
        
    }
}
