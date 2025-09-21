using App.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace App.Controllers;

[ApiController]
[Route("api/[controller]")]

public class TransactionsContoller : ControllerBase
{
    [HttpGet("check")]
    public bool check()
    {
        return true;
    }
}