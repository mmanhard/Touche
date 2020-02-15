from flask import Blueprint, request, redirect, session, jsonify, render_template
from models import Base, User, Question
from sqlalchemy import func
import json
from app import app, db
import datetime

question_api = Blueprint('question_api', __name__)
app.register_blueprint(question_api, url_prefix='/questions')

###########################################################################
# Show all questions
###########################################################################
@question_api.route("/", methods=['GET'])
# @auth.login_required
def index():
    #location
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)

    #filter by location or not
    if lat is None or lng is None:
        return 'need lat and lng'
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
# Create a new question
###########################################################################
@question_api.route("/", methods=['POST'])
# @auth.login_required
def create_new_question():
    #error checking
    u_id = request.form['user']
    if u_id is None:
        return 'need user id'
    user_entry = db.session.query(User).get(u_id)
    if user_entry is None:
        return 'need registered user id'
    new_category = request.form['category']
    if new_category is None:
        return 'need category'
    all_answers = request.form['answers']
    if all_answers is None:
        return 'need answers'
    question_text = request.form['question']
    if question_text is None:
        return 'need question text'
    lat = request.form['lat']
    lng = request.form['lng']
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
# Show all information about a specific question
###########################################################################
@question_api.route("/<q_id>", methods=['GET'])
# @auth.login_required
def show_question_by_id(q_id):
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
@question_api.route("/<q_id>/vote", methods=['PATCH'])
# @auth.login_required
def vote(q_id):
    # check fields
    u_id = request.form['user_id']
    a_id = request.form['answer_id']
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
# DEPRECATED METHODS
###########################################################################
# @question_api.route("/get_user_asked", methods=['GET'])
# @question_api.route("/get_user_answered", methods=['GET'])
