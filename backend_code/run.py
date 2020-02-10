from flask import Flask, session
from application import create_app
from models import Base, User, Question
from database import db

# db_string = 'postgres://qnzlvjypalnabz:LMkfLA8rHNVojAP5et6kLWzQtI@ec2-184-73-221-47.compute-1.amazonaws.com:5432/da5kf1gau76p71'
db_string = 'postgresql://localhost/testData'
application = create_app(db_string)

###########################################################################
# Setup data base (clearing anything in a previous instance)
# FIGURE OUT HOW TO DO THIS WITHOUT CLEARING
###########################################################################
def setup():

    # Recreate database each launch
    Base.metadata.drop_all(bind=db.engine)
    Base.metadata.create_all(bind=db.engine)

# Print the contents of both datbases
def check():
    print("USERS")
    users = db.session.query(User).all()
    for user in users:
        print(user)

    print(" ")
    print("QUESTIONS")

    questions = db.session.query(Question).all()
    for question in questions:
        print(question)

if __name__ == "__main__":
    application.run(debug=True)
