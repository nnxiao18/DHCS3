import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

int trialCount = 20; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
float movex;
float movey;
float movez;
float moverot;
float movec;
float startx;
float starty;

final int screenPPI = 120; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(400, 700); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  screenZ = inchesToPixels(.2f);
  
  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0)
    startTime = millis();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);

    return;
  }

  if (checkForSuccess()) {
    fill(#00FF00);
    rect(0, 0, 2*width, 90);
  }
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);


  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  movez = t.z;
  
  rotate(radians(t.rotation));
  
  fill(255, 0, 0); //set color to semi translucent
  if(checkForDist()) fill(0,255,0);
  rect(0, 0, t.z, t.z);
  fill(0);
  ellipse(0,0,5,5); //target circle center
  
  //draw lever
  //rotate(radians(225)); //rotate it to one of the corners
  //float leverWidth = t.z/3;
  //float leverHeight = t.z/7;
  //float cSquared = 2 * (float) Math.pow(t.z,2);
  //movec = (float)Math.pow(cSquared,0.5);
  //rect(movec/2 + leverWidth/2, 0, leverWidth, leverHeight);
  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen


  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  fill(0);
  ellipse(0,0,5,5); //target circle center
  
  popMatrix();
  mouseDragged();
  rotate(radians(screenRotation));
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

float calculateAngle(int x1, int y1, int x2, int y2) {
  float dy = y2-y1;
  float dx = x2-x1+1;
  println("dy: " + dy + " dx: " + dx + " deg: " + degrees(atan(dy/dx)));
  return degrees(atan(dy/dx)); 
}

float calculateDist(int x1, int y1, int x2, int y2) {
  float dy = y2-y1;
  float dx = x2-x1+1;
  return (sqrt(sq(dy) + sq(dx))); 
}

float initRotation;
float startingRotation;
float initZ;
float startingZ;
boolean startCenter;

void mousePressed(){
  if (trialIndex < trialCount){
    Target t = targets.get(trialIndex);
    movex = t.x;
    movey = t.y;
    startx = mouseX;
    starty = mouseY;
    initRotation = t.rotation;
    initRotation = t.rotation;
    startingRotation = calculateAngle(width/2,height/2, mouseX, mouseY); 
    initZ = t.z;
    startingZ = calculateDist(width/2,height/2, mouseX, mouseY);
    if (canMove(startx, starty)){ startCenter = true;}
    else startCenter = false;
  }  
}

boolean canMove(float x, float y){
  float halfz = movez/2;
  return (movex - halfz <= (x-width/2)) & ((x-width/2) <= halfz + movex) & (movey - halfz <= (y-height/2)) & ((y-height/2) <= movey+halfz);
}

void mouseDragged()
{
  if (trialIndex < trialCount){
    Target t = targets.get(trialIndex);
    if (mousePressed & startCenter){
      println("here");
      float dx = mouseX - startx;
      float dy = mouseY - starty;
      println(startx, starty, mouseX, mouseY, dx, dy, dx-width/2, dy-height/2,t.x,t.y);
  
      t.x = movex + (dx);
      t.y = movey + (dy);
      println(startx, starty, mouseX, mouseY, dx, dy,t.x,t.y);
    }
    else{
      if (mousePressed & !startCenter){
      float dRotation = calculateAngle(width/2,height/2, mouseX, mouseY) - startingRotation;
    t.rotation = initRotation + dRotation; 
    float dZ = (calculateDist(width/2,height/2, mouseX, mouseY) - startingZ) * 2;
    t.z = constrain(initZ + dZ, inchesToPixels(.15f), inchesToPixels(3f)); 
    }
    }
  }
}

void mouseReleased()
{
  //check to see if user clicked middle of screen
  if (mouseY < 100)
  {
    if (trialIndex==trialCount && userDone==false)
    {
      trialIndex = -1;
      userDone = false;
      finishTime = millis();
      startTime = 0;
    }

    //and move on to next trial
    if (!checkForSuccess() && userDone == false) 
      errorCount++;
    
    trialIndex++;
    
    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

public boolean checkForDist() {
    Target t = targets.get(trialIndex);
    return  dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);
}

public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
    boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	println("Close Enough Distance: " + closeDist);
    println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
	println("Close Enough Z: " + closeZ);
	
	return closeDist && closeRotation && closeZ;	
}



double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }