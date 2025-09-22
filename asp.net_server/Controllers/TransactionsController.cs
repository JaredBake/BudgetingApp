using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]

public class TransactionsController : ControllerBase
{
    private readonly BudgetDbContext _context;
    public TransactionsController(BudgetDbContext context)
    {
        _context = context;
    }

    [HttpGet()]
    public bool check()
    {
        return true;
    }

    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<Transaction>>> GetUsers()
    {
        return await _context.Transactions.ToListAsync();
    }
}