from flask import request, make_response, session
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from models import User
from database import db

def verify_password(username, password):

    return True
    user = db.session.query(User).filter_by(username=username)
    if user is None:
        return False
    else:
        return check_password_hash(username, password)

def auth_required(f):

    @wraps(f)
    def auth_wrapper(*args, **kwargs):
        auth = request.authorization
        username = auth.username
        if (auth is None) or (auth.username is None) or (auth.password is None):
            return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required"'})
        elif not verify_password(username, auth.password):
            return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Incorrect username"'})
        else:
            return f(*args, **kwargs)
    return auth_wrapper
