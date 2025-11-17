using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
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
        public DbSet<Category> Categories { get; set; }
        
        public DbSet<UserAccount> UserAccounts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Account>().OwnsOne(a => a.Balance);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.GoalAmount);
            modelBuilder.Entity<Fund>().OwnsOne(f => f.Current);
            modelBuilder.Entity<Transaction>().OwnsOne(t => t.Money);
            modelBuilder.Entity<User>().OwnsOne(u => u.Credentials);

            modelBuilder.Entity<User>()
                .Property(u => u.Id)
                .ValueGeneratedOnAdd()
                .UseIdentityColumn();

             modelBuilder.Entity<Account>()
                .Property(a => a.Id)
                .ValueGeneratedOnAdd()
                .UseIdentityColumn();

            modelBuilder.Entity<Fund>()
                .Property(f => f.Id)
                .ValueGeneratedOnAdd()
                .UseIdentityColumn();

            modelBuilder.Entity<Transaction>()
                .Property(t => t.Id)
                .ValueGeneratedOnAdd()
                .UseIdentityColumn();


            // User Account Junction Table Relationships
            modelBuilder.Entity<UserAccount>()
                .HasKey(ua => new { ua.UserId, ua.AccountId });

            modelBuilder.Entity<UserAccount>()
                .HasOne(ua => ua.User)
                .WithMany(u => u.UserAccounts)
                .HasForeignKey(ua => ua.UserId);

            modelBuilder.Entity<UserAccount>()
                .HasOne(ua => ua.Account)
                .WithMany(a => a.UserAccounts)
                .HasForeignKey(ua => ua.AccountId);

            // Fund to User relationship
            modelBuilder.Entity<Fund>()
                .HasOne(f => f.User)
                .WithMany(u => u.Funds)
                .HasForeignKey(f => f.UserId);

            modelBuilder.Entity<Account>()
                .HasMany(a => a.Transactions)
                .WithOne(t => t.Account)
                .HasForeignKey(t => t.AccountId);

            // Indexes for Performance
            modelBuilder.Entity<UserAccount>()
                .HasIndex(ua => ua.UserId);
            
            modelBuilder.Entity<UserAccount>()
                .HasIndex(ua => ua.AccountId);

            modelBuilder.Entity<Fund>()
                .HasIndex(f => f.UserId);

        }       
    }

    public class UserAccount
    {
        public required int UserId { get; set; }
        public required int AccountId { get; set; }

        [JsonIgnore]
        public virtual User? User { get; set; } = null!;

        [JsonIgnore]
        public virtual Account? Account { get; set; } = null!;
        
    }

    public class Money
    {
        public required decimal Amount { get; set; }
        public string? Currency { get; set; } = "$USD";
    }

    public enum AccountType
    {
        Checking, Saving, CreditCard, Brokerage
    }

    public enum TransactionType
    {
        Expense, Income
    }

    public class Account
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public required AccountType AccountType { get; set; }
        public required Money Balance { get; set; }

        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
        public virtual ICollection<UserAccount> UserAccounts { get; set; } = new List<UserAccount>();    
                
    }

    public class Fund
    {
        public int Id { get; set; }
        public string? Description { get; set; }
        public required Money GoalAmount { get; set; }
        public required Money Current { get; set; }
        public int UserId { get; set; }

        [JsonIgnore]
        public virtual User? User { get; set; } = null!;
        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
        
    }

    public class Category
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required int UserId { get; set; }

        [JsonIgnore]
        public virtual User? User { get; set; } = null!;

        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }

    public class Transaction
    {
        public int Id { get; set; }
        public required int AccountId { get; set; }
        public DateTime Date { get; set; } = DateTime.UtcNow;
        public required Money Money { get; set; }
        public required TransactionType Type { get; set; }
        public int? CategoryId { get; set; }
        public int? FundId { get; set; }

        [JsonIgnore]
        public virtual Account? Account { get; set; } = null!;

        [JsonIgnore]
        public virtual Category? Category { get; set; } = null!;

        [JsonIgnore]
        public virtual Fund? Fund { get; set; } = null!;

    }
    
    public enum UserRole
    {
        Admin, User
    }

    public class Credentials
    {
        public required String Name { get; set; }

        public required String? UserName { get; set; }

        [JsonIgnore]
        public String? Password { get; set; }
        
        public required String? Email { get; set; }

        public UserRole? Role { get; set; } = UserRole.User;
    }

    public class User
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public required Credentials Credentials { get; set; }

        public virtual ICollection<UserAccount> UserAccounts { get; set; } = new List<UserAccount>();
        public virtual ICollection<Fund> Funds { get; set; } = new List<Fund>();

        [NotMapped]
        public IEnumerable<Account> Accounts => UserAccounts.Select(ua => ua.Account!);

    }
}
