from flask import Blueprint, request, redirect, session, jsonify, render_template
import json

other_api = Blueprint('other_api', __name__)


###########################################################################
# Place holders
###########################################################################
@other_api.route('/')
# @auth.login_required
def index():
    return 'index'

###########################################################################
# vote on a new question
###########################################################################
@other_api.route("/vote", methods=['GET'])
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
