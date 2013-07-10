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
      byte buffer[bufSize];
      for(int i = 0; i < bufSize; i++) {
        buffer[i] = Serial.read();
      }
      float angle;
      angle = *(float*)buffer;
      motor.setAngle(angle);
      stopMotor = true;
      break;
    /*case 6:
      byte buf[3];
      byte ret;
      for(int i = 0; i < 3; i++)
        buffer[i] = 255;
      Serial.write(buf, 3);
      ret = (byte)rpm;
      Serial.write(&ret, sizeof(byte));
      break;*/
    default:
      break;
  }
}
