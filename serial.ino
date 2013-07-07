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
    case 1:
      // change the speed of the motor
      rpm = Serial.read();
      motor.setSpeed(rpm);
      break;
  }
}
