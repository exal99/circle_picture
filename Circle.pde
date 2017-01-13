class Circle {
  float x, y;
  float r;

  boolean growing;
  float growSpeed;

  float hue;
  float sat;
  float bright;
  boolean doneColor;

  Circle(float x, float y) {
    this.x = x;
    this.y = y;
    r = 1;
    growing = true;
    growSpeed = 0.25;
    hue = 0;
    sat = 0; 
    bright = 255;
    doneColor = false;
  }

  boolean toBig() {
    boolean res =  x + r > graphics.width - 2|| x - r < 2 || y + r > graphics.height - 2 || y - r < 2;
    growing = !res && growing;
    return res;
  }

  boolean intersects(Circle c) {
    boolean res =  dist(x, y, c.x, c.y) < r + c.r;
    growing = !res && growing;
    return res;
  }

  void grow() {
    if (growing) {
      r += growSpeed;
    }
  }

  void display() {
    //noFill();
    graphics.fill(hue, sat, bright);
    //graphics.strokeWeight(2);
    //graphics.stroke(hue, sat, bright);
    graphics.noStroke();
    graphics.ellipse(x, y, r*2, r*2);
  }

  void setColor() {
    if (!growing && !doneColor) {
      float hueSum = 0;
      float satSum = 0;
      float brightSum = 0;
      int numPixels = 0;
      for (int x = int(this.x - r); x < this.x + r; x++) {
        for (int y = int(this.y - r); y < this.y + r; y ++) {
          if (x > 0 && x < graphics.width && y > 0 && y < graphics.height && dist(x, y, this.x, this.y) < r) {
            color col = img.pixels[x + y * img.width];
            hueSum += hue(col);
            satSum += saturation(col);
            brightSum += brightness(col);
            numPixels++;
          }
        }
      }
      hue = hueSum / numPixels;
      sat = satSum / numPixels;
      bright = brightSum / numPixels;
      doneColor = true;
    }
  }
}