from flask import Blueprint, request, redirect, session, jsonify, render_template
from werkzeug.security import generate_password_hash
from models import Base, User, Question
import json

from app import app, db
from auth import auth_required

user_api = Blueprint('user_api', __name__)

###########################################################################
# Show all users
###########################################################################
@user_api.route("/", methods=['GET'])
@auth_required
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
def create_new_user():
    cell = request.form['number']
    new_username = request.form['username']
    password = request.form['password']

    if cell is None:
        return 'No Number Provided'
    if new_username is None:
        return 'No Username Provided'
    if password is None:
        return 'No Password Provided'

    # See if user has registered, register if not
    number = db.session.query(User).filter_by(cell_number=cell).scalar()
    if number is None:
        newuser = User(
        username=new_username,
        hash=generate_password_hash(password),
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
@auth_required
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
@auth_required
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
@auth_required
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
