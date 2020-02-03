from flask import Flask, request, redirect, session, jsonify
import re
import json
import sys
from flask_sqlalchemy import SQLAlchemy

app =  Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres://qnzlvjypalnabz:LMkfLA8rHNVojAP5et6kLWzQtI@'\
    'ec2-184-73-221-47.compute-1.amazonaws.com:5432/da5kf1gau76p71'
db = SQLAlchemy(app)

@app.route('/')
def index():
    return 'Home Page!'

if __name__ == "__main__":
    app.run(debug=True)
