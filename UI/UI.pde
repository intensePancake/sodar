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

int bufSize = 8;

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
  
  queries = new StringList();
  answers = new StringList();
  console();
  
  
  if(Serial.list().length > 0) {
    arduino = new Serial(this, Serial.list()[0], 9600);
    arduino.buffer(bufSize);
  }
}

void draw(){
  //draw a arc at diff angles based on speed of rotation
  changeSpeed();
  //rotSpeed*360/60/1000 = degrees per millisecond
  curAng = (rotSpeed*360/60000*millis())%360;
  printAng(curAng);
  fill(0,10);
  stroke(255);
  strokeWeight(2);
  strokeCap(SQUARE);
  smooth();
  ellipse(width / 4, height / 2, diameter, diameter);
  noStroke();
  fill(255);
  rect(width / 2, 0, width / 2, height / 2);
  
  //if scanning for angle to use
  if(scanOn){
    try {
      scanAng = degrees(atan2((mouseY - (height/2)),mouseX-(width/4)));
      printAng(scanAng); 
    } catch (ArithmeticException e){
      //divide by zero probably due to mouse going off the window
    }
  }
  noStroke();
  if(millis()%1000<500){
     rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
  }else{
     fill(0);
     rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
     fill(255);
  }
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

void printAng(float ang){
    strokeWeight(5);
    stroke(36,221,0);
    line(width/4,height/2, width/4+cos(radians(ang))*radius,height/2+sin(radians(ang))*radius);
}


byte [] f2B(float f){
    byte[] bArray = new byte[4];
    int data = Float.floatToIntBits(f);
    bArray[0] = (byte) (data>>>24);
    bArray[1] = (byte) (data>>>16);
    bArray[2] = (byte) (data>>>8);
    bArray[3] = (byte) (data>>>0); 
    return bArray;
}
