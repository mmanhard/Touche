from flask import Blueprint, request, redirect, session, jsonify, render_template
from models import Base, User, Question
import json
from application import app, db

user_api = Blueprint('user_api', __name__)
app.register_blueprint(user_api, url_prefix='/users')

###########################################################################
# Show all users
###########################################################################
@user_api.route("/", methods=['GET'])
# @auth.login_required
def index():
    all_users = db.session.query(User).all()
    s = []
    for u in all_users:
        s.append(u.serialize())
    return json.dumps(s, sort_keys=True, indent=4)

###########################################################################
# Create new user
###########################################################################
@user_api.route("/", methods=['POST'])
# @auth.login_required
def create_new_user():
    cell = request.form['number']
    print(cell)
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
# Request all info about a user
###########################################################################
@user_api.route("/<uid>", methods=['GET'])
# @auth.login_required
def show_user_by_id(uid):
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
# Show all questions asked by user
###########################################################################
@user_api.route("/<uid>/asked", methods=['GET'])
# @auth.login_required
def get_questions_asked_by_user(uid):
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
# Show all questions answered by user
###########################################################################
@user_api.route("/<uid>/answered", methods=['GET'])
# @auth.login_required
def get_questions_answered_by_user(uid):
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
# DEPRECATED METHODS
###########################################################################

# @user_api.route("/get_all", methods=['GET'])
# # @auth.login_required
