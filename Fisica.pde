// --- VISUALIZACIÓN DE CAMPO MAGNÉTICO INTERACTIVA ---
// Botones para mostrar solo el heatmap, solo flechas+cuadrícula, o ambos

Table table;
Sensor[] sensors;
int gridSize = 5;      // Tamaño de celda de heatmap (más bajo = más suave, más lento)
int arrowGrid = 30;    // Distancia entre flechas en el campo vectorial

// Colores para los niveles de campo
color azulOscuro, verde, amarillo, rojo;

// Variables de visibilidad
boolean mostrarHeatmap = true;
boolean mostrarVectorGrid = true;

void setup() {
  size(850, 850);
  azulOscuro = color(0, 0, 139);   // Azul oscuro (muy débil)
  verde      = color(0, 200, 0);   // Verde (medio)
  amarillo   = color(255,255,0);   // Amarillo (moderado)
  rojo       = color(255,0,0);     // Rojo (muy fuerte)

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
}

void draw() {
  background(20);
  drawButtons();

  // Lógica de visualización según los botones
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
  // Si ninguno está seleccionado, solo se ven los botones
}

// --- Botones ---
void drawButtons() {
  // Botón 1: Heatmap
  fill(mostrarHeatmap ? color(100, 200, 255) : 180);
  stroke(60);
  rect(20, 20, 160, 40, 8);
  fill(0);
  noStroke();
  textAlign(CENTER, CENTER);
  text("Mostrar campo color", 100, 40);

  // Botón 2: Vector+cuadrícula
  fill(mostrarVectorGrid ? color(255, 180, 100) : 180);
  stroke(60);
  rect(200, 20, 200, 40, 8);
  fill(0);
  noStroke();
  text("Mostrar flechas+cuadrícula", 300, 40);
}

void mousePressed() {
  // Botón Heatmap
  if (mouseX > 20 && mouseX < 180 && mouseY > 20 && mouseY < 60) {
    mostrarHeatmap = !mostrarHeatmap;
  }
  // Botón Vector+Grid
  if (mouseX > 200 && mouseX < 400 && mouseY > 20 && mouseY < 60) {
    mostrarVectorGrid = !mostrarVectorGrid;
  }
}

// Dibuja la cuadrícula de fondo
void drawGrid() {
  stroke(80, 60);
  for (int x = 100; x <= width-100; x += arrowGrid) line(x, 100, x, height-100);
  for (int y = 100; y <= height-100; y += arrowGrid) line(100, y, width-100, y);
}

// Heatmap interpolado usando IDW y mapeo multicolor
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

      // Umbrales de color (ajusta según tus datos)
      float t1 = 10;  // Muy débil
      float t2 = 25;  // Medio
      float t3 = 40;  // Moderado
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
        float amt = map(interpMag, t3, 60, 0, 1); // Ajusta "60" a tu valor máximo real
        c = lerpColor(amarillo, rojo, amt);
      }
      noStroke();
      fill(c, 60); // Transparencia
      rect(x, y, gridSize, gridSize);
    }
  }
}

// Campo vectorial interpolado
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
      float len = map(mag, 0, 60, 10, arrowGrid*0.8); // Ajusta "60" si es necesario
      pushMatrix();
      translate(x, y);
      rotate(angle);
      strokeWeight(2);
      line(0, 0, len, 0);
      // Cabeza de flecha
      line(len, 0, len-6, -4);
      line(len, 0, len-6, 4);
      popMatrix();
    }
  }
}

// Flechas y magnitud en los sensores
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
}

// Dibuja las posiciones de sensores
void drawSensorPositions() {
  for (Sensor s : sensors) {
    float px = map(s.x, -1, 1, 100, width-100);
    float py = map(s.y, -1, 1, height-100, 100);
    fill(255, 255, 0);
    noStroke();
    ellipse(px, py, 14, 14);
  }
}
