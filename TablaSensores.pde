class TablaSensores {
  String[] posiciones = {"(–1, –1)", "(1, –1)", "(–1, 1)", "(1, 1)", "(0,0)", "(0,1)", "(1,0)", "(0,-1)"}; // ajusta según tus sensores

  void display() {
    int x0 = 70, y0 = 130;
    int rowH = 35;
    int colW = 110;
    int cols = 6;
    String[] headers = {"Sensor", "Posición (X,Y)", "Bx (µT)", "By (µT)", "Bz (µT)", "|B| (µT)"};
    fill(40,200); noStroke();
    rect(x0-10, y0-45, colW*cols+20, rowH*(sensors.length+1)+30, 10);

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
