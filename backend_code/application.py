from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from routes.users import user_api
from routes.questions import question_api
from routes.others import other_api
from database import db


def create_app(db_string):
    app =  Flask(__name__)

    # Set up database
    app.config['SQLALCHEMY_DATABASE_URI'] = db_string
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)

    # Set up routes
    app.register_blueprint(user_api, url_prefix='/users')
    app.register_blueprint(question_api, url_prefix='/questions')
    app.register_blueprint(other_api, url_prefix='/')

    return app
