void serialEvent()
{
  while(Serial.available() > 0) {
    byte serialIn = Serial.read();
    execute(serialIn);
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
      // change the speed of the motor
      rpm = Serial.read();
      motor.setSpeed(rpm);
      break;
    case 4:
      // move to a certain angle and stop motor
      byte buffer[bufSize];
      for(int i = 0; i < bufSize; i++) {
        buffer[i] = Serial.read();
      }
      float angle = *(float*)buffer;
      motor.setAngle(angle);
      stopMotor = true;
      break;
  }
}
