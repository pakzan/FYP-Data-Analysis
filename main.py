import PythonLibMightyZap
import time
import os

MightyZap = PythonLibMightyZap
Servo_ID = 0
MightyZap.OpenMightyZap('COM5', 57600)
duration = 5
period = 0.1
path = "startMove.txt"

while True:
    # comunicate with matlab through .txt
    if os.path.exists(path):
        startTime = time.time()
        while time.time() - startTime < duration:
            MightyZap.goalPosition(Servo_ID,3300) 
            time.sleep(period)
            MightyZap.goalPosition(Servo_ID,2700)    
            time.sleep(period)
        os.remove(path)
