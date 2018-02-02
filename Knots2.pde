import java.util.Arrays;

int scale = 3;
int w;
int h;

KnotPattern[] patterns;
KnotPattern pat;
void setup() {
  size(1500, 1200);
  w = width / scale;
  h = height / scale;
  background(255);
  noFill();
  strokeWeight(0);

  // one!
  Bounds b = new Bounds(new PVector(100, 100), new PVector(1400, 1100));
  pat = new KnotPattern(8, 15, b, 3);
  print("\nfinished set up\n");

  drawPattern(pat);
  saveFrame();
}

void drawPattern (KnotPattern pattern) {
  stroke(0);
  rect(pattern.bounds.tl.x, pattern.bounds.tl.y, pattern.bounds.w, pattern.bounds.h);
  pattern.draw();
}

static PVector closer (PVector a, PVector b, PVector t) {
  if (b == null) return a;
  if (a == null) return b;
  if (b.dist(t) < a.dist(t)) return b;
  return a;
}

static boolean matchVector (PVector a, PVector b) {
  return (a.dist(b) < 0.001);
}

static boolean matchVector (PVector a, PVector b, float distance) {
  return (a.dist(b) < distance);
}