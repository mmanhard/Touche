from flask import request, make_response, session
from werkzeug.security import check_password_hash
from functools import wraps

from models import Base, User
from app import db

# Verifies a password for a given user.
def verify_password(username, password):

    # Get the user.
    user = db.session.query(User).filter_by(username=username).scalar()

    # Verify the user exists and check its password.
    return (user is not None) and check_password_hash(user.hash, password)

# Function wrapper used to authenticate and authorize the user.
def auth_required(f):

    @wraps(f)
    def auth_wrapper(*args, **kwargs):

        # Check that a username and password were supplied.
        auth = request.authorization
        if (auth is None) or (auth.username is None) or (auth.password is None):
            return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required"'})
        else:
            username = auth.username

        # Verify that the password is correct for the given user.
        if not verify_password(username, auth.password):
            return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Incorrect username or password"'})
        else:
            return f(*args, **kwargs)

    return auth_wrapper
