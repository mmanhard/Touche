from flask import Flask, session

from application import app, db
from models import Base, User, Question


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
    app.run(debug=True)
