class Bounds {
  PVector tl;
  PVector tr;
  PVector bl;
  PVector br;
  PVector centre;
  float w;
  float h;
  Line left;
  Line right;
  Line top;
  Line bottom;

  Bounds(PVector tl, PVector br) {
    this.tl = tl;
    this.br = br;
    this.tr = new PVector(br.x, tl.y);
    this.bl = new PVector(tl.x, br.y);
    this.w = br.x - tl.x;
    this.h = br.y - tl.y;
    centre = new PVector(tl.x + (w / 2), tl.y + (h / 2));
    left = new Line(bl, tl);
    right = new Line(tr, br);
    top = new Line(tl, tr);
    bottom = new Line(br, bl);
  }

  Line clipLine (Line line) {
    PVector l = left.secIntersection(line);
    PVector r = right.secIntersection(line);
    PVector t = top.secIntersection(line);
    PVector b = bottom.secIntersection(line);
    PVector start = null;
    PVector end = null;
    
    if (l != null && l.y > top.start.y && l.y < bottom.start.y) {
      if (closer(line.start, line.end, l) == line.start) start = l;
      else end = l;
    }
    if (r != null && r.y > top.start.y && r.y < bottom.start.y) {
      if (start != null) end = r;
      else if (end != null) start = r;
      if (closer(line.start, line.end, r) == line.start) start = r;
      else end = r;
    }
    if (start != null && end != null) return new Line(start, end);

    if (t != null && t.x > left.start.x && t.x < right.start.x) {
      if (start != null) end = t;
      else if (end != null) start = t;
      if (closer(line.start, line.end, t) == line.start) start = t;
      else end = t;
    }
    if (start != null && end != null) return new Line(start, end);

    if (b != null && b.x > left.start.x && b.x < right.start.x) {
      if (start != null) end = b;
      else if (end != null) start = b;
      if (closer(line.start, line.end, b) == line.start) start = b;
      else end = b;
    }
    if (start == null) start = line.start;
    if (end == null) end = line.end;
    return new Line(start, end);
  }
}