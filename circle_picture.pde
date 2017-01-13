ArrayList<Circle> updatingCircles;
ArrayList<Circle> colitionCircles;
PImage img;
boolean doneCreating;
boolean doneGrowing;
int spawnCount;
int tryCount;
boolean clearScreen;
PGraphics graphics;

void setup() {
  size(1200, 800);

  img = loadImage("img.jpg");
  //img.resize(1200,0);
  graphics = createGraphics(img.width, img.height);

  println(img.width);
  println(graphics.width);
  updatingCircles = new ArrayList<Circle>();
  colitionCircles = new ArrayList<Circle>();
  colorMode(HSB);
  img.loadPixels();
  doneCreating = false;
  doneGrowing = false;
  spawnCount = 100;
  tryCount = 1000;
  background(0, 0, 0);
  frameRate(60);
  clearScreen = false;
}

void draw () {
  graphics.beginDraw();
  graphics.colorMode(HSB);
  if (clearScreen) {
    graphics.background(0);
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
    if (tryes == tryCount) {
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
    graphics.save("out.png");
    graphics.textSize(60);
    graphics.fill(85, 255, 255);
    graphics.text("DONE", 0, 60);
  }
  graphics.endDraw();
  //println(frameRate);
  drawGraphic(graphics);
}

Circle getNew() {
  float x = random(img.width * 1000)/1000;
  float y = random(img.height * 1000)/1000;
  Circle newC = new Circle(x, y);
  for (Circle c : colitionCircles) {
    if (c.intersects(newC)) {
      newC = null;
      break;
    }
  }
  return newC;
}

void drawGraphic(PGraphics g) {
  float prop = ((float)g.width) / ((float) g.height);
  float h = width /prop;
  float w = height * prop;
  if (h <= height) {
    image(g, 0, (height - h)/ 2, width, h);
  } else {
    image(g, (width - w)/2, 0, w, height);
  }
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