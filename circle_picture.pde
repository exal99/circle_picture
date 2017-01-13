ArrayList<Circle> updatingCircles;
ArrayList<Circle> colitionCircles;
PImage img;
boolean doneCreating;
boolean doneGrowing;
int spawnCount;
int tryCount;
boolean clearScreen;

void setup() {
  size(800, 590);
  img = loadImage("banana.jpg");
  //img.resize(1200, 0);
  println(img.width);
  updatingCircles = new ArrayList<Circle>();
  colitionCircles = new ArrayList<Circle>();
  colorMode(HSB);
  img.loadPixels();
  doneCreating = false;
  doneGrowing = false;
  spawnCount = 50;
  tryCount = 250;
  background(0, 0, 0);
  frameRate(60);
  clearScreen = false;
}

void draw () {
  if (clearScreen) {
    background(0);
    clearScreen = false;
  }

  int created = 0;
  int tryes = 0;
  if (!doneCreating) {
    while (created < spawnCount && tryes < tryCount) {
      Circle newCircle = getNew();
      if (newCircle != null) {
        updatingCircles.add(newCircle);
        colitionCircles.add(newCircle);
        created++;
      }
      tryes++;
    }
    if (tryes == 100) {
      println("FINNISED");
      doneCreating = true;
    }
  }
  doneGrowing = true;
  for (int i = updatingCircles.size() - 1; i > 0; i--) {
    Circle c = updatingCircles.get(i);

    doneGrowing = !c.growing && doneGrowing;
    if (c.growing) {
      for (Circle other : colitionCircles) {
        if (other != c) {
          doneGrowing = c.intersects(other) && doneGrowing;
        }
      }
      c.grow();
    }
    if (!c.growing) {
      updatingCircles.remove(i);
    }
    
    c.setColor();
    c.display();
    
  }

  if (doneGrowing && doneCreating) {
    println("DONE");
    noLoop();
    save("out.png");
  }
  //println(frameRate);
}

Circle getNew() {
  float x = random(width);
  float y = random(height);
  Circle newC = new Circle(x, y);
  for (Circle c : colitionCircles) {
    if (c.intersects(newC)) {
      newC = null;
      break;
    }
  }
  return newC;
}

void keyPressed() {
  if (key == 'f') {
    doneCreating = true;
    println("STOPING");
  }
  if (key == 'r') {
    noLoop();
    doneGrowing = false;
    doneCreating = false;
    colitionCircles = new ArrayList<Circle>();
    updatingCircles = new ArrayList<Circle>();
    clearScreen = true;
    loop();
    println("RESET");
  }
}