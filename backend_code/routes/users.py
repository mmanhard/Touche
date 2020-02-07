from flask import Blueprint, request, redirect, session, jsonify, render_template
from models import Base, User, Question
import json
from database import db

user_api = Blueprint('user_api', __name__)

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
def get_user_by_id(uid):
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
# DEPRECATED METHODS
###########################################################################

# @user_api.route("/get_all", methods=['GET'])
# # @auth.login_required
