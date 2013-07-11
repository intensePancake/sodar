String curString = new String();
int text_size = 14;
StringList queries;
StringList answers;
int historySize;
int iHist = 0;
String[] listFuncs = {"speed(","rpm(","history(","pps(","move(","clear","speed","rpm","history","pps",
                      "exit"};
byte bFunc;
boolean scanOn = false;
float scanAng;

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
  //if(n.isEnding)println(s+n.data); //prints all functions in listFuncs
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
  //println(output); //prints the values a tabbed curString could be
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
      queries.append(curString);
      processCmd();
      while(queries.size() > historySize) {
        queries.remove(0);
        answers.remove(0);
      }
      iHist = queries.size();
      break;
    case 8:
      if(curString.length() > 0){
        curString = curString.substring(0, curString.length() - 1);
      }
      break;
      
    case 9:
      //tab functionality
      if(curString.length()>0){
        ArrayList<String>sVals = funcFound(procs);
        if(sVals.size()>0){
          curString = sVals.get(0);
        }
      }
      break;
      
    default:
      if(key == CODED){
        try {
          if(keyCode == UP){
            if(iHist>0)iHist--;
            curString = queries.get(iHist);
          }else if (keyCode == DOWN){
            if(iHist<queries.size()-1){
              iHist++;
              curString = queries.get(iHist);
            }else if (iHist==queries.size()-1) {
              iHist++;
              curString = "";
            }
          } 
        } finally { }
      }
      if(key >= 32 && key <= 127){
        curString += key;
      }
      break;
  }
  console();
}

void processCmd(){
  String func = new String();
  try {
    func = curString.substring(0,curString.indexOf('('));
  } catch (StringIndexOutOfBoundsException e){
    //not a function
    if(curString.equals("help")){
      answers.append("Not yet written.");
    }else if(curString.equals("clear")){
       queries.clear();
       answers.clear(); 
    }else if(curString.equals("speed") || curString.equals("rpm")){
      int rpmAvg = 0;
      for(int i = 0; i < 5; i++) {
        rpmAvg += rpm[i];
      }
      rpmAvg /= 5;
      answers.append(rpmAvg + " rpm");
    }else if(curString.equals("history")){
      answers.append(Integer.toString(historySize));
    //pings per second
    }else if(curString.equals("pps")){
       
    }else if(curString.equals("stop")){
      //stop is a one byte function to arduino
      bFunc = 0;
      arduino.write(bFunc);
    } else if(curString.equals("start")) {
      bFunc = 1;
      arduino.write(bFunc);
    }else if(curString.equals("exit")){
      exit();
    }else{
      answers.append("Not a known function, type 'help' for more"); 
    }
    curString = "";
    return;
  }
  //is a function
  String args = new String();
  try {
    args = curString.substring(curString.indexOf('(')+1,curString.indexOf(')'));
  } catch (StringIndexOutOfBoundsException e){
    answers.append("Need ending parenthesis for functions"); 
    return;
  }
  //has argument(s) in args string
  if(func.equals("speed") || func.equals("rpm")) {
    //change rpm of step motor to args value
    bFunc = 2;
    try {
      Integer iVal = Integer.parseInt(args);
      if(iVal <= 0 || iVal > 255){
        answers.append("RPM can only be in range 1 to 255");
        curString = curString.substring(0,curString.indexOf('(')+1);
        return;
      } else {
        arduino.write(bFunc);
        //readjust the integer so it fits the -128 to 127
        if(iVal >= 128) iVal -= 256;
        byte bVal = iVal.byteValue();
        arduino.write(bVal);
        rpmRequest = bVal;
        resetRPM();
      }
    } catch(NumberFormatException e){
      answers.append("Variable is not a 32-bit integer value");
    } finally {}

  }else if(func.equals("history")){
    //changes history size
    bFunc = 3; //unnecessary for arduino but I want to give every function a value
    try{
      historySize = Integer.parseInt(args);
    } catch (NumberFormatException e){
      if(args.length()==0) {
        if(historySize != (height / 2 - 6) / (text_size + 6)){
          //reset historySize to default
          historySize = (height / 2 - 6) / (text_size + 6);
          answers.append("Reset history size to " + historySize);
        }else{
          answers.append("History size is already default.");
        }
      }else {
        answers.append("Variable is not a 32-bit integer value");
      }
    } finally {}
    
  }else if(func.equals("pps")){
    bFunc = 4;
    try {
      Integer ppsIn = Integer.parseInt(args);
      if(1 <= ppsIn && ppsIn <= 30) {
        byte pps = ppsIn.byteValue();
        arduino.write(bFunc);
        arduino.write(pps);
      } else {
        answers.append("Argument must be between 1 and 30");
      }
    } catch(NumberFormatException e) {
      if(args.length() == 0) {
        byte pps = 20; // default value
        arduino.write(bFunc);
        arduino.write(pps);
      } else {
        answers.append("Stop being stupid.");
      }
    }
    if(args.length()==0){
      //set default pings per second
      byte pps = 20;
      arduino.write(bFunc);
      arduino.write(pps);
    }
    
  }else if(func.equals("move")){
    bFunc = 5;
    try {
      curAng = Float.parseFloat(args);
      //can't be one byte because of 360 degrees, could use 2 bytes if wanted
      arduino.write(bFunc);
      arduino.write(f2B(curAng));
    } catch (NumberFormatException e){
      if(args.length()==0){
        //if no angle specified, use graph to specify one
        cursor(CROSS);
        scanOn = true;
        answers.append("Click to select an angle");
      }else{
        answers.append("Variable is not a 32-bit integer value");
      }
    }
  }else if(func.equals("scan")){
    bFunc = 6;
    arduino.write(bFunc);
    
  }else{
    answers.append("Not a known function, type 'help' for more"); 
  }
  curString = "";
  if(answers.size() < queries.size()) answers.append("");
  
  bFunc = -1;
}

void deltaRPM(int diff)
{
  int req = rpmRequest - diff;
  if(1 <= req && req <= 255) {
    bFunc = 2;
    if(128 <= req && req < 256) req -= 256;
    arduino.write(bFunc);
    arduino.write(byte(req));
    bFunc = -1;
  }
}

void mouseClicked(){
   if(scanOn){
     scanOn = false;
     cursor(ARROW);
     bFunc = 5;
     arduino.write(bFunc);;
     arduino.write(f2B(scanAng));
     bFunc = -1;
   }
}

int sniffLine(String q, int returns, int size){
  //find how many '\n' chars are in q
  if(q != "" && q != null){
    String pastTemp = q;
    try {
      while(pastTemp.contains("\n")){
        pastTemp = pastTemp.substring(pastTemp.indexOf('\n')+1);
        returns++;
      }
    } catch (NullPointerException e){
      //don't add because next line is null
      q = q.substring(0, q.indexOf('\n'));
    }
    return returns;
  }else{
    returns--;
    return returns;
  }
}

void console(){
  // draw console
  fill(0);
  rect(width / 2, height / 2, width / 2, height / 2);
  fill(255);
  textSize(text_size);
  text('>',width / 2 + 2,height - 7);
  text(curString, width / 2 + 12, height - 7);
  int count = 0;
  for(int i = queries.size() - 1; i >= 0; i--){
    if(answers.size() == i) {
      answers.set(i, "");
    }
    String q = queries.get(i);
    String a = answers.get(i);
    count = sniffLine(q, count, 2*(queries.size()-i));
    count = sniffLine(a, count, 2*(answers.size()-i)-1);
    fill(255);
    text(q, width/2 + 2, height - 7 - 21 * (2 * (queries.size()-i) + count));
    text(a, width/2 + 2, height - 7 - 21 * (2 * (answers.size()-i) - 1 + count));
  }
}

