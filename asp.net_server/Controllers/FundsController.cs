using App.Models;
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

    [HttpGet()]
    public bool check()
    {
        return true;
    }

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

    [HttpPost("PostFund")]
    public async Task<ActionResult<Account>> PostFund(Fund fund)
    {

        var a = await _context.Funds.FindAsync(fund.Id);
        if (a != null) return BadRequest($"Fund already exists with Id: {fund.Id}");        

        var user = await _context.Users.Include(u => u.Funds).FirstOrDefaultAsync(u => u.Id == fund.UserId);
        if (user == null) return NotFound($"User does not exist with Id: {fund.UserId}");

        _context.Funds.Add(fund);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetFund), new { Id = fund.Id }, fund);
    }

    [HttpPut("{Id}")]
    public async Task<IActionResult> PutFund(int Id, Fund fund)
    {
        if (Id != fund.Id) return BadRequest($"Id: {Id} parameter doesn't equal fund.Id: {fund.Id}");        

        if (!FundExists(Id)) return NotFound($"No fund found to update with Id: {fund.Id}");

        var u = await _context.Users.FindAsync(fund.UserId);
        if (u == null) return NotFound($"User does not exist with Id: {fund.UserId}");
        
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