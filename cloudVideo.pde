/* ---------------------------------------
cloudVideo 
an interactive cloud controlled by video
by Matt Ganucheau (mganucheau@gmail.com)

Libraries Used: 
pbox2d    - https://github.com/shiffman/PBox2D
controlP5 - http://www.sojamo.de/libraries/controlP5/

Commands:
B - shows/hides boundaries
P - shows/hides particles

This sketch uses code from the following sources:
Blobby - PBox2D example, 2008, Daniel Shiffman.
Webcam Piano - Copyright (c) 2008, Memo Akten, www.memo.tv

*/

import processing.video.*;
import controlP5.*;
import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;

PBox2D box2d;
Blob blob;
ControlP5 controlP5;
Capture video;

ArrayList boundaries;
ArrayList particles;
float theta = 0.0f;
float theta_vel = 0.05f; // speed
int input;
int numPixels;
int gridSizeX;
int gridSizeY;
float[][] gridInfo;
int[] prevGrey;
float totalMovement;
int numGridX = 40;
int numGridY = 40;
float gridSpacing = 0.1;  // spacing of squares 
float vidMult = 0.5;      // ratio of camera resolution to output res
float maxTimeDiff = 5;    // trigger once every 5 seconds  
float gridMult = 1 / vidMult;
float triggerThreshold = 0.02;
float videoAmount = 160;
int fps = 30;

PImage img;
boolean showBoundaries = false;
boolean showParticles = false;

void setup() {
  size(640,480);

  video = new Capture(this, (int) (width * vidMult), (int) (height * vidMult), fps);
  numPixels = video.width * video.height;
  gridSizeX = video.width / numGridX;
  gridSizeY = video.height / numGridY;
  prevGrey = new int[numPixels];
  gridInfo = new float[numGridY][numGridX];

  img = createImage(video.width, video.height, ALPHA);
  frameRate(fps);

  smooth();
  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.setGravity(0,0);

  boundaries = new ArrayList();
  boundaries.add(new Boundary(width/2,10,width,1));          // top
  boundaries.add(new Boundary(width/2,height-10,width,1));   // bottom
  boundaries.add(new Boundary(width-10,height/2,1,height));  // right
  boundaries.add(new Boundary(10,height/2,1,height));        // left

  particles = new ArrayList();
  blob = new Blob();

  int sliderWidth = (int) (width * 0.4);
  controlP5 = new ControlP5(this);
  controlP5.addSlider("triggerThreshold", 0, 1, triggerThreshold, 20, 20, sliderWidth, 15);
  controlP5.addSlider("videoAmount", 1, 255, videoAmount, 20, 40, sliderWidth, 15);
}

void draw() {
  background(170, 213, 255);

  if (video.available()) {
    totalMovement = 0;

    initGridInfo();
    video.read();     // Read the new frame from the camera
    video.loadPixels();
    tint(255, videoAmount);
    img.loadPixels();
    image(video, 0, 0, width, height);
    
    for (int i=0; i<numPixels; i++) {
      int posX = i % video.width;
      int posY = floor(i / video.width);
      int gridX = floor(posX / gridSizeX);
      int gridY = floor(posY / gridSizeY);
      if(gridX >= numGridX) gridX = numGridX - 1;
      if(gridY >= numGridY) gridY = numGridY - 1;
      int gridNo  = gridY * numGridX + gridX;

      color curColor = video.pixels[i];
      int curR = (curColor >> 16) & 0xFF;
      int curG = (curColor >> 8) & 0xFF;
      int curB = curColor & 0xFF;
      
      // average RGB components (there are better ways of calculating intensity from RGB, but this will suffice for these purposes)
      int curGrey = (curR + curG + curB) / 3; 
      int diff = abs(curGrey - prevGrey[i]) ;
      img.pixels[i] = 0xff000000 | (diff << 16) | (diff << 8) | diff;

      gridInfo[gridY][gridX] += diff;
      totalMovement += diff;

      prevGrey[i] = curGrey;
    }

    drawGrid();
    totalMovement /= numPixels * 256;
  }

  box2d.step();
  blob.display();

  if (showBoundaries) {
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary wall = (Boundary) boundaries.get(i);
      wall.display();
    }
  }

  if (showParticles) {
    for (int i = 0; i < particles.size(); i++) {
      Particle p = (Particle) particles.get(i);
      p.display();
    }
  }  

  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = (Particle) particles.get(i);
    if (p.done()) {
      particles.remove(i);
    }
  }

}

void drawGrid() {
  noStroke();
  for(int y=0; y<numGridY; y++) {
    for(int x=0; x<numGridX; x++) {
      float gridMovement = gridInfo[y][x] / (gridSizeX * gridSizeY * 256); 
      if(gridMovement > triggerThreshold)  {
        fill(255, gridMovement * 250 + 50);
        particles.add(new Particle((x * gridSizeX + gridSizeX * gridSpacing/2) * gridMult,(y * gridSizeY + gridSizeY * gridSpacing/2) * gridMult,6,2));
      }  
      else {
        fill(255, 20);
      }

      float newX = (x * gridSizeX + gridSizeX * gridSpacing/2) * gridMult; 
      float newY = (y * gridSizeY + gridSizeY * gridSpacing/2) * gridMult;
      float newGrid = gridSizeX * (1 - gridSpacing) * gridMult;
      rect(newX, newY,newGrid,newGrid);
    }
  }
}

void initGridInfo() {
  for(int y=0; y<numGridY; y++) {
    for(int x=0; x<numGridX; x++) {
      gridInfo[y][x] = 0;
    }
  }
}

void keyPressed() {
  if (key == 'b') {
    showBoundaries = !showBoundaries;
  } 
  else if (key == 'p') {
    showParticles = !showParticles;
  } 
}








