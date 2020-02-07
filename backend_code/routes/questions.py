from flask import Blueprint

question_api = Blueprint('question_api', __name__)


# Handle questions
@question_api.route("/", methods=['GET','POST'])
# @auth.login_required
def questions():
    return 'Questions Home'


###########################################################################
# post a new question
###########################################################################
@question_api.route("/new", methods=['GET'])
# @auth.login_required
def new_question():

    #error checking
    u_id = request.args.get('user')
    if u_id is None:
        return 'need user id'
    user_entry = db.session.query(User).get(u_id)
    if user_entry is None:
        return 'need registered user id'
    new_category = request.args.get('category')
    if new_category is None:
        return 'need category'
    all_answers = request.args.get('answers')
    if all_answers is None:
        return 'need answers'
    question_text = request.args.get('question')
    if question_text is None:
        return 'need question text'
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    if lat is None or lng is None:
        return 'need lat and lng'

    #location
    new_lat = float(lat)
    new_lng = float(lng)

    #user
    u_id = int(u_id)

    #answers
    ans_in = all_answers.split(',')
    num_answers = len(ans_in)
    ans_new = [dict() for x in range(num_answers)]
    for i in range(0,num_answers):
        ans_new[i]["text"] = ans_in[i]
        ans_new[i]["numvotes"] = 0

    #update question database
    new_question = Question(
        asker=u_id,
        question=question_text,
        answers=json.dumps(ans_new),
        category=new_category,
        lat=new_lat,
        lng=new_lng
        )
    db.session.add(new_question)
    db.session.commit()

    #update user database
    serial = new_question.serialize()
    asked_questions = json.loads(user_entry.askQuest)
    asked_questions.question_apiend(new_question.serialize()['id'])
    user_entry.askQuest = json.dumps(asked_questions)
    db.session.commit()

    #return
    return 'success'

###########################################################################
# get user asked questions
###########################################################################
@question_api.route("/get_user_asked", methods=['GET'])
# @auth.login_required
def get_user_asked():
    uid= request.args.get('user')
    if uid is None:
        return 'need user id'
    uid = int(uid)
    user = db.session.query(User).get(uid)
    asked = json.loads(user.askQuest)
    s = []
    for a in asked:
        question = db.session.query(Question).get(a)
        s.question_apiend(question.serialize())

    sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
    return json.dumps(sorted_questions, sort_keys=True, indent=4)

###########################################################################
# get user answered questions
###########################################################################
@question_api.route("/get_user_answered", methods=['GET'])
# @auth.login_required
def get_user_answered():
    uid= request.args.get('user')
    if uid is None:
        return 'need user id'
    uid = int(uid)
    user = db.session.query(User).get(uid)
    answered = json.loads(user.ansQuest)
    s = []
    for a in answered:
        question = db.session.query(Question).get(a)
        s.question_apiend(question.serialize())

    sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)
    return json.dumps(sorted_questions, sort_keys=True, indent=4)

###########################################################################
# get all questions
###########################################################################
## Currently set to return all question less than 2 WEEKS old. CHANGE AFTER GRADED

@question_api.route("/get_all", methods=['GET'])
# @auth.login_required
def get_questions():

    #location
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)

    #filter by location or not
    if lat is None or lng is None:
        valid_questions = db.session.query(Question)
    else:
        lat = float(lat)
        lng = float(lng)
        valid_questions = db.session.query(Question).filter(
            Question.within(lat,lng,32000)
        )

    #filter by time
    valid_questions = valid_questions.filter(
        Question.datetime > (datetime.datetime.utcnow() -
                             datetime.timedelta(days=30)) )

    #filter by category
    category = request.args.get('category')

    if category:
        valid_questions = valid_questions.filter(
            func.lower(Question.category) == func.lower(category) )

    #serialize
    s = []
    for q in valid_questions:
        s.question_apiend(q.serialize())

    #sort
    if request.args.get('sort') == 'hot':
        sorted_questions = sorted(s, key=lambda user:(user['total_votes']), reverse=True)
    else:
        sorted_questions = sorted(s, key=lambda user:(user['datetime']), reverse=False)

    #return
    return json.dumps(sorted_questions, sort_keys=True, indent=4)


###########################################################################
# get all information about a specific question
###########################################################################
@question_api.route("/get", methods=['GET'])
# @auth.login_required
def get_question():
    q_id = request.args.get('question_id')
    if q_id is None :
        return "None"
    question = db.session.query(Question).get(q_id)
    if(question != None):
        return repr(question)
    else:
        return "None"
