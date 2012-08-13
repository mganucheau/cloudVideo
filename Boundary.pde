class Boundary {
  float x;
  float y;
  float w;
  float h;
  Body b;

  Boundary(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    float box2dW = box2d.scalarPixelsToWorld(w/2);     // Figure out the box2d coordinates
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    Vec2 center = new Vec2(x,y);

    // Define the polygon
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2dW, box2dH);
    sd.density = 0;          // No density means it won't move!
    sd.friction = .0f;
    sd.restitution = 2f;     // Restitution is bounciness

    // Create the body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(center));
    b = box2d.createBody(bd);
    b.createShape(sd);
  }

  // Draw the boundary
  void display() {
    fill(100);
    noStroke();
    rectMode(CENTER);
    rect(x,y,w,h);
  }

}


