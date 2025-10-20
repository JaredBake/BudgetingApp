using App.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

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


    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Fund>>> GetFunds()
    {
        return await _context.Funds.ToListAsync();
    }

    [HttpGet("{Id}")]
    public async Task<ActionResult<Fund>> GetFund(int Id)
    {
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
    [HttpPost("joinUserFund")]
    public async Task<ActionResult> JoinUserFund([FromBody] bodyObject request)
    {
        var user = await _context.Users.FindAsync(request.userId);
        var fund = await _context.Funds.FindAsync(request.fundId);

        if (user == null) return NotFound($"User: {request.userId} not found");
        if (fund == null) return NotFound($"Fund: {request.fundId} not found");

        var existingJoin = await _context.UserFunds
            .FirstOrDefaultAsync(ua => ua.UserId == request.userId && ua.FundId == request.fundId);

        if (existingJoin != null) return BadRequest($"User: {request.userId} is already connected to this fund: {request.fundId}");

        var userFund = new UserFund
        {
            UserId = request.userId,
            FundId = request.fundId
        };

        _context.UserFunds.Add(userFund);
        await _context.SaveChangesAsync();

        return Ok("User association successfully created");        
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutFund(int Id, Fund fund)
    {
        if (Id != fund.Id) return BadRequest($"Id: {Id} parameter doesn't equal fund.Id: {fund.Id}");        

        if (!FundExists(Id)) return NotFound($"No fund found to update with Id: {fund.Id}");
        
        _context.Entry(fund).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!FundExists(Id))
            {
                return NotFound($"No fund found to update with Id: {fund.Id}");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    [HttpDelete("{Id}")]
    public async Task<IActionResult> DeleteFund(int Id)
    {
        var fund = await _context.Funds.FindAsync(Id);
        if (fund == null)
        {
            return NotFound($"No fund found to delete with Id: {Id}");
        }

        _context.Funds.Remove(fund);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool FundExists(int Id)
    {
        return _context.Funds.Any(e => e.Id == Id);
    }
}