# Touché

Touché is an iOS application that helps users settle debates over subjective
topics.

Ever been at dinner with friends and someone asks, "Are hot dogs sandwiches,
tacos, or something else entirely?". Google doesn't have an answer for that,
so that's where Touché comes in. Users type in a question, get votes from people
around them, and eventually prove to their friends that they were right. Touché.

## Live Version

The back-end of the application is hosted on Heroku and can be found
[here](https://touche-back-end.herokuapp.com/).

Unfortunately, the front-end is not available on the Apple App Store.

#### Test Account

There is a test account that has already posted and answered a number of questions.
If you would like to use this account to play around with the app, feel free. The
credentials are as follows:

&nbsp;&nbsp;&nbsp;&nbsp;**Username:** toucheTest
&nbsp;&nbsp;&nbsp;&nbsp;**Password:** password1234

## Tech Stack

Front-End: Swift

Back-End: Flask + Python + PostgreSQL

## Setup and Usage - Front-End

#### Requirements

* `XCode` >= v11.3.1
* `Swift` >= v5.1.3

The easiest way to test and build the front-end is with Xcode.

##### 1. Open the project:

After cloning this repo, navigate to the directory containing the cloned repo.
Open the Xcode project with:

```
$ cd frontend_code
$ open Touche.xcodeproj
```

##### 2. Choose the correct scheme:

In Xcode, make sure the **Touche** scheme is selected (up in the top-left corner
of Xcode).

##### 3. Set up the back-end:

You have (3) options:

1. Use the live version of the back-end hosted on Heroku. Feel free to use this
as the app is hosted for demonstration purposes only. The URL for this option is
`https://touche-back-end.herokuapp.com/`.
2. Run the back-end locally with [these steps](https://github.com/mmanhard/Touche#local-setup-and-usage---back-end).
If you used the default port, the URL will be `http://127.0.0.1:5000/`. **NOTE**:
The iOS simulator may have issues connecting if you use `localhost` instead of
your localhost's IP address (typically `127.0.0.1`).
3. Host your own version of the back-end on Heroku using [these steps](https://github.com/mmanhard/Touche#deployment---back-end).
Heroku will let you know the URL of your back-end application.

Next, change the variable `host` in `Touche/Application/AppConstants.swift` to
the URL of your back-end. This will let the front-end know where to make HTTP
requests. NOTE: You won't need to change this if using option (1).

##### 4. Build and Run

Build and run the code by pressing the play button in the top-left corner of
Xcode. The application should open up in the Simulator.

## Local Setup and Usage - Back-End

#### Requirements

* `pip3` >= v19.0.3
* `PostgreSQL` >= v12.4
* `python` >= v3.7.4

After cloning this repo, navigate to the directory containing the cloned repo.
From there, follow the steps below:

##### 1. Set up the virtual environment:

```
$ cd backend_code
$ python3 -m venv venv
$ source venv/bin/activate
$ pip3 install -r requirements.txt
```

This will create a virtual environment for managing package dependencies.

**NOTE**: You may have trouble installing `psycopg2`. If so, run
`pip3 install psycopg2-binary` instead.

##### 2. Configure the app:

```
$ export FLASK_APP=app
$ export FLASK_ENV=development
$ export APP_SETTINGS="config.DevelopmentConfig"
```

##### 3. Set up the database:

```
$ psql
    # CREATE DATABASE <DATABASE_NAME>;
    # \c <DATABASE_NAME>
    # CREATE EXTENSION IF NOT EXISTS cube;
    # CREATE EXTENSION IF NOT EXISTS earthdistance;
    # \q
```

#### 4. Connect the database to the app:

```
$ export DATABASE_URL='postgresql://<pg_user>:<pg_pwd>@localhost:5432/<DATABASE_NAME>'
$ python3 manage.py db upgrade
```
Where `<DATABASE_NAME>` is the name you have selected for the database and
`<pg_user>` and `<pg_pwd>` are the username and password, respectively, for the
PostgreSQL server you are using.

**NOTE**: If you don't require a password to access PostgreSQL, you can just set
`DATABASE_URL` equal to `postgresql:///<DATABASE_NAME>`.

##### 4. Run the app:

```
$ flask run
```

By default, the flask development server will listen on port **5000**. If you need
to use a different one, append `-p <PORT_NUM>`, where `<PORT_NUM>` is the desired port
number, to `flask run`.

## Deployment - Back-End

#### Requirements

* `heroku CLI` >= 7.42.11

The live version is hosted on Heroku.

You can host your own forked version by following the steps below from the
directory where your local repo is located:

##### 1. Login in to Heroku and create a new Heroku app using the Heroku CLI:

```
$ heroku login
$ heroku create <APP_NAME>
```

Where `<APP_NAME>` is the name you have selected for your back-end application.

##### 2. Configure the app for production:

```
$ heroku config:set APP_SETTINGS=config.ProductionConfig -a <APP_NAME>
```

##### 3. Push all files from the `backend_code` directory only:

Make sure you complete the following from the top-level directory of this repo.

```
$ heroku git:remote -a <APP_NAME>
$ git add .
$ git commit -am "Enter a nice commit message here!"
$ git subtree push --prefix backend_code heroku master
```

After pushing changes, Heroku will automatically build the production version of
the app and run it. However, you still need to set up the database tables.

##### 4. Set up the database:

```
$ heroku run python manage.py db upgrade -a <APP_NAME>
$ heroku run python manage.py add_earth_ext -a <APP_NAME>
```
