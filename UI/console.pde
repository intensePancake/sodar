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
