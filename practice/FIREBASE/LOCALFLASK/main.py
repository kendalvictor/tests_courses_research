import os
import sys

from firebase_admin import firestore
import firebase_admin
from firebase_admin import credentials

import flask

app = flask.Flask(__name__)

BASE_DIR = os.getcwd()
if BASE_DIR not in sys.path:
    sys.path.append(BASE_DIR)

json_credentials = os.path.join(BASE_DIR, 'gamefunctions-b0e16-firebase-adminsdk-3a4cj-8140ff7bea.json')
cred = credentials.Certificate(json_credentials)
firebase_admin.initialize_app(cred)


SUPERHEROES = firestore.client().collection('superheroes')


@app.route('/', methods=['GET'])
def heroes():
    return flask.jsonify(
        {
            'coneccion': 'OK',
            'json_credentials': json_credentials
        }
    ), 200


@app.route('/heroes', methods=['POST'])
def create_hero():
    print("1")
    req = flask.request.json or {}
    print("-"*10, '>', req)
    print("2")
    hero = SUPERHEROES.document()
    print("-"*10, '>', hero)
    print("3")
    hero.set(req)
    print("4")
    return flask.jsonify({'id': hero.id}), 201


@app.route('/heroes/<id>', methods=['GET'])
def get_hero(id):
    return flask.jsonify(_ensure_hero(id).to_dict())


@app.route('/heroes/<id>', methods=['PUT'])
def update_hero(id):
    _ensure_hero(id)
    req = flask.request.json or {}
    SUPERHEROES.document(id).set(req)
    return flask.jsonify({'success': True})


@app.route('/heroes/<id>', methods=['DELETE'])
def delete_hero(id):
    _ensure_hero(id)
    SUPERHEROES.document(id).delete()
    return flask.jsonify({'success': True})


def _ensure_hero(id):
    try:
        return SUPERHEROES.document(id).get()
    except Exception as e:
        print("/"*50)
        print(e)
        print("/"*50)
        flask.abort(404)


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
