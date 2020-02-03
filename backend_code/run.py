from flask import Flask, request, redirect, session, jsonify, render_template
from models import Base, User, Question
import re
import json
import sys
import ast
from sqlalchemy import func
from flask_sqlalchemy import SQLAlchemy
from models import Question, User
from flask.ext.httpauth import HTTPBasicAuth
import datetime

###########################################################################
# Set up database
###########################################################################
app =  Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres://qnzlvjypalnabz:LMkfLA8rHNVojAP5et6kLWzQtI@'\
    'ec2-184-73-221-47.compute-1.amazonaws.com:5432/da5kf1gau76p71'
db = SQLAlchemy(app)

###########################################################################
# Require authorization
###########################################################################
auth = HTTPBasicAuth()
@auth.get_password
def get_password(username):
    if username == '~MrG<.Lgz9}sBQL':
        return 'mcn^S4R4J`3v-(V5'
    return None

@auth.error_handler
def unauthorized():
    return 'Unauthorized Access'


###########################################################################
# Place holders
###########################################################################
@app.route('/')
# @auth.login_required
def index():
    return 'index'

# Handle questions
@app.route("/questions", methods=['GET','POST'])
# @auth.login_required
def questions():
    return 'Questions Home'

# Handle users
@app.route("/users", methods=['GET','POST'])
# @auth.login_required
def users():
    return 'Users Home'

###########################################################################
# Add new user
###########################################################################
@app.route("/users/new", methods=['GET'])
# @auth.login_required
def new_user():

    cell = request.args.get('number')
    if cell is None:
        return 'No Number Provided'

    # See if user has registered, register if not
    number = db.session.query(User).filter_by(cell_number=cell).scalar()
    if number is None:
        newuser = User(
        cell_number=cell
        )
        db.session.add(newuser)
        db.session.commit()
        return str(newuser.id)
    else:
        return 'Already Registered'


###########################################################################
# Request all users
###########################################################################
@app.route("/users/get_all", methods=['GET'])
# @auth.login_required
def get_all_users():
    all_users = db.session.query(User).all()
    s = []
    for u in all_users:
        s.append(u.serialize())
    return json.dumps(s, sort_keys=True, indent=4)

###########################################################################
# Request all info about a user
###########################################################################
@app.route("/users/get", methods=['GET'])
# @auth.login_required
def get_user():
    uid = request.args.get('id')
    number = request.args.get('number')
    if number is None and uid is None:
        return "No Number or Id Provided"
    
    if number is None:
        user = db.session.query(User).get(int(uid))
    else:
        user = db.session.query(User).filter_by(cell_number=number).scalar()
    if user is None:
        return "This User does not exist"

    return repr(user)


###########################################################################
# post a new question
###########################################################################
@app.route("/questions/new", methods=['GET'])
# @auth.login_required
def new_question():

    #error checking
    u_id = request.args.get('user')
    if u_id is None:
        return 'need user id'
    user_entry = db.session.query(User).get(u_id)
    if user_entry is None:
        return 'need registered user id'
    new_category = request.args.get('category')
    if new_category is None:
        return 'need category'
    all_answers = request.args.get('answers')
    if all_answers is None:
        return 'need answers'
    question_text = request.args.get('question')
    if question_text is None:
        return 'need question text'
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    if lat is None or lng is None:
        return 'need lat and lng'

    #location
    new_lat = float(lat)
    new_lng = float(lng)

    #user
    u_id = int(u_id)

    #answers
    ans_in = all_answers.split(',')
    num_answers = len(ans_in)
    ans_new = [dict() for x in range(num_answers)]
    for i in range(0,num_answers):
        ans_new[i]["text"] = ans_in[i]
        ans_new[i]["numvotes"] = 0    

    #update question database
    new_question = Question(
        asker=u_id,
        question=question_text,
        answers=json.dumps(ans_new),
        category=new_category,
        lat=new_lat,
        lng=new_lng
        )
    db.session.add(new_question)
    db.session.commit()

    #update user database
    serial = new_question.serialize()
    asked_questions = json.loads(user_entry.askQuest)
    asked_questions.append(new_question.serialize()['id'])
    user_entry.askQuest = json.dumps(asked_questions)
    db.session.commit()

    #return
    return 'success'

###########################################################################
# get user asked questions
###########################################################################
@app.route("/questions/get_user_asked", methods=['GET'])
# @auth.login_required
def get_user_asked():
    uid= request.args.get('user')
    if uid is None:
        return 'need user id'
    uid = int(uid)
    user = db.session.query(User).get(uid)
    asked = json.loads(user.askQuest)
    s = []
    for a in asked:
        question = db.session.query(Question).get(a)
        s.append(question.serialize())
    
    sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
    return json.dumps(sorted_questions, sort_keys=True, indent=4)

###########################################################################
# get user answered questions
###########################################################################
@app.route("/questions/get_user_answered", methods=['GET'])
# @auth.login_required
def get_user_answered():
    uid= request.args.get('user')
    if uid is None:
        return 'need user id'
    uid = int(uid)
    user = db.session.query(User).get(uid)
    answered = json.loads(user.ansQuest)
    s = []
    for a in answered:
        question = db.session.query(Question).get(a)
        s.append(question.serialize())

    sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
    return json.dumps(sorted_questions, sort_keys=True, indent=4)

###########################################################################
# get all questions
###########################################################################
## Currently set to return all question less than 2 WEEKS old. CHANGE AFTER GRADED

@app.route("/questions/get_all", methods=['GET'])
# @auth.login_required
def get_questions():

    #location
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)

    #filter by location or not
    if lat is None or lng is None:
        valid_questions = db.session.query(Question)
    else:
        lat = float(lat)
        lng = float(lng)
        valid_questions = db.session.query(Question).filter(
            Question.within(lat,lng,32000)
        )

    #filter by time
    valid_questions = valid_questions.filter(
        Question.datetime > (datetime.datetime.utcnow() -
                             datetime.timedelta(days=30)) )

    #filter by category
    category = request.args.get('category')

    if category:
        valid_questions = valid_questions.filter(
            func.lower(Question.category) == func.lower(category) )

    #serialize
    s = []
    for q in valid_questions:
        s.append(q.serialize())

    #sort
    if request.args.get('sort') == 'hot':
        sorted_questions = sorted(s, key=lambda user:(user['total_votes']), reverse=True)
    else:
        sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)

    #return
    return json.dumps(sorted_questions, sort_keys=True, indent=4)


###########################################################################
# get all information about a specific question
###########################################################################
@app.route("/questions/get", methods=['GET'])
# @auth.login_required
def get_question():
    q_id = request.args.get('question_id')
    if q_id is None :
        return "None"
    question = db.session.query(Question).get(q_id)
    if(question != None):
        return repr(question)
    else:
        return "None"

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
    print "USERS"
    users = db.session.query(User).all()
    for user in users:
        print user

    print " "
    print "QUESTIONS"

    questions = db.session.query(Question).all()
    for question in questions:
        print question

if __name__ == "__main__":
    app.run(debug=True)
