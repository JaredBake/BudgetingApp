using App.Models;
using Microsoft.EntityFrameworkCore;

string allowCORs = "_AllowSpecificOrigins";

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddDbContext<BudgetDbContext>(options => 
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddCors(o => o.AddPolicy(
    allowCORs, builder =>
    {
        builder.WithOrigins("http://localhost:8000") //Update with correct port number of front-end
            .AllowAnyHeader()
            .AllowAnyMethod();
    })
);

var app = builder.Build();

app.MapGet("/test", () =>
{
    return true;
});

// app.UseHttpsRedirection();
app.UseCors(allowCORs);
app.UseRouting();
app.UseAuthorization();
app.MapControllers();
app.Run();

namespace App
{
    
}