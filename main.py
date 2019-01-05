# start of control motor
import PythonLibMightyZap
import time

MightyZap = PythonLibMightyZap
Servo_ID = 0
MightyZap.OpenMightyZap('COM5', 57600)
duration = 5
period = 0.1
path = "startMove.txt"


def startMove():
    startTime = time.time()
    while time.time() - startTime < duration:
            MightyZap.goalPosition(Servo_ID, 3300)
            time.sleep(period)
            MightyZap.goalPosition(Servo_ID, 2700)
            time.sleep(period)


# start of record video
from flask import Flask, render_template, Response, jsonify
import os, glob

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/audio_feed')
def audio_feed():
    # Server Send Event for sending current status to frontend
    def gen():
        while True:
            # comunicate with matlab through .txt
            for filename in glob.glob("*.txt"):
                if 'startRecord' in filename:
                    timestamp = filename.replace(
                        'startRecord', '').replace('.txt', '')
                    # startMove()
                    os.remove(filename)
                    yield 'data: {}\n\n'.format(timestamp)

    return Response(gen(), mimetype='text/event-stream')


app.run(host='0.0.0.0', debug=True, threaded=True)
