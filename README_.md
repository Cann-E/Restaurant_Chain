**Chain of Restraunts**

This repository contains the contents of a Project that contains a database that is supposed to hold a
chain of restraunts. It will have tables that include the payments for orders, frequent customers as well as the locations for restraunts.
Criteria from prompt
A chain of restaurants: food kind Asian, diverse food/beverage items. Consider payment info, package meals, tax, tips, restaurant location. Customers with/without loyalty (membership) card. Ability to pay with card or cash. Basic bank account information.
Project Overview
Key files included:

index.js: Main server file that runs the website
schema.sql: Creates and populates our database tables
.env: Configuration for database connection
public/: Contains our website files

The website demonstrates:

Menu item display
Customer management
Restaurant location tracking

Technical Requirements

Node.js
PostgreSQL
npm (comes with Node.js)

** For those who are grading our assignment **
Thank you for taking the time to look and assess our assignment, if you have any issues please contact us on discord!

First things first, we need to understand the prerequisite software that we are using to set up the assignment. We are using Node as a framework for our website.
** NOTE if you do not have node downloaded here is the link to download it: https://nodejs.org/ **
Using commands that come downloaded with node, double check to see if you have the dependencies downloaded within our folder/directory (we should already have them in the folder):
Copynpm install

Since we have a database dump here is the commands to import it: 
createdb Restaurant
psql Restaurant < Restaurant_V16.sql

Now look at our .env file. It should have a template like this:
DATABASE_URL=postgresql://username:password@localhost:5432/Restaurant
PORT=3000
Adjust the Username to your own username to your postresql on your personal machine. As well as the Password for your postresql.
Please note the port that is used.

We have inluded a .sql file named schema.sql (this does not include our full database but it creates the neccary tables needed for our transactions aswell as populating the database)
What you will need to do is create a server called Restaurant on postresql and then right click to select query tool to then copy from the sql file to then paste into the query to
then run it.

🎈Congratulations you have created our database🎈
Now we are hitting the home stretch type node index.js  into the terminal or command panel and you will activate our website on:
🌟 http://localhost:3000 🌟
Once we have the website up and running, you'll see our homepage with several navigation options:

Users Profile Management - For managing customer accounts and memberships

Menu - Browse our menu items and their pricing

Place Order - Order food for pickup or delivery

Transactions - View order history and payment records

Dashboard - Access analytics and reports

Locations - View our restaurant franchise locations

While the interface is simple, it demonstrates core database functionality including customer management, order processing, and multi-location restaurant operations. Each section shows different ways we've implemented database queries and data management. 🫡

Again we are available if there are any issues regarding setting up or just questions with the website if not contacted originally from one of our teammates contact, ww2geek101 for any questions thank you!

