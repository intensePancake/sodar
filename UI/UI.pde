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

//build a tree structure of all functions
void buildTree(){
  for(int i = 0; i<listFuncs.length; i++){
    recursiveBuildTree(procs, listFuncs[i]);
  }
}

void recursiveBuildTree(GenericTreeNode procs, String aFunc){
  if(aFunc.length()==1){
    //if last letter of string, make isEnding true
    GenericTreeNode temp = procs.incrChild(aFunc.charAt(0));
    temp.isEnding = true;
  }else{
    recursiveBuildTree(procs.incrChild(aFunc.charAt(0)),aFunc.substring(1));
  }
}

void checkTree(){
  for(int i = 0; i<procs.children.size(); i++){
    rCheck((GenericTreeNode)procs.children.get(i),"");
  }
}

GenericTreeNode rCheck(GenericTreeNode n,String s){
  if(n.isEnding)println(s+n.data);
  if(n.hasChildren()){
   for(int i = 0; i<n.children.size(); i++){
     rCheck((GenericTreeNode)n.children.get(i),s+n.data);
   } 
  }
  return n;
}


ArrayList<String> funcFound(GenericTreeNode n){
  ArrayList<String> output = new ArrayList<String>();
  rFuncFound(n,"",curString,output);
  //I can't find a way to stop the recursion from adding "null" to every String in the ArrayList
  eraseNull(output);
  println(output);
  return output;
}

void eraseNull(ArrayList<String> output){
 for(int i = 0; i<output.size(); i++){
  output.set(i,output.get(i).substring(4));
 } 
}

GenericTreeNode rFuncFound(GenericTreeNode n,String s, String m, ArrayList<String>output){
  if(n.isEnding)output.add(s+n.data);
  if(n.hasChildren()){
    for(int i = 0; i<n.children.size(); i++){
        GenericTreeNode temp = (GenericTreeNode)n.children.get(i);
        if(m.length()==0){
          rFuncFound((GenericTreeNode)n.children.get(i),s+n.data,m,output);
        }else if((Character)m.charAt(0)==temp.getData()){
         rFuncFound((GenericTreeNode)n.children.get(i),s+n.data,m.substring(1),output); 
        }
    }
  }
  return n;
}


void keyPressed(){
  switch(key){
    case '\n':
      pastStrings.append(curString);
      processCmd();
      while(pastStrings.size() > historySize) {
        pastStrings.remove(0);
      }
      break;
    case 8:
      if(curString.length() > 0){
        curString = curString.substring(0, curString.length() - 1);
      }
      break;
      
    case 9:
      ArrayList<String>sVals = funcFound(procs);
      if(sVals.size()>0){
        curString = sVals.get(0);
      }
      break;
      
    default:
      if(key >= 32 && key <= 127){
        curString += key;
      }
      break;
  }
}

void processCmd(){
  String func = new String();
  try {
    func = curString.substring(0,curString.indexOf('('));
  } catch (StringIndexOutOfBoundsException e){
    //not a function
    if(curString.equals("help")){
       pastStrings.append("Not yet written.");
    }else if(curString.equals("clear")){
       pastStrings.clear(); 
    }else if(curString.equals("speed") || curString.equals("rpm")){
      pastStrings.append(String.valueOf(rotSpeed) + " rpm");
    }else if(curString.equals("history")){
      
    //pings per second
    }else if(curString.equals("pps")){
       
    }else{
      pastStrings.append("Not a known function, type 'help' for more"); 
    }
    curString = "";
    return;
  }
  //is a function
  String args = new String();
  try {
    args = curString.substring(curString.indexOf('(')+1,curString.indexOf(')'));
  } catch (StringIndexOutOfBoundsException e){
    pastStrings.append("Need ending parenthesis for functions"); 
    return;
  }
  byte bFunc;
  //has argument(s) in args string
  if(func.equals("speed")){
    //change speed to args value
    bFunc = 1;
    int bVal = Integer.parseInt(args);
    println(bVal);
  }else if(func.equals("history")){
    
  }else if(func.equals("pps")){
    
  }else if(func.equals("move")){
    
  }else{
    pastStrings.append("Not a known function, type 'help' for more"); 
  } 
  curString = "";
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



