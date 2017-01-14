import controlP5.*;
import java.awt.event.KeyEvent;

ArrayList<Circle> updatingCircles;
ArrayList<Circle> colitionCircles;
PImage img;
boolean doneCreating;
boolean doneGrowing;
boolean saved;

boolean clearScreen;
PGraphics graphics;


ControlP5 settingsControls;
ControlP5 displayControls;
ControlP5 consoleControls;
Println console;
Textarea consoleText;

int spawnCount;
int tryCount;
boolean meanColor;

boolean ctrl;
boolean v;

String keyBindInfoText = 
"\t---OPTIONS BINDINGS---\n\n" + 
"c\t-\tClears the error messages" + 
"\n\n\n\n" + 
"\t---DISPLAY BINDINGS---\n\n" + 
"b\t-\tReturns back to the options screen\n\t\t(IMPORTANT: THIS WILL DELEATE ANY PROGRESS\n\t\tMADE WITHOUT CONFERMATION!)\n\n" + 
"f\t-\tFinishes the current picture, i.e. stops creating new\n\t\tcircles, and saves the picture\n\n" +
"r\t-\tResets the progress and starts over again\n\t\t(IMPORTANT: THIS WILL DELEATE ANY PROGRESS\n\t\tMADE WITHOUT CONFERMATION!)";

enum Screen {
  OPTIONS, DISPLAY
} 
Screen window;

void setup() {
  //parseTabs("---OPTIONS BINDINGS---\nc\t-\tclears the error messages\n\n---DISPLAY BINDINGS---\nb\t-\treturns back to the options screen");
  size(1200, 800);
  colorMode(HSB);
  background(0, 0, 0);
  frameRate(60);
  saved = false;
  clearScreen = false;
  window = Screen.OPTIONS;
  settingsControls = new ControlP5(this);
  displayControls = new ControlP5(this);
  consoleControls = new ControlP5(this);

  settingsControls.setAutoDraw(false);
  displayControls.setAutoDraw(false);

  createOptionsInterface();
  createDisplayInterface();

  ControlFont temp = consoleControls.getFont();
  temp.setSize(9);
  consoleText = consoleControls.addTextarea("console");
  consoleText.setPosition(20, 40);
  consoleText.setSize(500, 200);
  consoleText.setColor(color(255, 255, 255));
  consoleText.setFont(new ControlFont(createFont("Arial", 30, true)));

  console = consoleControls.addConsole(consoleText);
  
  smooth();
}

void draw () {
  switch (window) {
  case DISPLAY: 
    {
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

      if (doneGrowing && doneCreating && !saved) {
        graphics.save("out.png");
        println("DONE");
        saved = true;
      }
      graphics.endDraw();
      drawGraphic(graphics);
      displayControls.draw();
    } 
    break;
  case OPTIONS:
    background(0);
    settingsControls.draw();

    break;
  }
  console.play();
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
  switch (window) {
  case DISPLAY:
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
      console.clear();
      loop();
      println("RESET");
    }
    if (key == 'b') {
      background(0);
      window = Screen.OPTIONS;
      console.clear();
      consoleText.setColor(color(255, 255, 255));
    }
    break;
  case OPTIONS:
    if (key == ENTER && settingsControls.get(Textfield.class, "filePath").isFocus()) {
      String path = settingsControls.get(Textfield.class, "filePath").getText();
      if (path != "") {
        startDisplay(path);
      }
    }
    if (key == 'c') {
      console.clear();
    }
    
    if (keyCode == CONTROL) {
      ctrl = true;
    }
    if (keyCode == KeyEvent.VK_V) {
      v = true;
    }
    if (ctrl && v && settingsControls.get(Textfield.class, "filePath").isFocus()) {
      ctrl = false;
      v = false;
      println("pasting");
      settingsControls.get(Textfield.class, "filePath").setText(GClip.paste());
    }
    break;
    
  }
}

void keyReleased() {
  if (key == 'v') {
    v = false;
  }
  if (keyCode == CONTROL) {
    ctrl = false;
  }
}

void startDisplay(String fileName) {
  background(0);
  img = loadImage(fileName);
  if (img != null && spawnCount < tryCount) {
    console.clear();
    img.loadPixels();
    graphics = createGraphics(img.width, img.height);
    graphics.smooth();
    updatingCircles = new ArrayList<Circle>();
    colitionCircles = new ArrayList<Circle>();
    doneCreating = false;
    doneGrowing = false;
    meanColor = settingsControls.get(CheckBox.class, "options").getState("Mean Color");
    window = Screen.DISPLAY;
    saved = false;
    consoleText.setColor(color(85, 255, 255));
  } else if (img == null) {
    println("INVALID FILE PATH");
  } else if (spawnCount > tryCount) {
    println("Need to have more tryes than circles created");
  }
}

void createOptionsInterface() {
  Textfield t = settingsControls.addTextfield("filePath");
  t.setText("img.jpg");
  t.setWidth(400);
  t.getValueLabel().setMultiline(false);
  println(t.getValueLabel().getWidth());
  t.setPosition(width/2 - t.getWidth()/2, height/2 - t.getHeight()/2);

  Button b = settingsControls.addButton("start");
  b.setWidth(200);
  b.setHeight(50);
  float xOffset = - 50;
  float yOffset = - 50;
  b.setPosition(width - b.getWidth() + xOffset, height - b.getHeight() + yOffset);
  b.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      String path = settingsControls.get(Textfield.class, "filePath").getText();
      if (path != "") {
        startDisplay(path);
      }
    }
  }
  );

  CheckBox cb = settingsControls.addCheckBox("options");
  cb.addItem("Mean Color", 0);
  cb.setSize(20, 20);
  cb.activate("Mean Color");
  cb.setPosition(width/2 - t.getWidth()/2, height/2 - cb.getHeight()/2 - 60);

  Slider spawn = settingsControls.addSlider("spawnCount");
  spawn.setCaptionLabel("Circles Generated Per Frame (Lower = Better Preformance)");
  spawn.setWidth(300);
  spawn.setHeight(20);
  spawn.setRange(1, 200);
  spawn.setValue(100);
  spawn.setPosition(width/2 - t.getWidth()/2, height/2 - spawn.getHeight()/2 + 60);

  Slider tryes = settingsControls.addSlider("tryCount");
  tryes.setCaptionLabel("Tryes Before Finnishing (Lower = Better Preformance)");
  tryes.setWidth(300);
  tryes.setHeight(20);
  tryes.setRange(50, 2000);
  tryes.setValue(1000);
  tryes.setPosition(width/2 - t.getWidth()/2, height/2 - tryes.getHeight()/2 + 120);

  Textarea keyBindInfo = settingsControls.addTextarea("info");
  keyBindInfo.setSize(500 - t.getWidth()/2 + 30, 400);
  keyBindInfo.setPosition((width/2 - keyBindInfo.getWidth())/2 - 75, 300);
  keyBindInfo.setText(parseTabs(keyBindInfoText));
}

String parseTabs(String msg) {
  String[] lines = split(msg, '\n');
  int tabSize = 20;
  StringBuilder toReturn = new StringBuilder();
  for (int line = 0; line < lines.length; line++) {
    StringBuilder sb = new StringBuilder();
    for (int c = 0; c < lines[line].length(); c++) {
      //println(line, c);
      if (lines[line].charAt(c) == '\t') {
        
        int spaceToAppend = tabSize - (sb.length()) % tabSize;
        for (int i = 0; i < spaceToAppend; i++) {
          sb.append(" ");
        }
      } else {
        sb.append(lines[line].charAt(c));
      }
    }
    toReturn.append(sb.toString() + "\n");
  }
  return toReturn.toString();
}

void createDisplayInterface() {
}