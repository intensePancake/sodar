const int pingPin = 7;
const int bufLen = 4;

void setup() {
  // initialize serial communication:
  Serial.begin(9600);
}

void loop()
{
  long duration;
  byte cmbuf[bufLen];

  // trigger the pulse
  
  pinMode(pingPin, OUTPUT); // set up the pin to output
  
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
  //Serial.println(duration);

  // convert the time into a distance
  // fill buffer with the number of centimeters based on duration
  microsecondsToCentimeters(duration, cmbuf);
  
  Serial.write(cmbuf, bufLen);
  
  delay(100);
}

void microsecondsToCentimeters(long microseconds, byte *buffer)
{  
  // speed of sound = 343.2 m/s ==>
  // 29.137529 microseconds/cm conversion factor
  
  // Using float
  float cm = float(microseconds) / 29.137529 / 2;
  long *cmPtr = (long*)(&cm);
  
  // place the 4 bytes in a byte array
  buffer[0] = *cmPtr;
  buffer[1] = (*cmPtr >> 8);
  buffer[2] = (*cmPtr >> 16);
  buffer[3] = (*cmPtr >> 24);
  
  /*
  // Using long
  long cm = microseconds / 29 / 2;
  buffer[0] = (byte) cm;
  buffer[1] = (byte) cm >> 8;
  buffer[2] = (byte) cm >> 16;
  buffer[3] = (byte) cm >> 24;
  */
}
