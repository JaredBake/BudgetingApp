using App.Models;
using Microsoft.EntityFrameworkCore;
using DotNetEnv;
using App.Services;

string allowCORs = "_AllowSpecificOrigins";

var builder = WebApplication.CreateBuilder(args);

Env.Load();

var connectionString = $"Host={Environment.GetEnvironmentVariable("DB_HOST")};" +
                       $"Database={Environment.GetEnvironmentVariable("DB_NAME")};" +
                       $"Username={Environment.GetEnvironmentVariable("DB_USER")};" +
                       $"Password={Environment.GetEnvironmentVariable("DB_PASSWORD")};" +
                       $"Port={Environment.GetEnvironmentVariable("DB_PORT")}";

builder.Services.AddControllers();

builder.Services.AddDbContext<BudgetDbContext>(options => 
    options.UseNpgsql(connectionString));


var localHostString = $"http://localhost:{Environment.GetEnvironmentVariable("LOCALHOST_PORT")}";

builder.Services.AddCors(o => o.AddPolicy(
    allowCORs, builder =>
    {
        builder.WithOrigins(localHostString) 
            .AllowAnyHeader()
            .AllowAnyMethod();
    })
);

builder.Services.AddScoped<DatabaseSeeder>();

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