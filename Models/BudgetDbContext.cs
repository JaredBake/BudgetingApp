using Microsoft.EntityFrameworkCore;

namespace App.Models
{
    public class BudgetDbContext(DbContextOptions<BudgetDbContext> options) : DbContext(options)
    {
        public DbSet<User> Users { get; set; }
    }

    public class User
    {
        public int id { get; set; }
        public string name { get; set; }
        public string email { get; set; }
    }
}