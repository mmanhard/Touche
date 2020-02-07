from flask import Flask, request, redirect, session, jsonify, render_template
from models import Base, User, Question
import re
import json
import sys
import ast
from sqlalchemy import func
from flask_sqlalchemy import SQLAlchemy
from models import Question, User
from routes.users import user_api
from routes.questions import question_api
#from questions import question_api
# from flask.ext.httpauth import HTTPBasicAuth
import datetime

###########################################################################
# Set up database
###########################################################################
app =  Flask(__name__)
# db_string = 'postgres://qnzlvjypalnabz:LMkfLA8rHNVojAP5et6kLWzQtI@ec2-184-73-221-47.compute-1.amazonaws.com:5432/da5kf1gau76p71'
db_string = 'postgresql://localhost/testData'
app.config['SQLALCHEMY_DATABASE_URI'] = db_string
db = SQLAlchemy(app)

###########################################################################
# Set up routes
###########################################################################
app.register_blueprint(user_api, url_prefix='/users')
app.register_blueprint(question_api, url_prefix='/questions')

###########################################################################
# Require authorization
###########################################################################
# auth = HTTPBasicAuth()
# @auth.get_password
# def get_password(username):
#     if username == '~MrG<.Lgz9}sBQL':
#         return 'mcn^S4R4J`3v-(V5'
#     return None
#
# @auth.error_handler
# def unauthorized():
#     return 'Unauthorized Access'


###########################################################################
# Place holders
###########################################################################
@app.route('/')
# @auth.login_required
def index():
    return 'index'

###########################################################################
# vote on a new question
###########################################################################
@app.route("/vote", methods=['GET'])
# @auth.login_required
def vote():
    # check fields
    u_id = request.args.get('user_id')
    q_id = request.args.get('question_id')
    a_id = request.args.get('answer_id')
    if u_id is None or q_id is None or a_id is None :
        return "need to supply all id's"

    # check database
    u_id = int(u_id)
    q_id = int(q_id)
    a_id = int(a_id)
    question = db.session.query(Question).get(q_id)
    user = db.session.query(User).get(u_id)
    if question is None:
        return "question doesn't exist"
    if user is None:
        return "user doesn't exist"

    #error check
    responders = json.loads(question.responders)
    if u_id in responders:
        return "user already responded"
    answers = json.loads(question.answers)
    if a_id >= len(answers):
        return "answer id not legitimate"

    #update total_votes
    question.total_votes += 1

    #update responders
    responders.append(u_id)
    question.responders = json.dumps(responders)

    #update answer
    answers[a_id]['numvotes'] += 1
    question.answers = json.dumps(answers)

    #put into user table
    ans_quest = json.loads(user.ansQuest)
    ans_quest[str(q_id)] = a_id
    user.ansQuest = json.dumps(ans_quest)

    #commit
    db.session.commit()
    return "success"


###########################################################################
# Setup data base (clearing anything in a previous instance)
# FIGURE OUT HOW TO DO THIS WITHOUT CLEARING
###########################################################################
def setup():

    # Recreate database each launch
    Base.metadata.drop_all(bind=db.engine)
    Base.metadata.create_all(bind=db.engine)

# Print the contents of both datbases
def check():
    print("USERS")
    users = db.session.query(User).all()
    for user in users:
        print(user)

    print(" ")
    print("QUESTIONS")

    questions = db.session.query(Question).all()
    for question in questions:
        print(question)

if __name__ == "__main__":
    app.run(debug=True)
