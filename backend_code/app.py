from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

def create_app():
    app =  Flask(__name__)

    # Set up the app and sqlalchemy
    app.config.from_object(os.environ['APP_SETTINGS'])
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    return app

app = create_app()
db = SQLAlchemy(app)

from routes.users import user_api
from routes.questions import question_api
from routes.others import other_api

app.register_blueprint(user_api, url_prefix='/users')
app.register_blueprint(question_api, url_prefix='/questions')
app.register_blueprint(other_api, url_prefix='/')

if __name__ == "__main__":
    app.run()
