import processing.serial.*;

Serial arduino;

void serialEvent(Serial port)
{
  // guuyyyyyyyyyyyyyyyyyyyyys... i'm super Serial.
  int cm;
  int angle;
  byte[] buffer = new byte[bufSize];
  while(port.available() > 0) {
    int read = port.readBytes(buffer);
    if(buffer != null) {
      if(bFunc == 6) {
        // request was for motor speed
        if(answers.get(answers.size() - 1).equals("")) {
          answers.set(answers.size() - 1, buffer[bufSize - 1] + " rpm");
        } else {
          answers.append(buffer[bufSize - 1] + " rpm");
        }
        bFunc = -1;
        console();
      } else {
        cm = (int(buffer[3]) << 24) | (int(buffer[2]) << 16) | (int(buffer[1]) << 8) | int(buffer[0]);
        cmDist = Float.intBitsToFloat(cm); // distance reading from arduino in centimeters
        angle = (int(buffer[7]) << 24) | (int(buffer[6]) << 16) | (int(buffer[5]) << 8) | int(buffer[4]);
        inputAng = Float.intBitsToFloat(angle); // motor angle reading from arduino in degrees
        /* before arduino interrupt code was added
        lastAng = curAng;
        tLast = tCur;
        tCur = millis();
        */
        curAng = inputAng;
        //updateRPM(); // dynamic speed adjustment based on motor angles and time
        
        if(0 < cmDist && cmDist < outerLimit) {
          dots.add(new Dot(cmDist, inputAng));
        }
      }
    }
  }
}

void updateRPM()
{
  float diff = 0;
  float deg = curAng - lastAng;
  float ms = tCur - tLast;
  for(int i = numRPMs - 1; i > 0; i--) {
    rpm[i] = rpm[i - 1];
    diff += rpm[i] - rpmRequest;
  }
  rpm[0] = round(deg / ms * 1000 / 6);
  if(rpm[0] <= 0 || rpm[0] > 200)
    rpm[0] = rpmRequest;
  
  diff += rpm[0] - rpmRequest;
  if(diff < 0) {
    // processing doesn't know how to divide...
    diff *= -1;
    diff /= numRPMs;
    diff *= -1;
  } else {
  diff += rpmRequest - rpm[0];
    diff /= numRPMs; // get the average difference
  }
  if(diff < -2 || diff > 2) {
    deltaRPM(round(diff));
  }
}
