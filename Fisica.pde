// --- VISUALIZACIÓN DE CAMPO MAGNÉTICO INTERACTIVA ---
Table table;
Sensor[] sensors;
int gridSize = 5;      
int arrowGrid = 30;

boolean mostrarTabla = false;

// Área de visualización y sketch
int areaVizW = 850;  
int areaVizH = 600;
int barraH = 90;        
int sketchW = areaVizW;
int sketchH = areaVizH + barraH;

// Colores para los niveles de campo
color azulOscuro, verde, amarillo, rojo;

boolean mostrarHeatmap = true;
boolean mostrarVectorGrid = true;

TablaSensores tabla; 

void setup() {
  size(850, 850);
  azulOscuro = color(0, 0, 139);
  verde      = color(0, 200, 0);
  amarillo   = color(255,255,0);
  rojo       = color(255,0,0);

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
  textFont(createFont("Arial", 15));
  tabla = new TablaSensores(); // <--- inicializa la tabla
}

void draw() {
  background(20);

  // Dibuja la barra negra 
  noStroke();
  fill(30);
  rect(0, areaVizH, sketchW, barraH);

  drawButtons();

  if (!mostrarTabla) {
    pushMatrix();
    clip(0, 0, areaVizW, areaVizH);
    if (mostrarHeatmap && !mostrarVectorGrid) {
      drawInterpolatedHeatmap();
    } else if (!mostrarHeatmap && mostrarVectorGrid) {
      drawGrid();
      drawVectorField();
      drawSensorArrows();
      drawSensorPositions();
    } else if (mostrarHeatmap && mostrarVectorGrid) {
      drawInterpolatedHeatmap();
      drawGrid();
      drawVectorField();
      drawSensorArrows();
      drawSensorPositions();
    }
    noClip();
    popMatrix();
    stroke(100);
    line(0, areaVizH, sketchW, areaVizH);
  } else {
    tabla.display(); 
  }
}

// Botones Configuración
void drawButtons() {
  int bx1 = 200; // desde el borde izquierdo
  int by  = areaVizH + (barraH/2) - 20; // Centrado en la barra de abajo
  int bW  = 160;
  int bH  = 40;
  int sep = 40 + 40; // Espacio entre botones

  // Botón Heatmap
  fill(mostrarHeatmap ? color(100, 200, 255) : 180);
  stroke(60);
  rect(bx1, by, bW, bH, 8);
  fill(0);
  noStroke();
  textAlign(CENTER, CENTER);
  text("Mapa de Intensidad", bx1 + bW/2, by + bH/2);

  // Botón Vector+cuadrícula
  int bx2 = bx1 + bW + sep;
  fill(mostrarVectorGrid ? color(255, 180, 100) : 180);
  stroke(60);
  rect(bx2, by, bW, bH, 8);
  fill(0);
  noStroke();
  text("Campo Vectorial", bx2 + bW/2, by + bH/2);
  
  //Botón tabla
  int bx3 = bx2 + bW + sep;
  fill(mostrarTabla ? color(200, 220, 120) : 180);
  stroke(60);
  rect(bx3, by, bW, bH, 8);
  fill(0);
  noStroke();
  text("Tabla", bx3 + bW/2, by + bH/2);
}

void mousePressed() {
  int bx1 = 200;
  int by = areaVizH + (barraH/2) - 20;
  int bW = 160;
  int bH = 40;
  int sep = 40 + 40;
  int bx2 = bx1 + bW + sep;
  int bx3 = bx2 + bW + sep; 

  if (mouseX > bx1 && mouseX < bx1+bW && mouseY > by && mouseY < by+bH)
    mostrarHeatmap = !mostrarHeatmap;
  if (mouseX > bx2 && mouseX < bx2+bW && mouseY > by && mouseY < by+bH)
    mostrarVectorGrid = !mostrarVectorGrid;  
  if (mouseX > bx3 && mouseX < bx3+bW && mouseY > by && mouseY < by+bH)
    mostrarTabla = !mostrarTabla;
}

// Dibujo de la gráfica adaptado al área 
void drawGrid() {
  stroke(80, 60);
  for (int x = 100; x <= areaVizW-100; x += arrowGrid) line(x, 100, x, areaVizH-100);
  for (int y = 100; y <= areaVizH-100; y += arrowGrid) line(100, y, areaVizW-100, y);
}

void drawInterpolatedHeatmap() {
  for (int y = 0; y < areaVizH; y += gridSize) {
    for (int x = 0; x < areaVizW; x += gridSize) {
      float posX = map(x, 100, areaVizW-100, -1, 1);
      float posY = map(y, areaVizH-100, 100, -1, 1);
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
      float t1 = 10, t2 = 25, t3 = 40;
      color c;
      if (interpMag < t1) {
        c = azulOscuro;
      } else if (interpMag < t2) {
        float amt = map(interpMag, t1, t2, 0, 1);
        c = lerpColor(azulOscuro, verde, amt);
      } else if (interpMag < t3) {
        float amt = map(interpMag, t2, t3, 0, 1);
        c = lerpColor(verde, amarillo, amt);
      } else {
        float amt = map(interpMag, t3, 60, 0, 1);
        c = lerpColor(amarillo, rojo, amt);
      }
      noStroke();
      fill(c, 60);
      rect(x, y, gridSize, gridSize);
    }
  }
}

void drawVectorField() {
  stroke(255);
  for (int y = 100; y < areaVizH-100; y += arrowGrid) {
    for (int x = 100; x < areaVizW-100; x += arrowGrid) {
      float posX = map(x, 100, areaVizW-100, -1, 1);
      float posY = map(y, areaVizH-100, 100, -1, 1);
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
      float len = map(mag, 0, 60, 10, arrowGrid*0.8);
      pushMatrix();
      translate(x, y);
      rotate(angle);
      strokeWeight(2);
      line(0, 0, len, 0);
      line(len, 0, len-6, -4);
      line(len, 0, len-6, 4);
      popMatrix();
    }
  }
}

void drawSensorArrows() {
  for (Sensor s : sensors) {
    float px = map(s.x, -1, 1, 100, areaVizW-100);
    float py = map(s.y, -1, 1, areaVizH-100, 100);
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
}

void drawSensorPositions() {
  for (Sensor s : sensors) {
    float px = map(s.x, -1, 1, 100, areaVizW-100);
    float py = map(s.y, -1, 1, areaVizH-100, 100);
    fill(255, 255, 0);
    noStroke();
    ellipse(px, py, 14, 14);
  }
}
