void serialEvent()
{
  while(Serial.available() > 0) {
    byte fid = Serial.read();
    execute(fid);
  }
}

// input: function ID from the serial port
// reads the new bytes for the function from the serial port
// and executes the function
void execute(byte fid)
{
  byte buffer[bufSize];
  
  switch(fid) {
    case 0:
      // stop the motor
      stopMotor = true;
      break;
    case 1:
      // start the motor
      stopMotor = false;
      break;
    case 2:
      // change the speed of the motor
      while(!Serial.available());
      rpm = (int)Serial.read();
      motor.setSpeed(rpm);
      break;
    case 4:
      // set the number of pings per second
      byte pps;
      pps = Serial.read();
      ping_delay = 1000 / pps;
      break;
    case 5:
      // move to a certain angle and stop motor
      while(Serial.available() < bufSize);
      for(int i = 0; i < bufSize; i++) {
        buffer[i] = Serial.read();
      }
      float angle;
      angle = *(float*)buffer;
      motor.setAngle(angle);
      stopMotor = true;
      break;
/*    case 6:
      // get the motor speed
      for(int i = 0; i < bufSize; i++) {
        buffer[i] = 0;
      }
      Serial.write(buffer, bufSize);
      
      buffer[bufSize - 1] = (byte)rpm;
      Serial.write(buffer, bufSize);
      break;
*/
    default:
      break;
  }
}
