/*
using System.Data.SqlTypes;
using System.Security.Principal;
using System.Transactions;
using Grpc.Core;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace App.Models
{
    public class BudgetDbContext(DbContextOptions<BudgetDbContext> options) : DbContext(options)
    {
        public DbSet<User> Users { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Fund> Funds { get; set; }
        public DbSet<Transaction> Transactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder){
            modelBuilder.Entity<Account>().OwnsOne(a => a.Balance);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.GoalAmount);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.Current);
            modelBuilder.Entity<Transaction>().OwnsOne(t => t.Money);
        }
    }

    public class Fund
    {
        public required string description { get; set; }

        public required Money goal_amount { get; set; }

        public required Money current { get; set; }
    }

    public class Money
    {
        decimal amount { get; set; }

        public required string Currency { get; set; }
    }
    public class TransactionsContoller
    {

        public int id { get; set; }
        public DateTime date;

        public required Money money { get; set; }
    }

    public enum AccountType
    {
        Checking, Saving
    }
    public class Account
    {
        public int id { get; set; }

        public required string Name { get; set; }

        public AccountType accountType;

        public required Money Balance;
    }

    public class User
    {
        public class Credentials
        {
            public required String userName { get; set; }
            public required String name { get; set; }
            public required String password { get; set; }
            public required String email { get; set; }
        }

        public class Data
        {
            public required List<Transaction> transactions;

            public required List<Fund> funds;

            public required List<Account> accounts;

        }

        public int id { get; set; }

        public DateTime createdAt { get; set; }

        public required Credentials credentials { get; set; }
    }
}

*/

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
        public required string Currency { get; set; }
    }

    public enum AccountType
    {
        Checking, Saving
    }

    public class Account
    {
        public required int Id { get; set; }
        public required string Name { get; set; }
        public required AccountType AccountType { get; set; }
        public required Money Balance { get; set; }

        public required int UserId { get; set; }
        public required User User { get; set; }
    }

    public class Fund
    {
        public required int Id { get; set; }
        public required string Description { get; set; }
        public required Money GoalAmount { get; set; }
        public required Money Current { get; set; }

        public required int UserId { get; set; }
        public required User User { get; set; }
    }

    public class Transaction
    {
        public required int Id { get; set; }
        public required DateTime Date { get; set; }
        public required Money Money { get; set; }
 
        public required int UserId { get; set; }
        public required User User { get; set; }
 
        public required int? AccountId { get; set; }
        public required Account Account { get; set; }
    }

    public class User
    {
        public required int id { get; set; }
        public required DateTime CreatedAt { get; set; }

        required public string UserName { get; set; }
        required public string Name { get; set; }
        required public string Password { get; set; }
        required public string Email { get; set; }

        public required List<Account> Accounts { get; set; }
        public required List<Fund> Funds { get; set; }
        public required List<Transaction> Transactions { get; set; }
    }
}
