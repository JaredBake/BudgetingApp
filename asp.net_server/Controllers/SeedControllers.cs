using App.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace App.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/[controller]")]
    public class SeedController : ControllerBase
    {
        private readonly DatabaseSeeder _seeder;

        public SeedController(DatabaseSeeder seeder)
        {
            _seeder = seeder;
        }

        [AllowAnonymous]
        [HttpGet()]
        public bool check() { return true; }

        [HttpGet("auth")]

        [HttpPost]
        public async Task<IActionResult> Seed()
        {
            try
            {
                await _seeder.SeedAsync();
                return Ok("Database seeded with fake data.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Seeding failed: {ex.Message}");
            }
        }
    }
}
