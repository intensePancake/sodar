String curString = new String();
int text_size = 14;
StringList queries;
StringList answers;
int historySize;
int iHist = 0;
String[] listFuncs = {"speed(","rpm(","history(","pps(","move(","clear","speed","rpm","history","pps"};

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
      answers.append(String.valueOf(rotSpeed) + " rpm");
    }else if(curString.equals("history")){
      answers.append(Integer.toString(historySize));
    //pings per second
    }else if(curString.equals("pps")){
       
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
  byte bFunc;
  //has argument(s) in args string
  if(func.equals("speed")){
    //change rpm of step motor to args value
    bFunc = 1;
    arduino.write(bFunc);
    try {
      Integer iVal = Integer.parseInt(args);
      if(iVal<=0 || iVal>256){
        answers.append("RPM can only be in range 1 to 256");
        curString = curString.substring(0,curString.indexOf('(')+1);
        return;
      } else {
        //readjust the integer so it fits the -128 to 127
        iVal -= 129;
        byte bVal = iVal.byteValue();
        arduino.write(bVal);
      }
    } catch(NumberFormatException e){
      answers.append("Variable is not an integer value");
    } finally {}

  }else if(func.equals("history")){
    //changes history size
    bFunc = 2; //unnecessary for arduino but I want to give every function a value
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
        answers.append("Variable is not an integer value");
      }
    } finally {}
    
  }else if(func.equals("pps")){
    bFunc = 3;
    arduino.write(bFunc);
    try {
      
    } catch (NumberFormatException e){
      
    }
  }else if(func.equals("move")){
    bFunc = 4;
    arduino.write(bFunc);
    
  }else{
    answers.append("Not a known function, type 'help' for more"); 
  } 
  curString = "";
  if(answers.size() < queries.size()) answers.append("");
}


int sniffLine(String q, int returns, int size){
  //find how many '\n' chars are in q
  if(q != ""){
    String pastTemp = q;
    try {
      while(pastTemp.contains("\n")){
        pastTemp = pastTemp.substring(pastTemp.indexOf('\n')+1);
        returns++;
      }
    } catch (NullPointerException e){
      //don't add because next line is null
      q = q.substring(0,q.indexOf('\n'));
    } 
    return returns;
  }else{
    returns--;
    return returns;
  }
}

void console(){
  fill(255);
  textSize(text_size);
  text('>',width / 2 + 2,height - 7);
  text(curString, width / 2 + 12, height - 7);
  int count = 0;
  for(int i = queries.size() - 1; i >= 0; i--){
    count = sniffLine(queries.get(i),count, 2*(queries.size()-i));
    count = sniffLine(answers.get(i),count, 2*(answers.size()-i)-1);
    text(queries.get(i), width/2 + 2, height - 7 - 21 * (2 * (queries.size()-i) + count));
    text(answers.get(i), width/2 + 2, height - 7 - 21 * (2 * (answers.size()-i) - 1 + count));
  }
  if(millis()%1000<500){
    rect(width / 2 + textWidth('>' + curString) + 2, height - 4, 10, 2);
  }
}
