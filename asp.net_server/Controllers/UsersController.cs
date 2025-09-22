using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly BudgetDbContext _context;

    public UsersController(BudgetDbContext context)
    {
        _context = context;
    }

    [HttpGet()]
    public bool check()
    {
        return true;
    }

    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<User>>> GetUsers()
    {

        return await _context.Users
            .Include(u => u.Accounts)
            .ThenInclude(a => a.Transactions)
            .Include(u => u.Funds)
            .ToListAsync();               
    }   

    [HttpGet("{Id}")]
    public async Task<ActionResult<User>> GetUser(int Id)
    {
        var user = await _context.Users
            .Include(u => u.Accounts)
            .Include(u => u.Funds)
            .FirstOrDefaultAsync(u => u.Id == Id);

        if (user == null)
        {
            return NotFound();
        }

        return user;
    }

    [HttpPost("PostUser")]
    public async Task<ActionResult<User>> PostUser(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUser), new { Id = user.Id }, user);
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutUser(int Id, User user)
    {
        if (Id != user.Id)
        {
            return BadRequest();
        }

        _context.Entry(user).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!UserExists(Id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteUser(int Id)
    {
        var user = await _context.Users.FindAsync(Id);
        if (user == null)
        {
            return NotFound();
        }

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool UserExists(int Id)
    {
        return _context.Users.Any(e => e.Id == Id);
    }
}