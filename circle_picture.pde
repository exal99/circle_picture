ArrayList<Circle> circles;
PImage img;
boolean doneCreating;
boolean doneGrowing;
int spawnCount;
int tryCount;

void setup() {
  size(850, 590);
  img = loadImage("banana.jpg");
  img.resize(1200, 0);
  println(img.width);
  circles = new ArrayList<Circle>();
  colorMode(HSB);
  img.loadPixels();
  doneCreating = false;
  doneGrowing = false;
  spawnCount = 50;
  tryCount = 250;
}

void draw () {
  background(0);
  frameRate(60);
  int created = 0;
  int tryes = 0;
  if (!doneCreating) {
    while (created < spawnCount && tryes < tryCount) {
      Circle newCircle = getNew();
      if (newCircle != null) {
        circles.add(newCircle);
        created++;
      }
      tryes++;
    }
    if (tryes == 100) {
      println("FINNISED");
      doneCreating = true;
    }
  }
  if (doneCreating) {
    println("START");
  }
  doneGrowing = true;
  for (Circle c : circles) {

    doneGrowing = !c.growing && doneGrowing;
    if (doneCreating && c.growing) {
      println(c.growing);
    }
    if (c.growing) {
      for (Circle other : circles) {
        if (other != c) {
          doneGrowing = c.intersects(other) && doneGrowing;
        }
      }
      c.grow();
    }
    c.display();
    c.setColor();
  }

  if (doneGrowing) {
    println("DONE");
    noLoop();
    save("out.png");
  }
}

Circle getNew() {
  float x = random(width);
  float y = random(height);
  Circle newC = new Circle(x, y);
  for (Circle c : circles) {
    if (c.intersects(newC)) {
      newC = null;
      break;
    }
  }
  return newC;
}