# File: main.py
import firebase_admin
from firebase_admin import db
import flask

firebase_admin.initialize_app(options={
    'databaseURL': 'https://gamefunctions-b0e16.firebaseio.com/',
})

SUPERHEROES = db.reference('superheroes')


def init():
    return flask.jsonify({'connection': 'ok'}), 200


def create_hero(request):
    req = request.json
    hero = SUPERHEROES.push(req)
    return flask.jsonify({'id': hero.key}), 201


def read_hero(idd):
    hero = SUPERHEROES.child(idd).get()
    if not hero:
        return 'Resource not found', 404
    return flask.jsonify(hero)


def update_hero(idd, request):
    hero = SUPERHEROES.child(idd).get()
    if not hero:
        return 'Resource not found', 404
    req = request.json
    SUPERHEROES.child(idd).update(req)
    return flask.jsonify({'success': True})


def delete_hero(idd):
    hero = SUPERHEROES.child(idd).get()
    if not hero:
        return 'Resource not found', 404
    SUPERHEROES.child(idd).delete()
    return flask.jsonify({'success': True})


def heroes(request):
    print("request.path  :: ", request.path)

    if request.path == '/' or request.path == '':
        if request.method == 'POST':
            return create_hero(request)
        elif request.method == 'GET':
            return init()
        else:
            return 'Method not supported', 405

    if request.path.startswith('/'):
        idd = request.path.lstrip('/')
        if request.method == 'GET':
            return read_hero(idd)
        elif request.method == 'DELETE':
            return delete_hero(idd)
        elif request.method == 'PUT':
            return update_hero(idd, request)
        else:
            return 'Method not supported', 405

    return 'URL not found', 404
