from flask import Blueprint, request, redirect, session, jsonify, render_template
import json

other_api = Blueprint('other_api', __name__)
app.register_blueprint(other_api, url_prefix='/')

###########################################################################
# Place holders
###########################################################################
@other_api.route('/')
# @auth.login_required
def index():
    return 'index'
