'''
Pines del controlador de motor (L298N) relacionado con los pines de la raspberry pi
enable: 18
in1: 19
in2: 13
'''
import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

class Motor():
    def __init__(self,ena,in1,in2):
        self.ena = ena
        self.in1 = in1
        self.in2 = in2
        GPIO.setup(self.ena, GPIO.OUT)
        GPIO.setup(self.in1, GPIO.OUT)
        GPIO.setup(self.in2,GPIO.OUT)
        self.pwm = GPIO.PWM(self.ena, 100)
        self.pwm.start(0)
    def forward(self, frequency = 50):
        GPIO.output(self.in1, GPIO.LOW)
        GPIO.output(self.in2, GPIO.HIGH)
        self.pwm.ChangeDutyCycle(frequency)
    def backwards(self, frequency = 50):
        GPIO.output(self.in1, GPIO.HIGH)
        GPIO.output(self.in2, GPIO.LOW)
        self.pwm.ChangeDutyCycle(frequency)
    def stop(self):
        GPIO.output(self.in1, GPIO.LOW)
        GPIO.output(self.in2, GPIO.LOW)

#Parametros nombrados - Motor(enable: 18, in1: 19, in2: 13)
#Enable es un pin PWM (18)
        
motor = Motor(18,19,13)

while True:
    motor.forward(40)
    sleep(2)
    motor.stop()
    sleep(2)
    motor.backwards(40)
    sleep(2)
    motor.stop()
