class Sensor {
  float x, y, bx, by, bz;
  Sensor(float x, float y, float bx, float by, float bz) {
    this.x = x;
    this.y = y;
    this.bx = bx;
    this.by = by;
    this.bz = bz;
  }
  float magnitude() {
    return sqrt(bx*bx + by*by + bz*bz);
  }
}
