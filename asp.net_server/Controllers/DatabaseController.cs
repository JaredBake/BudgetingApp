using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;


namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DatabaseController : ControllerBase
{
    private readonly BudgetDbContext _db;

    public DatabaseController(BudgetDbContext db)
    {
        _db = db;
    }
    
    [HttpGet("check")]
    public bool check()
    {
        return true;
    }

    [HttpPost("migrate")]
    public async Task<IActionResult> Migrate()
    {
        try{
            await _db.Database.MigrateAsync();
            return Ok("Database schema updated successfully");
        }
        catch (Exception ex){
            return StatusCode(500, $"Migration failed: {ex.Message}");
        }
         
    }    
}