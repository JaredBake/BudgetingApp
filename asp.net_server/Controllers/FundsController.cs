using System.Security.Claims;
using App.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]

public class FundsController : ControllerBase
{
    private readonly BudgetDbContext _context;

    public FundsController(BudgetDbContext context)
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
    public async Task<ActionResult<IEnumerable<Fund>>> GetFunds()
    {
        return await _context.Funds.ToListAsync();
    }

    [HttpGet("MyFunds")]
    public async Task<ActionResult<IEnumerable<Fund>>> GetUserFunds()
    {
        var userId = GetCurrentUserId();
        
        var funds = await _context.Funds
            .Where(f => f.UserId == userId)
            .ToListAsync();

        return Ok(funds);
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Fund>> GetFund(int Id)
    {
        if (!await AuthorizeUser(Id)) return Forbid();

        var fund = await _context.Funds.FindAsync(Id);

        if (fund == null)
        {
            return NotFound();
        }

        return fund;
    }

    [HttpPost()]
    public async Task<ActionResult<Fund>> PostFund(Fund fund)
    {      
        var userId = GetCurrentUserId();
        fund.UserId = userId;

        _context.Funds.Add(fund);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetFund), new { Id = fund.Id }, fund);
    }

    [HttpDelete("User")]
    public async Task<IActionResult> PutFund(Fund fund)
    {
        if (!await AuthorizeUser(fund.Id)) return Forbid();

        if (!FundExists(fund.Id)) return NotFound($"No fund found to update with Id: {fund.Id}");
        
        _context.Entry(fund).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!FundExists(fund.Id))
            {
                return NotFound($"No fund found to update with Id: {fund.Id}");
            }
            else
            {
                throw;
            }
        }

        return Ok(fund);
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteFund(int Id)
    {
        if (!await AuthorizeUser(Id)) return Forbid();

        var fund = await _context.Funds.FindAsync(Id);
        if (fund == null)
        {
            return NotFound($"No fund found to delete with Id: {Id}");
        }

        _context.Funds.Remove(fund);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool UserExists(int Id)
    {
        return _context.Users.Any(e => e.Id == Id);
    }

    private bool FundExists(int Id)
    {
        return _context.Funds.Any(e => e.Id == Id);
    }

    private async Task<bool> BelongsToUser(int fundId, int userId)
    {
        var fund = await _context.Funds
            .FirstOrDefaultAsync(f => f.Id == fundId && f.UserId == userId);

        return fund != null;
    }

    private async Task<bool> AuthorizeUser(int fundId)
    {
        if (User.IsInRole("Admin")) return true;

        return await BelongsToUser(fundId, GetCurrentUserId());
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.Parse(userIdClaim ?? "0");
    }
}