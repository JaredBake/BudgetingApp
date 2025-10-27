CS4400 Group 8: Budgeting app

This Repository holds in progress development on a Continuous budgeting app, which will allow users to have a better understanding of their finances without the traditional constraint of monthly or periodic time windows.
It uses a flutter front end, a containerized asp.net backend, and PostgreSQL as a database component.


###
Installation and running:

Option 1: Compile from Source (Recommended)
This is currently the most stable method.

Dependencies
Make sure the following tools are installed and available on your system:
Flutter
 (add to your PATH)
.NET 9.0 SDK
PostgreSQL

###
Backend Configuration

Create a .env file inside the ASP.NET project directory.
Add the following environment variables (adjust as needed):

DB_HOST=localhost
DB_PORT=5432
DB_NAME=budget
DB_USER=postgres
DB_PASSWORD=1234

JWT_SECRET_KEY=67821ded0cf07a4f1cbc654033ec53a8
LOCALHOST_PORT=8000

API_KEY=

###
Run database migrations:
dotnet ef database update

###
Start the backend:
Make sure you are inside the asp.net_server directory
dotnet run

###
Start the frontend:
Make sure you are inside the flutter_app directory
flutter run

The app should be available at http://localhost:8080


#Team Organization:
Team Members:
Caleb Terry
Jared Bake
Santos Laprida
Shawn Crook

Meeting Schedule:
Monday  @10AM
Thursday @12PM (w/ Professor)
Saturday @10AM

Team Leader Rotation
S1: Caleb Terry
S2: Santos Laprida
S3: Jared Bake
S4: Shawn Crook

Github Link: https://github.com/JaredBake/BudgetingApp
