
//Derived from http://vivin.net/2010/01/30/generic-n-ary-tree-in-java/

public class GenericTreeNode<T> {

    public T data;
    public ArrayList<GenericTreeNode<T>> children;
    public boolean isEnding;

    public GenericTreeNode() {
        super();
        children = new ArrayList<GenericTreeNode<T>>();
        isEnding = false;
    }

    public GenericTreeNode(T data) {
        this();
        setData(data);
    }

    public ArrayList<GenericTreeNode<T>> getChildren() {
        return this.children;
    }

    public int getNumberOfChildren() {
        return getChildren().size();
    }

    public boolean hasChildren() {
        return (getNumberOfChildren() > 0);
    }

    public void setChildren(ArrayList<GenericTreeNode<T>> children) {
        this.children = children;
    }

    public void addChild(GenericTreeNode<T> child) {
        children.add(child);
    }
    
    public void addChild(T data){
        children.add(new GenericTreeNode(data));
    }
    
    public GenericTreeNode<T> incrChild(T data){
      //if there is a child with data value, return that node, else add new node and return that one
      for(int i = 0; i<this.children.size(); i++){
        if(this.children.get(i).data == data)return this.children.get(i); 
      }
      this.children.add(new GenericTreeNode(data));
      return this.children.get(this.children.size()-1);
    }
    
    public void addChildAt(int index, GenericTreeNode<T> child) throws IndexOutOfBoundsException {
        children.add(index, child);
    }
    
    public void removeChildren() {
        this.children = new ArrayList<GenericTreeNode<T>>();
    }

    public void removeChildAt(int index) throws IndexOutOfBoundsException {
        children.remove(index);
    }

    public GenericTreeNode<T> getChildAt(int index) throws IndexOutOfBoundsException {
        return children.get(index);
    }

    public T getData() {
        return this.data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public String toString() {
        return getData().toString();
    }

    public boolean equals(GenericTreeNode<T> node) {
        return node.getData().equals(getData());
    }

    public int hashCode() {
        return getData().hashCode();
    }
    
}


