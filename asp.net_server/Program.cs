using App.Models;
using Microsoft.EntityFrameworkCore;
using DotNetEnv;
using App.Services;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

string allowCORs = "_AllowSpecificOrigins";

var builder = WebApplication.CreateBuilder(args);

Env.Load();

var connectionString = $"Host={Environment.GetEnvironmentVariable("DB_HOST")};" +
                       $"Database={Environment.GetEnvironmentVariable("DB_NAME")};" +
                       $"Username={Environment.GetEnvironmentVariable("DB_USER")};" +
                       $"Password={Environment.GetEnvironmentVariable("DB_PASSWORD")};" +
                       $"Port={Environment.GetEnvironmentVariable("DB_PORT")}";

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
            options.JsonSerializerOptions.WriteIndented = true;
        }
    );

builder.Services.AddDbContext<BudgetDbContext>(options => 
    options.UseNpgsql(connectionString));


var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") ?? throw new InvalidOperationException("JWT SecretKey not configured");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration.GetSection("JwtSettings")["Issuer"],
        ValidAudience = builder.Configuration.GetSection("JwtSettings")["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();


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
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();

namespace App
{
    
}