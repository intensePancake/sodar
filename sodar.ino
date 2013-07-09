#include <Stepper.h>

#define STEPS 200 // number of steps per revolution
#define DELAY 100 // delay in milliseconds between one pulse from PING)))
                 // sensor and the next pulse to the PING))) sensor

Stepper motor(STEPS, 8, 9, 10, 11);
boolean stopMotor = false;
int rpm = 60;
const int pingPin = 7;
const int bufSize = 4;
long last_ping_time = 0;

void setup() {
  motor.setSpeed(rpm);
  
  // initialize serial communication
  Serial.begin(9600);
}

void loop()
{
  if(millis() - last_ping_time >= DELAY) {
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
    duration = pulseIn(pingPin, HIGH);
  
    // convert the time into a distance
    cm = microsecondsToCentimeters(duration);
    // fill buffer with the distance reading
    fillBuffer(buffer, cm);
    //Serial.write(buffer, bufSize);
    Serial.print(cm);
    Serial.println(" cm");
    
    angle = motor.getAngle();
    fillBuffer(buffer, angle);
    //Serial.write(buffer, bufSize);
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
  
void fillBuffer(byte *buffer, float data)
{
  long *dataPtr = (long*)(&data);
  
  // place the 4 bytes in a byte array
  
  // Using float
  buffer[0] = *dataPtr;
  buffer[1] = (*dataPtr >> 8);
  buffer[2] = (*dataPtr >> 16);
  buffer[3] = (*dataPtr >> 24);
  
  /*
  // Using long
  buffer[0] = (byte) data;
  buffer[1] = (byte) data >> 8;
  buffer[2] = (byte) data >> 16;
  buffer[3] = (byte) data >> 24;
  */
}
