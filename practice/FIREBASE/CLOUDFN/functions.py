from cloudfn.flask_handler import handle_http_event
from flask import Flask, request
from flask.json import jsonify


app = Flask('the-function')


@app.route('/',  methods=['POST', 'GET'])
def hello():

    return jsonify(message='Hello world!', json=request.get_json()), 201


handle_http_event(app)