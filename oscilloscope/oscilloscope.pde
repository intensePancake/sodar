import processing.serial.*;

Serial arduino;
int bufSize = 2; // 2 byte buffer (Arduino int)
int[] values;

void setup()
{
  size(360, 360);
  background(51);
  stroke(255);
  arduino = new Serial(this, Serial.list()[0], 9600);
  arduino.buffer(bufSize);
  values = new int[width];
}

int get_y(int val)
{
  return height - (int)(val * (float)height / 1023.0);
}

void draw()
{
  for(int i = 0; i < width; i++) {
    point(i, values[i]);
  }
  
  text("5 V", 0, 0);
  text("0 V", 0, height);
}

void serialEvent(Serial port)
{
  byte[] buffer = new byte[bufSize];
  while(port.available() > 0) {
    int read = port.readBytes(buffer);
    if(buffer != null) {
      int val = int(buffer[1]) << 8 | int(buffer[0]);
      addV(val);
    }
  }
}

void addV(int v)
{
  for(int i = 0; i < width - 1; i++) {
    values[i] = values[i + 1];
  }
  values[width - 1] = v;
}

void stop()
{
  arduino.clear();
  arduino.stop();
}
