import processing.serial.*;

Serial arduino;
long distance;
int bufLen = 4; // size of the buffer in bytes
int cm;
float cm_float; // if using float
float max = 0;
float min = 100000.0;

void setup()
{
  size(400, 400);
  arduino = new Serial(this, Serial.list()[0], 9600);
  arduino.buffer(bufLen);
}

void draw()
{
  //background(0);
}

void serialEvent(Serial port)
{
  byte[] buffer = new byte[bufLen];
  while(port.available() > 0) {
    int read = port.readBytes(buffer);
    if(buffer != null) {
      cm = (int(buffer[3]) << 24) | (int(buffer[2]) << 16) | (int(buffer[1]) << 8) | int(buffer[0]);
      cm_float = Float.intBitsToFloat(cm); // if using float
      if(cm_float < min) {
        min = cm_float;
        print("min = ");
        println(min);
      }
      if(cm_float > max) {
        max = cm_float;
        print("max = ");
        println(max);
      }
      /*print(cm);
      println(" cm");*/
    }
  }
}

void stop()
{
  arduino.clear();
  arduino.stop();
}
