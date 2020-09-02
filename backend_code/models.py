from sqlalchemy import Column, Integer, String, DateTime, func, Float, Numeric
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.ext.hybrid import hybrid_property, hybrid_method
import json
import datetime

from app import db

Base = declarative_base()

# Represents the users
class User(db.Model, Base):
	__tablename__ = 'users'

	id = Column(Integer, primary_key=True)
	cell_number = Column(String(16))
	username = Column(String)
	hash = Column(String)
	ansQuest = Column(String, default="{}")
	askQuest = Column(String, default="[]")

	def serialize(self):
		return {
		'id':self.id,
		'username':self.username,
		'cell_number':self.cell_number,
		'ansQuest':json.loads(self.ansQuest),
		'askQuest':json.loads(self.askQuest)
		}

	def __repr__(self):
		return json.dumps(self.serialize())

# Represents the questions
class Question(db.Model, Base):
	__tablename__ = 'questions'

	id = Column(Integer, primary_key=True)
	asker = Column(Integer)
	datetime = Column(DateTime, default=datetime.datetime.utcnow)
	question = Column(String)
	answers = Column(String)
	total_votes = Column(Integer, default=0)
	responders = Column(String, default='[]')
	category = Column(String, default='miscellaneous')
	lat = Column(Float)
	lng = Column(Float)

	# Determines if a location (latitude = l1 and longitude = l2) is within a
	# specified distance, dist (in m), of where the question was posted. 
	@hybrid_method
	def within(self, l1, l2, dist):
		me = func.ll_to_earth(self.lat, self.lng)
		you = func.ll_to_earth(l1, l2)
		return func.earth_distance(me, you) < dist

	# Determines if a location (latitude = l1 and longitude = l2) is within a
	# specified distance, dist (in m), of where the question was posted.
	@within.expression
	def within(cls, l1, l2, dist):
		me = func.ll_to_earth(cls.lat, cls.lng)
		you = func.ll_to_earth(l1, l2)
		return (func.earth_distance(me, you) < dist)

	def serialize(self):
		return {
                'id':self.id,
                'asker':self.asker,
                'datetime':int((datetime.datetime.utcnow() - self.datetime).total_seconds()),
                'question':self.question,
                'answers':json.loads(self.answers),
                'total_votes':self.total_votes,
                'responders':json.loads(self.responders),
                'category':self.category,
                'lat':self.lat,
                'lng':self.lng
                }

	def __repr__(self):
		return json.dumps(self.serialize(), sort_keys=True, indent=4)
