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
}