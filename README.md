CS4400 Group 8: Budgeting app

This Repository holds in progress development on a Continuous budgeting app, which will allow users to have a better understanding of their finances without the traditional constraint of monthly or periodic time windows.
It uses a flutter front end, a containerized asp.net backend, and PostgreSQL as a database component.

Installation and running:
Option 1: Compile from source
This is the current best method for installation as the docker compose is not yet production ready. You will need to install the following dependencies:
-Flutter, make sure that it is available on your PATH
-.Net 9.0 SDK
-PostGreSQL

Options 2: Docker Compose (WARNING: Docker compose installation is not yet ready, and may have issues)
This is the intended long term solution to allow people to easily self host the application. 
The only dependency for this installation is Docker, follow instructions here to install for your system: https://www.docker.com/products/docker-desktop/
After cloning the repo, simply navigate to the root directory in a terminal and run "docker compose up". The application should be accessible on port 8080 of your machine.

Using the app:
Once you have the service running, you should see a welcome page asking you to log in or register. Click Register,
and then fill in required info (username, password, name).
You will then be taken to a home screen. To add an account, go to accounts and then press the (+) button. Once you have an account, you will be able to add transactions. Each time you buy something or recieve income, record it creating a transaction, and the app will be able to start recording your spending.


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
