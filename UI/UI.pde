import processing.serial.*;

Serial arduino;
float rotSpeed; //rotations per minute
float curAng; //current angle
float lastMillis;
float lastAng;
float radius;
String curString = "";
int text_size = 14;

StringList pastStrings;
int historySize;
int bufSize = 8;

void setup(){
  frameRate(100);
  size(720,480);
  background(150);
  rotSpeed = 5;
  curAng = 0;
  lastMillis = millis();
  radius = (width/2-width/32);
  line(width / 2, 0, width / 2, height);
  
  // set up console
  fill(0);
  rect(width / 2, height / 2, width / 2, height / 2);
  historySize = (height / 2 - 6) / (text_size + 6);
  pastStrings = new StringList(historySize);
  
  if(Serial.list().length > 0) {
    arduino = new Serial(this, Serial.list()[0], 9600);
    arduino.buffer(bufSize);
  }
}

void draw(){
  //draw a arc at diff angles based on speed of rotation
  changeSpeed();
  printAng();
  fill(0,10);
  stroke(255);
  strokeWeight(2);
  strokeCap(SQUARE);
  smooth();
  ellipse(width / 4, height / 2, radius, radius);
  noStroke();
  fill(255);
  rect(width / 2, 0, width / 2, height / 2);
  
  // draw console
  fill(0);
  rect(width / 2, height / 2, width / 2, height / 2);
  console();
  /*
  String fps = "fps: " + int(frameRate);
  text(fps, width/2 + 10, 10);
  */
}

void keyPressed(){
  switch(key){
    case '\n':
      pastStrings.append(curString);
      //processCmd(curString);
      while(pastStrings.size() > historySize) {
        pastStrings.remove(0);
      }
      curString = "";
      break;
    case 8:
      if(curString.length() > 0){
        curString = curString.substring(0, curString.length() - 1);
      }
      break;
    default:
      if(key >= 32 && key <= 127){
        curString += key;
      }
      break;
  }
}

void console(){
  fill(255);
  textSize(text_size);
  text('>',width / 2 + 2,height - 6);
  text(curString, width / 2 + 12, height - 6);
  for(int i = pastStrings.size() - 1; i >= 0; i--){
    text(pastStrings.get(i), width / 2 + 2, height - 6 - 20 * (pastStrings.size() - i));
  }
  if(millis()%1000<500){
    rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
  }
}

void changeSpeed(){
  //autoGenerate randomly without a serial input
  float tempMil = millis();
  if(tempMil-lastMillis>17.5){
    //max difference between correct and real is half degree increment of 1.8deg
    float fluctuation = randomGaussian()*0.9/12000;
    float inputAngle = (rotSpeed /*+fluctuation*/ )*360/60000*(millis()-lastMillis);
    float difAng = inputAngle - lastAng;
    if(abs(inputAngle+360-lastAng)<abs(inputAngle-lastAng))difAng = inputAngle-lastAng + 360;
    if(abs(inputAngle-360-lastAng)<abs(inputAngle-lastAng))difAng = inputAngle-lastAng - 360;
    float newSpeed = difAng/(tempMil-lastMillis)*60000/360;
    //rotSpeed = (rotSpeed * 4 + newSpeed)/5;
    lastMillis = tempMil;
  }
}

void printAng(){
   //rotSpeed*360/60/1000 = degrees per millisecond
    curAng = (rotSpeed*360/60000*millis())%360;
    //println(curAng+": "+cos(curAng)+", "+sin(curAng));
    /*
    noStroke();
    fill(36,221,0);
    arc(width/4,height/2,width/2-width/32,width/2-width/32,radians(curAng),radians(curAng-20));
    */
    strokeWeight(5);
    stroke(36,221,0);
    line(width/4,height/2, width/4+cos(radians(curAng))*radius/2,height/2+sin(radians(curAng))*radius/2);
}

void serialEvent(Serial port)
{
  int cm;
  float cm_float;
  int angle;
  float angle_float;
  byte[] buffer = new byte[bufSize];
  while(port.available() > 0) {
    int read = port.readBytes(buffer);
    if(buffer != null) {
      cm = (int(buffer[3]) << 24) | (int(buffer[2]) << 16) | (int(buffer[1]) << 8) | int(buffer[0]);
      cm_float = Float.intBitsToFloat(cm); // distance reading from arduino in centimeters
      angle = (int(buffer[7]) << 24) | (int(buffer[6]) << 16) | (int(buffer[5]) << 8) | int(buffer[4]);
      angle_float = Float.intBitsToFloat(angle); // motor angle reading from arduino in degrees
      displayReading(cm_float, angle_float);
    }
  }
}

void displayReading(float cm, float angle)
{
}
