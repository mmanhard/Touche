from flask import Blueprint, request, redirect, session, jsonify, render_template
import json

other_api = Blueprint('other_api', __name__)

###########################################################################
# Place holders
###########################################################################
@other_api.route('/')
def index():
    return 'index'
