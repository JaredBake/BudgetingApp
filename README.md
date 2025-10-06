CS4400 Group 8: Budgeting app

This Repository holds in progress development on a Continuous budgeting app, which will allow users to have a better understanding of their finances without the traditional constraint of monthly or periodic time windows.
It uses a flutter front end, a containerized asp.net backend, and PostgreSQL as a database component.

Installation and running:
Option 1: Compile from source
This is the current best method for installation as the docker compose is not yet production ready. You will need to install the following dependencies:
-Flutter, make sure that it is available on your PATH
-.Net 9.0 SDK
-PostGreSQL
You will also need to set the following Environment variables, with a .ENV file in the directory of the asp.net application:
TODO: add necessary env variables here

Options 2: Docker Compose (WARNING: Docker compose installation is not yet ready, and may have issues)
This is the intended long term solution to allow people to easily self host the application. 
The only dependency for this installation is Docker, follow instructions here to install for your system: https://www.docker.com/products/docker-desktop/
After cloning the repo, simply navigate to the root directory in a terminal and run "docker compose up". The application should be accessible on port 8080 of your machine 


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
S2: Jared Bake
S3: Santos Laprida
S4: Shawn Crook

Github Link: https://github.com/JaredBake/BudgetingApp
