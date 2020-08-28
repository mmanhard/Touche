# Touché

Touché is an iOS application that helps users settle debates over subjective topics.

Ever been at dinner with friends and someone asks, "Are hot dogs sandwiches, tacos, or something else entirely?". Google doesn't have an answer for that, so that's where Touché comes in. Users type in a question, get votes from people around them, and eventually prove to their friends that they were right. Touché.

## Live Version

The backend of the application is hosted on Heroku and can be found [here](https://touche-backend.herokuapp.com/). Unfortunately, the frontend is not available on the Apple App Store.

## Tech Stack

Front-End: Swift

Back-End: Flask + Python + PostgreSQL

## Setup and Usage - Frontend

The easiest way to test and build the frontend is with Xcode. 

##### 1. Open the project:

After cloning this repo onto your machine, navigate to the directory containing the source code. Open the Xcode project with:

```
cd frontend_code
open Touche.xcodeproj
```

##### 2. Choose the correct scheme:

In Xcode, make sure the **Touche** scheme is selected (up in the top-left corner of Xcode). 

##### 3. Set up the backend:

You have (3) options:

1. Use the live version of the backend hosted on Heroku. The URL for this option is `https://touche-backend.herokuapp.com/`. Feel free to use this option as this application is hosted for demonstration purposes only.
2. Run the backend locally. Follow (these steps)[https://github.com/mmanhard/Touche#local-setup-and-usage---backend] to do so. If you used the default port, the URL will be `http://localhost:5000`.
3. Host your own version of the backend on Heroku. Follow (these steps)[https://github.com/mmanhard/Touche#deployment---backend] to do so. Heroku will let you know the URL of your backend application.

Next, you'll need to configure the frontend to connect to the appropriate backend.  To do so, change the host in `Touche/Application/AppConstants.swift` to the URL of your backend. NOTE: You won't need to change this if using option (1).

##### 4. Build and Run

Build and run the code by pressing the play button. The application should open up in the Simulator.

**NOTE**: This application was tested using Xcode Version 11.3.1. Older versions may have issues building the application.

## Local Setup and Usage - Backend

After cloning this repo onto your machine, navigate to the directory containing the source code. From there, navigate into the `backend_code` directory (`cd backend_code`).

##### 1. Set up the virtual environment:

```
$ python3 -m venv venv
$ source venv/bin/activate
$ pip3 install -r requirements.txt
```

This will create a virtual environment for managing package dependencies.

**NOTE**: You may have trouble installing `psycopg2` . If so, run `pip3 install psycopg2-binary`.

##### 2. Configure the app:

```
export FLASK_APP=app
export FLASK_ENV=development
export APP_SETTINGS="config.DevelopmentConfig"
```

##### 3. Set up the database:

```
$ psql
    # CREATE DATABASE <DATABASE_NAME>;
    # \q
    $ export DATABASE_URL='postgresql://<pg_user>:<pg_pwd>@localhost:5432/<DATABASE_NAME>' 
$ python3 manage.py db upgrade
$ python3 manage.py add_earth_ext
```
Where `<DATABASE_NAME>` is the name you have selected for the database and`<pg_user>` and `<pg_pwd>` are the username and password, respectively, for the PostgreSQL server you are using. 

**NOTE**: If you don't require a password to access PostgreSQL, you can just set `DATABASE_URL` equal to `postgresql:///<DATABASE_NAME>`.

##### 4. Run the app:

```
$ flask run
```

## Deployment - Backend

The live version is hosted on Heroku.

You can host your own forked version by following the steps below from the directory where your local repo is located:

##### 1. Login in to Heroku and create a new Heroku app using the Heroku CLI:

```
$ heroku login
$ heroku create
```

##### 2. Configure the app for production:

```
$ heroku config:set APP_SETTINGS=config.ProductionConfig
```

##### 3. Push all files from the `backend_code` directory only:

```
$ heroku git:remote -a <APP_NAME>
$ git subtree push --prefix backend_code heroku master
```
Where `<APP_NAME>` is the name you have selected for your backend application.

After pushing changes, Heroku will automatically build the production version of the app and run it. However, you still need to set up the database tables.

##### 4. Set up the database:

```
$ heroku run python manage.py db upgrade --app <APP_NAME>
$ heroku run python3 manage.py add_earth_ext --app <APP_NAME>
```
