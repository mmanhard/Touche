from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# db_string = 'postgres://qnzlvjypalnabz:LMkfLA8rHNVojAP5et6kLWzQtI@ec2-184-73-221-47.compute-1.amazonaws.com:5432/da5kf1gau76p71'
db_string = 'postgresql://localhost/testData'

def create_app(db_string):
    app =  Flask(__name__)

    # Set up database
    app.config['SQLALCHEMY_DATABASE_URI'] = db_string
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    return app

app = create_app(db_string)
db = SQLAlchemy(app)

from models import Base, User, Question
from routes.users import user_api
from routes.questions import question_api
from routes.others import other_api

app.register_blueprint(user_api, url_prefix='/users')
app.register_blueprint(question_api, url_prefix='/questions')
app.register_blueprint(other_api, url_prefix='/')

if __name__ == "__main__":
    app.run(debug=True)
