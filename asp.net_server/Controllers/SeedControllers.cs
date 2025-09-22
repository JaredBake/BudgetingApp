// using App.Services;
// using Microsoft.AspNetCore.Mvc;

// namespace App.Controllers
// {
//     [ApiController]
//     [Route("api/[controller]")]
//     public class SeedController : ControllerBase
//     {
//         private readonly DatabaseSeeder _seeder;

//         public SeedController(DatabaseSeeder seeder)
//         {
//             _seeder = seeder;
//         }

//          [HttpGet("check")]
//         public bool check()
//         {
//             return true;
//         }

//         [HttpPost]
//         public async Task<IActionResult> Seed()
//         {
//             try
//             {
//                 await _seeder.SeedAsync();
//                 return Ok("Database seeded with fake data.");
//             }
//             catch (Exception ex)
//             {
//                 return StatusCode(500, $"Seeding failed: {ex.Message}");
//             }
//         }
//     }
// }
