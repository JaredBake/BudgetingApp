# BudgetingApp
Budgeting App project for CS 4400, built with Jared Bake, Caleb Terry, Shawn Crook, Santos Laprida













## Dev - Routes
`GET:localhost:5284/test` - Test your connection to the server. Should return `true`

`GET:localhost:5284/api/Users/` - Test that the User Controller is reading properly. Should return `true`

`POST:localhost:5284/api/database/migrate` - Shouldn't be necessary, but migrates the database schema based on the newest migration. 

`POST:localhost:5284/api/Seed/` - Deletes and recreates entire database with basic fake data. Should return `Database seeded with fake data.`


### User Routes
`GET:localhost:5284/api/Users/GetAll` 
Returns an array with all the users formatted in JSON objects. Accounts populate properly as well as each accounts transactions

`GET:localhost:5284/api/Users/{id}`
Returns a signle JSON object with the specific user formatted in JSON. All accounts populate properly with all of each accounts transactions

Example: 
`{
	"id": 20001,
	"createdAt": "0001-01-01T00:00:00",
	"userName": "testDummy",
	"name": "Shawn Crook,",
	"password": "password123",
	"email": "test@gmail.com",
	"accounts": null,
	"funds": null
}`


