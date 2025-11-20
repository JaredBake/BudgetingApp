using System.Security.Claims;
using App.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]

public class CategoriesController : ControllerBase
{
    private readonly BudgetDbContext _context;

    public CategoriesController(BudgetDbContext context)
    {
        _context = context;
    }

    [AllowAnonymous]
    [HttpGet()]
    public bool check() { return true; }

    [Authorize]
    [HttpGet("auth")]
    public bool checkAuth() { return true; }

    [Authorize(Roles = "Admin")]
    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Category>>> GetCategories()
    {
        return await _context.Categories.ToListAsync();
    }

    [HttpGet("MyCategories")]
    public async Task<ActionResult<IEnumerable<Category>>> GetUserCategories()
    {
        var userId = GetCurrentUserId();
        var categories = await _context.Categories
            .Where(c => c.UserId == userId)
            .OrderBy(c => c.Name)
            .ToListAsync();

        return categories;
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Category>> GetCategory(int Id)
    {
        var category = await _context.Categories.FindAsync(Id);

        if (category == null)
        {
            return NotFound();
        }

        if (!await AuthorizeUser(category.UserId))
        {
            return Forbid();
        }

        return category;
    }

    [HttpPost()]
    public async Task<ActionResult<Category>> PostCategory([FromBody] Category category)
    {
        var userId = GetCurrentUserId();
        
        // Enforce that the category belongs to the current user
        category.UserId = userId;

        // Check for duplicate category name for this user
        var existingCategory = await _context.Categories
            .FirstOrDefaultAsync(c => c.UserId == userId && c.Name == category.Name);

        if (existingCategory != null)
        {
            return BadRequest($"Category '{category.Name}' already exists for this user.");
        }

        _context.Categories.Add(category);
        
        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            // Handle unique constraint violation
            return BadRequest($"Category '{category.Name}' already exists for this user.");
        }

        return CreatedAtAction(nameof(GetCategory), new { Id = category.Id }, category);
    }

    [HttpPut()]
    public async Task<IActionResult> PutCategory(Category category)
    {
        if (!await AuthorizeUser(category.UserId))
        {
            return Forbid();
        }

        if (!CategoryExists(category.Id))
        {
            return NotFound($"No category found to update with Id: {category.Id}");
        }

        // Check for duplicate category name for this user (excluding the current category)
        var existingCategory = await _context.Categories
            .FirstOrDefaultAsync(c => c.UserId == category.UserId && c.Name == category.Name && c.Id != category.Id);

        if (existingCategory != null)
        {
            return BadRequest($"Category '{category.Name}' already exists for this user.");
        }

        _context.Entry(category).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!CategoryExists(category.Id))
            {
                return NotFound($"No category found to update with Id: {category.Id}");
            }
            else
            {
                throw;
            }
        }
        catch (DbUpdateException)
        {
            return BadRequest($"Category '{category.Name}' already exists for this user.");
        }

        return Ok(category);
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteCategory(int Id)
    {
        var category = await _context.Categories.FindAsync(Id);
        if (category == null)
        {
            return NotFound($"No category found to delete with Id: {Id}");
        }

        if (!await AuthorizeUser(category.UserId))
        {
            return Forbid();
        }

        _context.Categories.Remove(category);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool CategoryExists(int Id)
    {
        return _context.Categories.Any(e => e.Id == Id);
    }

    private async Task<bool> AuthorizeUser(int categoryUserId)
    {
        if (User.IsInRole("Admin")) return true;

        return categoryUserId == GetCurrentUserId();
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.Parse(userIdClaim ?? "0");
    }
}
