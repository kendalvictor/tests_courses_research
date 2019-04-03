# File: main.py
import firebase_admin
from firebase_admin import firestore
import flask

firebase_admin.initialize_app()
SUPERHEROES = firestore.client().collection('superhumanos')
headers = {
    'Access-Control-Allow-Origin': '*'
}


def init():
    return flask.jsonify({'connection': 'ok'}), 200, headers


def _ensure_hero(idd):
    try:
        return SUPERHEROES.document(idd).get()
    except:
        return None


def create_hero(request):
    req = request.json or {}
    hero = SUPERHEROES.document()
    hero.set(req)
    return flask.jsonify({'id': hero.id}), 201, headers


def read_hero(hero):
    return flask.jsonify(hero.to_dict()), 200, headers


def update_hero(idd, request):
    req = request.json or {}
    SUPERHEROES.document(idd).set(req)
    return flask.jsonify({'success': True}), 200, headers


def delete_hero(idd):
    SUPERHEROES.document(idd).delete()
    return flask.jsonify({'success': True}), 200, headers


def heroes(request):
    print("request.path  :: ", request.path)

    if request.path == '/' or request.path == '':
        if request.method == 'POST':
            return create_hero(request)
        elif request.method == 'GET':
            return init()
        else:
            return 'Method not supported', 405, headers

    if request.path.startswith('/'):
        idd = request.path.lstrip('/')
        hero = _ensure_hero(idd)
        print("idd : ", idd)
        print("hero : ", hero)
        print(dir(hero))

        if hero:
            if request.method == 'GET':
                return read_hero(hero)

            elif request.method == 'DELETE':
                return delete_hero(idd)

            elif request.method == 'PUT':
                return update_hero(idd, request)

            else:
                return 'Method not supported', 405, headers

        else:
            return 'Resource not found', 404, headers

    return 'URL not found', 404, headers
