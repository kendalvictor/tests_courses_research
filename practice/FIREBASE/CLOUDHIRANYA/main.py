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


def _response(data, status):
    if isinstance(data, dict):
        data = flask.jsonify(data)

    return data, status, headers


def create_hero(request):
    req = request.json or {}
    hero = SUPERHEROES.document()
    hero.set(req)
    return _response({'id': hero.id}, 201)


def read_hero(hero):
    return _response(hero.to_dict(), 200)


def update_hero(idd, request):
    req = request.json or {}
    SUPERHEROES.document(idd).set(req)
    return _response({'success': True}, 200)


def delete_hero(idd):
    SUPERHEROES.document(idd).delete()
    return _response({'success': True}, 200)


def heroes(request):
    print("request.path  :: ", request.path)

    if request.path == '/' or request.path == '':
        if request.method == 'POST':
            return create_hero(request)
        elif request.method == 'GET':
            return init()
        else:
            return _response('Method not supported', 405)

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
                return _response('Method not supported', 405)

        else:
            return _response('Resource not found', 404)

    return _response('URL not found', 404)
