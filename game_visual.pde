import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

import java.util.Map;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ConcurrentHashMap;

import ddf.minim.Minim;
import ddf.minim.AudioSample;
import ddf.minim.AudioPlayer;


import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.Tool;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.processing.LeapMotion;
//////////library ends!////////////////////
LeapMotion leapMotion;




int fingers = 0;


ConcurrentMap<Integer, Integer> fingerColors;
ConcurrentMap<Integer, Integer> toolColors;
ConcurrentMap<Integer, Vector> fingerPositions;
ConcurrentMap<Integer, Vector> toolPositions;

// A list we'll use to track fixed objects
ArrayList boundaries;

// A reference to our box2d world
Box2DProcessing box2d;

// Just a single box this time
Box box;

//generate circles
int arraySize = 400;
// circle Array
ArrayList<Circle> cArray = new ArrayList<Circle>();

// record x, y
FloatList xArray = new FloatList();
FloatList yArray = new FloatList();


//visual
int time;
int wait = 1000;
int countTime = 0;
int highScore = 0;
PImage bg;


PImage startBtn;
PImage overBtn;
PImage monster;
PImage monsterDead;
int y;

boolean startGame = false;
boolean gameOver = false;

color c ;

void setup()
{
  size(1000,600);
  frameRate(60);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-80);

  c = color(255,131,125);


  // Add a bunch of fixed boundaries
  boundaries = new ArrayList();
  //boundaries.add(new Boundary(width/4,height-5,width/2-100,10));
  //boundaries.add(new Boundary(3*width/4,height-5,width/2-100,10));
  boundaries.add(new Boundary(width-5,height/2,10,height));
  boundaries.add(new Boundary(5,height/2,10,height));
  leapMotion = new LeapMotion(this);
  fingerPositions = new ConcurrentHashMap<Integer, Vector>();
  
  
  
  //visual
  time = millis();//store the current time
  bg = loadImage("pics/background-01.jpg");
  startBtn = loadImage("pics/startbutton.png");
  overBtn = loadImage("pics/overbutton.png");
  monsterDead = loadImage("pics/f2.png");
  monster = loadImage("pics/f1.png");
  
}

boolean monsterAppear = false;


void draw() {
  background(bg);
  
  // We must always step through time!
  box2d.step();


  // Draw the boundaries
  for (int i = 0; i < boundaries.size(); i++) {
    Boundary wall = (Boundary) boundaries.get(i);
    wall.display();
  }

  //draw fingers
   finger1Position();

  
  //visual
  if(startGame && !gameOver){
    
  if(!monsterAppear){
    box = new Box(width/2, height/10);
    box.display();
    monsterAppear = true;
  }else{
    box.display(); 
  }
    if(millis() - time >= wait){
        time = millis();//also update the stored time
        countTime = countTime + 1;
      }
 

    fill(0);
    if(highScore <= countTime){
      textSize(20);
      fill(c);
      text("High Score: "+String.valueOf(countTime),width-200,30);
      highScore = countTime;
      
    }else{
      textSize(20);
      fill(c);
      text("High Score: "+highScore, width-200,30);
    }
    textSize(35);
    text(String.valueOf(countTime),width-150,80); 
    
  }else if (gameOver && !startGame){
         imageMode(CENTER);    
         image(overBtn, width/2.0, height/2.0);
         image(monsterDead, width*0.7, height*0.75); //base on position of death
         monsterAppear = false;
         textSize(20);
         fill(c);
      text("High Score: "+highScore, width-200,30);
      textSize(35);
      text(String.valueOf(countTime),width-150,80); 
  }else {
       imageMode(CENTER);
       image(startBtn, width/2.0, height/2.0);
        
  }
    //monster dead
 if(box!=null){
    if (box.done()){
      gameOver=true;
      startGame = false;
    }
  }
  

imageMode(CENTER);     
}

// single finger gesture1
void finger1Position(){
   for (Map.Entry entry : fingerPositions.entrySet())
  {
    Integer fingerId = (Integer) entry.getKey();
    Vector position = (Vector) entry.getValue();
    fill(c);
    noStroke();
    float posX = leapMotion.leapToSketchX(position.getX());
    float posY = leapMotion.leapToSketchY(position.getY());
    Circle circle = new Circle(posX, posY, 24.0);
    circle.display();
    //insert fingerpositions into array
    xArray.append(posX);
    yArray.append(posY);
    cArray.add(circle);
    
    //ellipse(leapMotion.leapToSketchX(position.getX()), leapMotion.leapToSketchY(position.getY()), 24.0, 24.0);
  }
  //circles
  for (int i = cArray.size() - 1; i >= 0; i--) {
   Circle cur = cArray.get(i);
   //cur.update();
   cur.display();
   //if the length is too long or there are too many circles
    if((abs(xArray.get(xArray.size()-1) - xArray.get(0)) > arraySize)|| (abs(yArray.get(yArray.size()-1) - yArray.get(0)) > arraySize) || cArray.size() > 30){
      cArray.get(0).killBody();
      cArray.remove(0);
      xArray.remove(0);
      yArray.remove(0);
    }
  }
}

void onInit(final Controller controller)
{
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  // enable background policy
  controller.setPolicyFlags(Controller.PolicyFlag.POLICY_BACKGROUND_FRAMES);
}

void onFrame(final Controller controller)
{
  Frame frame = controller.frame();

 
       fingerPositions.clear();
       for(Finger finger : frame.fingers()){
         int fingerId = finger.id();
         fingerPositions.put(fingerId, finger.tipPosition());
       }
        Finger finger = frame.fingers().get(0);
//Tool tool = frame.tools().get(0);
        fingerPositions.put(1, finger.tipPosition());
        //toolPositions.put(1, tool.tipPosition());
    
   
}


void keyPressed() {
    if (keyCode == ENTER) {
       if(!startGame && !gameOver){
           startGame = true;
           countTime = 0;
       }
       if(!startGame && gameOver){
          gameOver = false;
          startGame = true;
          monsterAppear = false;
          countTime = 0;
          
       }
    }
    
}



