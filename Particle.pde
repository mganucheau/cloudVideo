class Particle {
  Body body;
  float r;   // radius
  float dir; // direction

  Particle(float x, float y, float r_, float dir_) {
    r = r_;
    dir = dir_;
    makeBody(x,y,r,dir);   //puts the particle in the Box2d world
  }

  void killBody() {
    box2d.destroyBody(body);  // removes the particle from the box2d world
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);     //finds the screen position of the particle
    if (pos.y < height+10 || pos.y > height-10 || pos.x < width+10 || pos.x > width-10) {
//    if (pos.y < 20 || pos.y > height-20 || pos.x < 20 || pos.x > width-20) {

  killBody();
      return true;
    }
    return false;
  }

  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x,pos.y);
    noStroke();
    fill(100);
    ellipse(0, 0+0.1, 0.05+r*2, 0.1+r*2 );
    popMatrix();
  }

  // adds the particle to the Box2D world
  void makeBody(float x, float y, float r, float dir) {
    BodyDef bd = new BodyDef();  // Define a body
    bd.position = box2d.coordPixelsToWorld(x,y);  // Set its position
    body = box2d.world.createBody(bd);

    CircleDef cd = new CircleDef();     // Make the body's shape a circle
    cd.radius = box2d.scalarPixelsToWorld(r);
    cd.density = .10f;
    cd.friction = 0.02f;
    cd.restitution = 2f;     // Restitution is bounciness
    body.createShape(cd);
    body.setMassFromShapes();  // Always do this at the end

    if (dir == 0) {
      body.setLinearVelocity(new Vec2(random(5f,10f),random(-10f,10f))); // right
    }
    if (dir == 1) {
      body.setLinearVelocity(new Vec2(random(-10f,10f),random(5f,10f))); // up
    }
    if (dir == 3) {
      body.setLinearVelocity(new Vec2(random(-10f,10f),random(-5f,-10f))); // down 
    }
    if (dir == 2) {
      body.setLinearVelocity(new Vec2(random(-5f,-10f),random(-10f,10f))); // left  
    }

  }

}



