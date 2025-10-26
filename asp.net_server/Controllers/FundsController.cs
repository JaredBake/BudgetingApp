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
    public async Task<ActionResult<Account>> PostFund(Fund fund)
    {      

        _context.Funds.Add(fund);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetFund), new { Id = fund.Id }, fund);
    }

    public class bodyObject { public int userId { get; set; } public int fundId { get; set; } }
    [HttpPost("User")]
    public async Task<ActionResult> JoinUserFund([FromBody] bodyObject request)
    {

        if (!IsUser(request.userId)) return Forbid(); 

        var user = await _context.Users.FindAsync(request.userId);
        var fund = await _context.Funds.FindAsync(request.fundId);

        if (user == null) return NotFound($"User: {request.userId} not found");
        if (fund == null) return NotFound($"Fund: {request.fundId} not found");

        if (await BelongsToUser(request.fundId, request.userId))
        {
            return BadRequest($"User: {request.userId} is already connected to this account: {request.fundId}");
        }

        var userFund = new UserFund
        {
            UserId = request.userId,
            FundId = request.fundId
        };

        _context.UserFunds.Add(userFund);
        await _context.SaveChangesAsync();

        return Ok("User association successfully created");
    }

    [HttpDelete("User")]
    public async Task<ActionResult> DeleteUserFund([FromBody] bodyObject request)
    {
        if (!await AuthorizeUser(request.fundId)) return Forbid();

        var userFund = new UserFund
        {
            UserId = request.userId,
            FundId = request.fundId
        };

        try
        {
            _context.UserFunds.Remove(userFund);
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await BelongsToUser(request.fundId, request.userId))
            {
                return BadRequest($"");
            }
            if (!FundExists(request.fundId))
            {
                return NotFound($"");
            }
            if (!UserExists(request.userId))
            {
                return NotFound($"");
            }
            else
            {
                throw;
            }
        }

        return Ok("User association successfully deleted");

    }

    [HttpGet("User")]
    public async Task<ActionResult<bool>> TestBelongs([FromBody] bodyObject request)
    {
        if (!await AuthorizeUser(request.fundId)) return Forbid();
        return await BelongsToUser(request.fundId, request.userId);
    }

    [HttpPut()]
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

        var userFunds = _context.UserFunds.Where(e => e.FundId == Id);
        _context.UserFunds.RemoveRange(userFunds);

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
        var existingJoin = await _context.UserFunds
            .FirstOrDefaultAsync(uf => uf.UserId == userId && uf.FundId == fundId);

        if (existingJoin == null) return false;
        else return true;
    }

    private async Task<bool> AuthorizeUser(int fundId)
    {
        if (User.IsInRole("Admin")) return true;

        return await BelongsToUser(fundId, GetCurrentUserId());
    }

    public bool IsUser(int userId)
    {
        if (User.IsInRole("Admin")) return true;

        return GetCurrentUserId() == userId;
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.Parse(userIdClaim ?? "0");
    }
}