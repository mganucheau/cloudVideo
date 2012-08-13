class Blob {
  ArrayList skeleton;  // A list to keep track of all the points in our blob
  float bodyRadius;    // The radius of each body that makes up the skeleton
  float radius;        // The radius of the entire blob
  float totalPoints;   // How many points make up the blob

  Blob() {
    skeleton = new ArrayList();      // Create the empty 
    ConstantVolumeJointDef cvjd = new ConstantVolumeJointDef();     // Let's make a volume of joints!
    Vec2 center = new Vec2(width/2,height/2);     // Where and how big is the blob
    radius = 100;
    totalPoints = 50;
    bodyRadius = 12;

    // Initialize all the points
    for (int i = 0; i < totalPoints; i++) {
      
      float theta = PApplet.map(i, 0, totalPoints, 0, TWO_PI);  // Look polar to cartesian coordinate transformation!
      float x = center.x + radius * cos(theta);
      float y = center.y + radius * sin(theta);

      BodyDef bd = new BodyDef();    // Make each individual body
      bd.fixedRotation = false;      // no rotation!
      bd.position.set(box2d.coordPixelsToWorld(x,y));
      Body body = box2d.createBody(bd);

      CircleDef cd = new CircleDef(); // The body is a circle
      cd.radius = box2d.scalarPixelsToWorld(bodyRadius);
      cd.density = .1f;

      body.createShape(cd);         // Finalize the body
      cvjd.addBody(body);           // Add it to the volume
      body.setMassFromShapes();     // We always do this at the end
      skeleton.add(body);           // Store our own copy for later rendering
    }

    cvjd.frequencyHz = 10.0f;       // control how stiff vs. jiggly the blob iss
    cvjd.dampingRatio = .1f;

    box2d.world.createJoint(cvjd);  // Put the joint thing in our world!
  }

  void display() {
    beginShape();
    noStroke();
    fill(255);
    for (int i = 0; i < skeleton.size(); i++) {
      Body b = (Body) skeleton.get(i);       // We look at each body and get its screen position
      Vec2 pos = box2d.getBodyPixelCoord(b);
      vertex(pos.x,pos.y);     
      ellipse(pos.x, pos.y, 20,20);
      }
    endShape(CLOSE);
  }
  
}













