from flask import Blueprint, request, redirect, session, jsonify, render_template, make_response
from werkzeug.security import generate_password_hash
from models import Base, User, Question
import json

from app import app, db
from auth import auth_required, verify_password

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
    return make_response(json.dumps(s, sort_keys=True, indent=4),200)

###########################################################################
# Create new user
###########################################################################
@user_api.route("/", methods=['POST'])
def create_new_user():

    if "number" not in request.form:
        return make_response('No number provided!', 400)
    if "username" not in request.form:
        return make_response('No username provided!', 400)
    if "password" not in request.form:
        return make_response('No password provided!', 400)

    cell = request.form["number"]
    username = request.form["username"]
    password = request.form["password"]

    # See if user has registered
    numbers = db.session.query(User).filter_by(cell_number=cell).scalar()
    usernames = db.session.query(User).filter_by(username=username).scalar()
    if numbers is not None:
        return make_response('Phone number already registered!', 400)
    elif usernames is not None:
        return make_response('Username already registered!', 400)

    if not valid_phone_number(cell):
        return make_response('Phone number is invalid!', 400)

    if not valid_username(username):
        return make_response('Username is invalid!', 400)

    else:
        newuser = User(
        username=username,
        hash=generate_password_hash(password),
        cell_number=cell
        )
        db.session.add(newuser)
        db.session.commit()
        return make_response(str(newuser.id), 201)

def valid_phone_number(cell):
    return (len(cell) >= 10)

def valid_username(username):
    return (len(username) > 2)

###########################################################################
# Request all info about a user
###########################################################################
@user_api.route("/<uid>", methods=['GET'])
@auth_required
def show_user_by_id(uid):
    if number is None and uid is None:
        return make_response("No Number or Id Provided", 400)

    user = db.session.query(User).get(int(uid))

    if user is None:
        return make_response("This user does not exist", 404)

    return make_response(repr(user), 200)

###########################################################################
# Login user (checks if user exists and is authorized)
###########################################################################
@user_api.route("/login", methods=['GET'])
def login_user():

    auth = request.authorization
    if (auth is None) or (auth.username is None) or (auth.password is None):
        return make_response('Could not login!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required"'})
    else:
        username = auth.username

    if not verify_password(username, auth.password):
        return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Incorrect username or password"'})
    else:
        user = db.session.query(User).filter_by(username=username).scalar()
        return make_response(str(user.id), 200)

###########################################################################
# Show all questions asked by user
###########################################################################
@user_api.route("/<uid>/asked", methods=['GET'])
@auth_required
def get_questions_asked_by_user(uid):
    if uid is None:
        return make_response("No user id provided", 400)
    uid = int(uid)
    user = db.session.query(User).get(uid)
    asked = json.loads(user.askQuest)
    s = []
    for a in asked:
        question = db.session.query(Question).get(a)
        s.append(question.serialize())

    sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
    return make_response(json.dumps(sorted_questions, sort_keys=True, indent=4), 200)

###########################################################################
# Show all questions answered by user
###########################################################################
@user_api.route("/<uid>/answered", methods=['GET'])
@auth_required
def get_questions_answered_by_user(uid):
        if uid is None:
            return make_response("No user id provided", 400)
        uid = int(uid)
        user = db.session.query(User).get(uid)
        answered = json.loads(user.ansQuest)
        s = []
        for a in answered:
            question = db.session.query(Question).get(a)
            s.append(question.serialize())

        sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
        return make_response(json.dumps(sorted_questions, sort_keys=True, indent=4), 200)
