# start of control motor
import PythonLibMightyZap
import time

MightyZap = PythonLibMightyZap
Servo_ID = 0
duration = 5
period = 0.15


def startMove():
    try:
        MightyZap.OpenMightyZap('COM5', 57600)
    except Exception as e:
        print(e)
    startTime = time.time()
    while time.time() - startTime < duration:
            MightyZap.goalPosition(Servo_ID, 3500)
            time.sleep(period)
            MightyZap.goalPosition(Servo_ID, 2500)
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
                    print("start record")
                    timestamp = filename.replace(
                        'startRecord', '').replace('.txt', '')
                    yield 'data: {}\n\n'.format(timestamp)
                    try:
                        os.remove(filename)
                    except Exception:
                        print("file deleted")

                    #start after 5 sec
                    delay = 5
                    startTime = time.time()
                    while time.time() - startTime < delay:
                        pass
                    startMove()

    return Response(gen(), mimetype='text/event-stream')

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, threaded=True)

# for testing
# while True:
#     input("")
#     startMove()
