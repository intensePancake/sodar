float outerLimit;

float curAng; //current angle
float inputAng;
float lastAng;

long tLast;
long tCur;

int numRPMs = 5;
int[] rpm = new int[numRPMs]; // stores 5 most recent calculations of real RPM
int rpmRequest = 15;

float cmDist;

float diameter;
float radius;

int bufSize = 8;

color green = color(36, 221, 0, 150);
color red = color(221, 36, 0, 150);
color blue = color(36, 0, 221, 150);

//make header null node
GenericTreeNode procs = new GenericTreeNode();

void setup(){
  frameRate(100);
  size(720,480);
  background(150);
  curString = "";
  outerLimit = 300;
  curAng = 0;
  tCur = millis();
  diameter = (width/2-width/32);
  radius = diameter / 2;
  dots = new ArrayList<Dot>();
  
  line(width / 2, 0, width / 2, height);
  
  // set up console
  buildTree();
  checkTree();
  fill(0);
  rect(width / 2, height / 2, width / 2, height / 2);
  historySize = (height / 2 - 6) / (text_size + 6);
  
  queries = new StringList();
  answers = new StringList();
  console();
  
  
  if(Serial.list().length > 0) {
    arduino = new Serial(this, Serial.list()[0], 9600);
    arduino.buffer(bufSize);
  }
  
  resetRPM();
}

void draw(){
  stroke(255);
  strokeWeight(2);
  strokeCap(SQUARE);
  smooth();
  fill(0);//10);
  ellipse(width / 4, height / 2, diameter, diameter);
  //printAng(curAng, green);
  displayArc(curAng, green);
  noStroke();
  fill(255);
  rect(width / 2, 0, width / 2, height / 2);
  
  //if scanning for angle to use
  if(scanOn){
    try {
      scanAng = degrees(atan2((mouseY - (height/2)),mouseX-(width/4)));
      displayArc(scanAng, red);
      //printAng(scanAng, red); 
    } catch (ArithmeticException e){
      //divide by zero probably due to mouse going off the window
    }
  }
  noStroke();
  if(millis()%1000<500){
    fill(255);
    rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
  }else{
     fill(0);
     rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
  }
  drawDots();
  /*
  String fps = "fps: " + int(frameRate);
  text(fps, width/2 + 10, 10);
  */
}

void printAng(float ang, color c){
    strokeWeight(5);
    stroke(c);
    line(width/4,height/2, width/4+cos(radians(ang))*radius,height/2+sin(radians(ang))*radius);
}

void displayArc(float angle, color c) {
  fill(c);
  arc(width / 4, height / 2, diameter, diameter,
      radians(angle - 10), radians(angle + 10));
}

void resetRPM()
{
  for(int i = 0; i < numRPMs; i++) {
    rpm[i] = rpmRequest;
  }
}

void stop()
{
  arduino.stop();
}

byte [] f2B(float f){
    byte[] bArray = new byte[4];
    int data = Float.floatToIntBits(f);
    bArray[0] = (byte) (data);
    bArray[1] = (byte) (data >> 8);
    bArray[2] = (byte) (data >> 16);
    bArray[3] = (byte) (data >> 24); 
    return bArray;
}
