#include <Stepper.h>
#include <NewPing.h>

#define STEPS 200 // number of steps per revolution
#define TRIGGER_PIN 7
#define ECHO_PIN 7
#define MAX_DISTANCE 300

Stepper motor(STEPS, 8, 9, 10, 11);
NewPing sodar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
int ping_delay = 50;
long last_ping_time = 0;
long duration; // duration of return pulse

boolean new_reading = false;
const int max_write_delay = 50;
long last_write_time = 0;

const int bufSize = 4;

boolean stopMotor = false;
int rpm = 15; // default RPM

void setup() {
  motor.setSpeed(rpm);
  // initialize serial communication
  Serial.begin(9600);
}

void loop()
{
  float cm;
  
  if(millis() - last_ping_time >= ping_delay) {
    last_ping_time = millis();
  
    // trigger the pulse and interrupt on response
    sodar.ping_timer(checkPing);
  }
  
  if(new_reading) {
    new_reading = false;
    last_write_time = millis();
    
    // convert the time into a distance
    cm = microsecondsToCentimeters(duration);
    //cm = random(1, 300);
    
    writeData(cm, motor.getAngle());
  } else if(millis() - last_write_time >= max_write_delay) {
    last_write_time = millis();
    
    cm = 0;
    writeData(cm, motor.getAngle());
  }
  
  if(!stopMotor) {
    motor.step(1);
  }
}

void writeData(float cm, float angle)
{
  byte buffer[bufSize];
  
  // fill the buffer with the distance reading
  floatToBuffer(buffer, cm);
  Serial.write(buffer, bufSize);
  //Serial.print(cm);
  //Serial.print(" cm @ ");
  
  // fill the buffer with the angle
  floatToBuffer(buffer, angle);
  Serial.write(buffer, bufSize);
  //Serial.print(angle);
  //Serial.println(" degrees");
}

void checkPing()
{
  if(sodar.check_timer()) {
    // response was received from ping sensor
    new_reading = true;
    
    duration = sodar.ping_result;
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
