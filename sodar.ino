#include <Stepper.h>

#define STEPS 200 // number of steps per revolution

Stepper motor(STEPS, 8, 9, 10, 11);
boolean stopMotor = false;
int rpm = 15;
int ping_delay = 50;
const int pingPin = 7;
const int bufSize = 4;
const int compBufSize = 8;
long last_ping_time = 0;

long tmax = 0;

void setup() {
  motor.setSpeed(rpm);
  pinMode(2, OUTPUT); // debugging LED
  // initialize serial communication
  Serial.begin(9600);
}

void loop()
{
  if(millis() - last_ping_time >= ping_delay) {
    last_ping_time = millis();

    // we can now request a reading from the PING))) sensor
    long duration;                // time measurement from sensor
    float cm;                     // distance reading in centimeters
    byte buffer[bufSize];          // buffer to send to the serial port
    float angle;                  // stepper motor angle
  
    // trigger the pulse
    
    pinMode(pingPin, OUTPUT);
    
    // write low for 2 microseconds to ensure clean pulse
    digitalWrite(pingPin, LOW);
    delayMicroseconds(2);
    // send pulse
    digitalWrite(pingPin, HIGH);
    delayMicroseconds(5);
    digitalWrite(pingPin, LOW);
  
    // read pulse from the pin
    pinMode(pingPin, INPUT);
    duration = pulseIn(pingPin, HIGH, 25000);
  
    // convert the time into a distance
    cm = microsecondsToCentimeters(duration);
   //cm = random(1, 300);
    // fill buffer with the distance reading
    floatToBuffer(buffer, cm);
    Serial.write(buffer, bufSize);
    //Serial.print(cm);
    //Serial.println(" cm");
    
    angle = motor.getAngle();
    floatToBuffer(buffer, angle);
    Serial.write(buffer, bufSize);
    
  }
  
  if(!stopMotor) {
    motor.step(1);
  }
}

float microsecondsToCentimeters(long microseconds)
{  
  // speed of sound = 343.2 m/s =>
  // 29.137529 microseconds/cm conversion factor
  
  // Using float
  float cm = float(microseconds) / 29.137529 / 2;
  
  // Using long
  //long cm = microseconds / 29 / 2;
  
  return cm;
}
  
void floatToBuffer(byte *buffer, float data)
{
  long *dataPtr = (long*)(&data);
  
  // place the 4 bytes in a byte array
  
  buffer[0] = *dataPtr;
  buffer[1] = (*dataPtr >> 8);
  buffer[2] = (*dataPtr >> 16);
  buffer[3] = (*dataPtr >> 24);
}

void longToBuffer(byte *buffer, long data)
{
  buffer[0] = (byte) data;
  buffer[1] = (byte) data >> 8;
  buffer[2] = (byte) data >> 16;
  buffer[3] = (byte) data >> 24;
}
