class Circle{
  //position x, y 
  float x;
  float y;
  //size
  float size;
  // But we also have to make a body for box2d to know about it
  Body b;
  
  //construction
  Circle(float x_, float y_, float size_){
    x = x_;
    y = y_;
    size = size_;
    
    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(size/2);
    float box2dH = box2d.scalarPixelsToWorld(size/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
  }
  
  void display(){
    ellipse(x, y, size, size);
  }
  void killBody() {
    box2d.destroyBody(b);
  }
}