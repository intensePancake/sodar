import processing.serial.*;

Serial arduino;

float rotSpeed; //rotations per minute
float outerLimit;

float curAng; //current angle
float inputAng;
float lastAng;

float lastMillis;
float curMillis;

float cmDist;

float diameter;
float radius;

ArrayList<Dot> dots;

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
  outerLimit = 300;
  curAng = 0;
  lastMillis = millis();
  diameter = (width/2-width/32);
  radius = diameter / 2;
  dots = new ArrayList<Dot>();
  dots.add(new Dot(100, 90));
  time1=millis();
  
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
  ellipse(width / 4, height / 2, diameter, diameter);
  noStroke();
  fill(255);
  rect(width / 2, 0, width / 2, height / 2);
  
  // draw console
  fill(0);
  rect(width / 2, height / 2, width / 2, height / 2);
  console();
  
  drawDots(100, 90);
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
  if(curMillis != lastMillis){
    /*
    //max difference between correct and real is half degree increment of 1.8deg
    float fluctuation = randomGaussian()*0.9/12000;
    inputAng = (rotSpeed +fluctuation )*360/60000*(curMillis-lastMillis);
    */
    float difAng = inputAng - lastAng;
    if(abs(inputAng+360-lastAng)<abs(inputAng-lastAng))difAng = inputAng-lastAng + 360;
    if(abs(inputAng-360-lastAng)<abs(inputAng-lastAng))difAng = inputAng-lastAng - 360;
    float newSpeed = difAng/(curMillis-lastMillis)*60000/360;
    rotSpeed = (rotSpeed * 4 + newSpeed)/5; //increment the speed to new speed
    lastMillis = curMillis;
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
    line(width/4,height/2, width/4+cos(radians(curAng))*radius,height/2+sin(radians(curAng))*radius);
}

void serialEvent(Serial port)
{
  curMillis = millis();
  int cm;
  int angle;
  byte[] buffer = new byte[bufSize];
  while(port.available() > 0) {
    int read = port.readBytes(buffer);
    if(buffer != null) {
      cm = (int(buffer[3]) << 24) | (int(buffer[2]) << 16) | (int(buffer[1]) << 8) | int(buffer[0]);
      cmDist = Float.intBitsToFloat(cm); // distance reading from arduino in centimeters
      angle = (int(buffer[7]) << 24) | (int(buffer[6]) << 16) | (int(buffer[5]) << 8) | int(buffer[4]);
      inputAng = Float.intBitsToFloat(angle); // motor angle reading from arduino in degrees
      if(cmDist > outerLimit) {
        dots.add(new Dot(cmDist, inputAng));
      }
    }
  }
}

void drawDots(float cm, float angle)
{
  for(int i = 0; i < dots.size(); i++) {
    Dot dot = dots.get(i);
    if(dot.alpha < 1) {
      dots.remove(i);
    } else {
      dot.drawSelf();
      if(millis() - dot.last_fade > 100) {
        // 10 fades per second
        dot.fade();
      }
    }
  }
}

class Dot {
  float cm;
  float angle;
  float alpha;
  float dotRadius;
  long last_fade;
  
  Dot(float dist, float ang) {
    cm = dist;
    angle = ang;
    alpha = 255;
    dotRadius = width / 64;
    last_fade = 0;
  }
  
  void drawSelf() {
    noStroke();
    fill(36, 221, 0, alpha);
    float px = (cm / outerLimit) * radius; // number of pixels from the center of the circle
    ellipse(width / 4 + px * cos(radians(angle)), height / 2 + px * sin(radians(angle)), dotRadius, dotRadius);
  }
  
  void fade() {
    alpha *= 9.0/10.0;
    last_fade = millis();
  }
}
    
