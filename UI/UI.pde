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

String curString = new String();
int text_size = 14;

StringList pastStrings;
int historySize;
int bufSize = 8;

String[] listFuncs = {"speed(","rpm(","history(","pps(","move(","clear","speed","rpm","history","pps"};

//make header null node
GenericTreeNode procs = new GenericTreeNode();


void setup(){
  frameRate(100);
  size(720,480);
  background(150);
  curString = "";
  rotSpeed = 5;
  outerLimit = 300;
  curAng = 0;
  lastMillis = millis();
  diameter = (width/2-width/32);
  radius = diameter / 2;
  dots = new ArrayList<Dot>();
  dots.add(new Dot(100, 90));
  
  line(width / 2, 0, width / 2, height);
  
  // set up console
  buildTree();
  checkTree();
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



