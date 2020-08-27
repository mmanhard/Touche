from flask import Blueprint, request, redirect, session, jsonify, render_template, make_response
from sqlalchemy import func
import json
import datetime

from models import Base, User, Question
from app import app, db
from auth import auth_required

# Constant (5000m) used to filter out questions that are farther than
# 5km from requested latitude and longitude
max_distance_filter = 5000

question_api = Blueprint('question_api', __name__)

###########################################################################
# Show all questions
###########################################################################
@question_api.route("/", methods=['GET'])
@auth_required
def index():
    #location
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)

    #filter by location or not
    if lat is None or lng is None:
        return make_response('Need location', 400)
    else:
        lat = float(lat)
        lng = float(lng)
        valid_questions = db.session.query(Question).filter(
            Question.within(lat,lng,max_distance_filter)
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

    return make_response(json.dumps(sorted_questions, sort_keys=True, indent=4), 200)

###########################################################################
# Create a new question
###########################################################################
@question_api.route("/", methods=['POST'])
@auth_required
def create_new_question():
    #error checking
    u_id = request.form['user']
    if u_id is None:
        return make_response("No user id provided", 400)
    user_entry = db.session.query(User).get(u_id)
    if user_entry is None:
        return make_response("User not found", 404)
    new_category = request.form['category']
    if new_category is None:
        return make_response("No category provided", 400)
    all_answers = request.form['answers']
    if all_answers is None:
        return make_response("No answers provided", 400)
    question_text = request.form['question']
    if question_text is None:
        return make_response("No question text provided", 400)
    lat = request.form['lat']
    lng = request.form['lng']
    if lat is None or lng is None:
        return make_response('Need location', 400)

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
    return make_response('Question created succesfully!', 201)

###########################################################################
# Show all information about a specific question
###########################################################################
@question_api.route("/<q_id>", methods=['GET'])
@auth_required
def show_question_by_id(q_id):
    if q_id is None :
        return make_response("No question id provided!", 400)
    question = db.session.query(Question).get(q_id)
    if(question != None):
        return make_response(repr(question), 200)
    else:
        return make_response("Question not found!", 404)

###########################################################################
# vote on a new question
###########################################################################
@question_api.route("/<q_id>/vote", methods=['PATCH'])
@auth_required
def vote(q_id):
    # check fields
    u_id = request.form['user_id']
    a_id = request.form['answer_id']
    if u_id is None or q_id is None or a_id is None :
        return make_response("No question or user or answer id provided!", 400)

    # check database
    u_id = int(u_id)
    q_id = int(q_id)
    a_id = int(a_id)
    question = db.session.query(Question).get(q_id)
    user = db.session.query(User).get(u_id)
    if question is None:
        return make_response("Question not found!", 404)
    if user is None:
        return make_response("User not found!", 404)

    #error check
    responders = json.loads(question.responders)
    if u_id in responders:
        return make_response("User already responded!", 400)
    answers = json.loads(question.answers)
    if a_id >= len(answers):
        return make_response("Answer id not legitimate!", 400)

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
    return make_response("Vote added succesfully!", 200)
