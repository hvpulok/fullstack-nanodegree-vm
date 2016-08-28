# This file defines server side definitions
from flask import Flask, render_template, request, redirect,jsonify, url_for, flash
from flask import session as login_session
from sqlalchemy import create_engine, asc
from sqlalchemy.orm import sessionmaker
from database_setup import Base, Subject, Course, User

import random, string

app = Flask(__name__)

#Connect to Database and create database session
engine = create_engine('sqlite:///course_catalog.db')
Base.metadata.bind = engine

DBSession = sessionmaker(bind=engine)
session = DBSession()

#Show all subjects in catalog
@app.route('/')
@app.route('/subjects/')
def showSubjects():
    subjects = session.query(Subject).order_by(asc(Subject.name))
    return render_template('subjects.html', subjects = subjects)
    # return "Welcome"


#Show selected subject's course catalog
@app.route('/subjects/<int:subject_id>/')
@app.route('/subjects/<int:subject_id>/course/')
def showCourse(subject_id):
    subject = session.query(Subject).filter_by(id = subject_id).one()
    courses = session.query(Course).filter_by(subject_id = subject_id).all()
    return render_template('courses.html', courses = courses, subject = subject)


# Server host and port definition starts here
if __name__ == '__main__':
    app.secret_key = 'super_secret_key'
    app.debug = True
    app.run(host = '0.0.0.0', port = 5000)