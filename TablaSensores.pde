class TablaSensores {
  String[] posiciones = {"(–1, –1)", "(1, –1)", "(–1, 1)", "(1, 1)", "(0,0)", "(0,1)", "(1,0)", "(0,-1)"}; // ajustar según los sensores

  void display() {
    int rowH = 35;
    int colW = 110;
    int cols = 6;
    String[] headers = {"Sensor", "Posición (X,Y)", "Bx (µT)", "By (µT)", "Bz (µT)", "|B| (µT)"};
    int tablaAncho = colW * cols;
    int tablaAlto = rowH * (sensors.length + 1) + 30;
    int x0 = (width - tablaAncho) / 2;   
    int y0 = (height - tablaAlto)/2 -70; 
    
    fill(130); 
    noStroke();
    rect(x0-10, y0-35, tablaAncho+20, tablaAlto, 10);

    textAlign(CENTER, CENTER);
    textSize(17);
    fill(240);
    for (int c=0; c<cols; c++) text(headers[c], x0 + c*colW + colW/2, y0);

    fill(220);
    textSize(16);
    for (int i=0; i<sensors.length; i++) {
      Sensor s = sensors[i];
      int rowY = y0 + rowH*(i+1);
      text("S"+(i+1), x0 + colW/2, rowY);
      String pos = (i < posiciones.length) ? posiciones[i] : "(?,?)";
      text(pos, x0 + colW + colW/2, rowY);
      text(nf(s.bx,1,2), x0 + 2*colW + colW/2, rowY);
      text(nf(s.by,1,2), x0 + 3*colW + colW/2, rowY);
      text(nf(s.bz,1,2), x0 + 4*colW + colW/2, rowY);
      text(nf(s.magnitude(),1,2), x0 + 5*colW + colW/2, rowY);
    }
  }
}
