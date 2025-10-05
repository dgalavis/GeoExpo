// Magnetic field visualization with heatmap + vector field (arrows) in Processing
// Author: Copilot for dgalavis
// Save your CSV as "sensors.csv" in the "data" folder of your sketch

Table table;
Sensor[] sensors;
int gridSize = 5;      // Size of heatmap grid cell (lower = smoother, slower)
int arrowGrid = 30;    // Distance between arrows in vector field

void setup() {
  size(600, 600);
  table = loadTable("lecturas.csv", "header");
  sensors = new Sensor[table.getRowCount()];
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    float x = row.getFloat("PosX");
    float y = row.getFloat("PosY");
    float bx = row.getFloat("Bx");
    float by = row.getFloat("By");
    float bz = row.getFloat("Bz");
    sensors[i] = new Sensor(x, y, bx, by, bz);
  }
}

void draw() {
  background(20);
  drawInterpolatedHeatmap();
  drawVectorField();
  drawSensorArrows();
  drawSensorPositions();
  drawGrid();
}

// Draws a faint grid like the example image
void drawGrid() {
  stroke(80, 60);
  for (int x = 100; x <= width-100; x += arrowGrid) line(x, 100, x, height-100);
  for (int y = 100; y <= height-100; y += arrowGrid) line(100, y, width-100, y);
}

// Interpolated heatmap over the whole area using IDW
void drawInterpolatedHeatmap() {
  for (int y = 0; y < height; y += gridSize) {
    for (int x = 0; x < width; x += gridSize) {
      float posX = map(x, 100, width-100, -1, 1);
      float posY = map(y, height-100, 100, -1, 1);
      float num = 0;
      float den = 0;
      for (Sensor s : sensors) {
        float dx = posX - s.x;
        float dy = posY - s.y;
        float dist = sqrt(dx*dx + dy*dy) + 0.01;
        float w = 1.0 / (dist*dist);
        num += w * s.magnitude();
        den += w;
      }
      float interpMag = num / den;
      float normMag = map(interpMag, 0, 60, 0, 1); // Adjust 60 to your max expected value
      int c = lerpColor(color(0,0,255), color(255,0,0), constrain(normMag, 0, 1));
      noStroke();
      fill(c, 60); // Alpha for blending
      rect(x, y, gridSize, gridSize);
    }
  }
}

// Draws a vector field (arrows) interpolating the direction at each grid point
void drawVectorField() {
  stroke(255);
  for (int y = 100; y < height-100; y += arrowGrid) {
    for (int x = 100; x < width-100; x += arrowGrid) {
      float posX = map(x, 100, width-100, -1, 1);
      float posY = map(y, height-100, 100, -1, 1);
      float bx=0, by=0, den=0;
      for (Sensor s : sensors) {
        float dx = posX - s.x;
        float dy = posY - s.y;
        float dist = sqrt(dx*dx + dy*dy) + 0.01;
        float w = 1.0 / (dist*dist);
        bx += w * s.bx;
        by += w * s.by;
        den += w;
      }
      bx /= den;
      by /= den;
      float angle = atan2(by, bx);
      float mag = sqrt(bx*bx + by*by);
      float len = map(mag, 0, 60, 10, arrowGrid*0.8); // Adjust 60 if needed
      pushMatrix();
      translate(x, y);
      rotate(angle);
      strokeWeight(2);
      line(0, 0, len, 0);
      // Arrowhead
      line(len, 0, len-6, -4);
      line(len, 0, len-6, 4);
      popMatrix();
    }
  }
}

// Draws big arrows and magnitude at sensor positions
void drawSensorArrows() {
  for (Sensor s : sensors) {
    float px = map(s.x, -1, 1, 100, width-100);
    float py = map(s.y, -1, 1, height-100, 100);
    float angle = atan2(s.by, s.bx);
    float mag = s.magnitude();
    float len = map(mag, 0, 60, 20, 60);
    pushMatrix();
    translate(px, py);
    rotate(angle);
    stroke(0);
    strokeWeight(3);
    line(0, 0, len, 0);
    line(len, 0, len-12, -7);
    line(len, 0, len-12, 7);
    popMatrix();
    fill(255);
    textAlign(CENTER, TOP);
    text(nf(mag,1,2), px, py+30);
  }
} //jhola

// Draws sensor positions (optional, yellow dots)
void drawSensorPositions() {
  for (Sensor s : sensors) {
    float px = map(s.x, -1, 1, 100, width-100);
    float py = map(s.y, -1, 1, height-100, 100);
    fill(255, 255, 0);
    noStroke();
    ellipse(px, py, 14, 14);
  }
}
