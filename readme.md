# Touché


## Installation and Usage - Backend

#### Running Locally

After cloning this repo onto your machine, navigate to the directory containing the source code. From there, navigate into the `backend_code` directory (`cd backend_code`).

1. Set up the virtual environment:

```
$ python3 -m venv venv
$ source venv/bin/activate
$ pip3 install -r requirements.txt
```

This will create a virtual environment for managing package dependencies.

Occassionally, `psycopg2` may have trouble installing. If so, run `pip3 install psycopg2-binary`.

2. Configure the app:

```
export FLASK_APP=app
export FLASK_ENV=development
export APP_SETTINGS="config.DevelopmentConfig"
```

3. Set up the database:

```
$ psql
    # CREATE DATABASE <DATABASE_NAME>;
    # \q
$ python3 manage.py db upgrade
$ export DATABASE_URL="postgresql:///<DATABASE_NAME>“
```

Where `<DATABASE_NAME>` is the name you have selected for the database.

4. Run the app:

```
$ flask run
```

## Deployment - Backend

The live version is hosted on Heroku.

You can host your own forked version by following the steps below from the directory where your local repo is located:

1. Login in to Heroku and create a new Heroku app using the Heroku CLI:

```
$ heroku login
$ heroku create
```

2.. Configure the app for production:

```
heroku config:set APP_SETTINGS=config.ProductionConfig
```

3. Push all files from the `backend_code` directory only:

```
heroku git:remote -a <APP_NAME>
git subtree push --prefix backend_code heroku master
```

After pushing changes, Heroku will automatically build the production version of the app and run it. However, you still need to set up the database tables.

4. Set up the database:

```
heroku run python manage.py db upgrade --app <APP_NAME>
```
