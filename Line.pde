class Line {

  PVector start;
  PVector end;

  Line (PVector start, PVector end) {
    this.start = start;
    this.end = end;
    if (start == null || end == null) {
      print("noooo"); //<>// //<>//
    }
  }

  PVector normalised() {
    return end.copy().sub(start).normalize();
  }

  PVector leftNormal (float l) {
    PVector n = normalised();
    return new PVector(n.y * l, -n.x * l);
  }

  PVector rightNormal (float l) {
    PVector n = normalised();
    return new PVector(-n.y * l, n.x * l);
  }

  void draw (int r, int g, int b, boolean arrowHead) {
    stroke(r, g, b);
    strokeWeight(0);
    line(start.x, start.y, end.x, end.y);  

    if (arrowHead) {
      PVector p = end.copy().sub(normalised().mult(8));
      PVector p1 = p.copy().add(leftNormal(4));
      PVector p2 = p.copy().add(rightNormal(4));
      stroke(255, 0, 0);
      line(end.x, end.y, p1.x, p1.y);
      line(end.x, end.y, p2.x, p2.y);
    }
  }

  // returns a point if there is an intersection between the end points of both lines
  PVector secSecIntersection (Line s2) {
    if (s2 == null) return null;
    PVector uAuB = calculateuAuB(s2);
    // if uA and uB are between 0-1, lines are colliding
    if (uAuB.x >= 0 && uAuB.x <= 1 && uAuB.y >= 0 && uAuB.y <= 1) {
      return new PVector(start.x + (uAuB.x * (end.x-start.x)), start.y + (uAuB.x * (end.y-start.y)));
    }
    return null;
  }
  
  // returns a point if there is an intersection between the end points of this line, and an infinite line s2
  PVector secIntersection (Line s2) {
    PVector uAuB = calculateuAuB(s2);
    // if uB is between 0-1, lines are colliding
    if (uAuB.x >= 0 && uAuB.x <= 1) {
      return new PVector(start.x + (uAuB.x * (end.x-start.x)), start.y + (uAuB.x * (end.y-start.y)));
    }
    return null;
  }
  
  PVector calculateuAuB (Line s2) {
    PVector p1 = start;
    PVector p2 = end;
    PVector p3 = s2.start;
    PVector p4 = s2.end;
    // calculate the distance to intersection point
    float uA = ((p4.x-p3.x)*(p1.y-p3.y) - (p4.y-p3.y)*(p1.x-p3.x)) / ((p4.y-p3.y)*(p2.x-p1.x) - (p4.x-p3.x)*(p2.y-p1.y));
    float uB = ((p2.x-p1.x)*(p1.y-p3.y) - (p2.y-p1.y)*(p1.x-p3.x)) / ((p4.y-p3.y)*(p2.x-p1.x) - (p4.x-p3.x)*(p2.y-p1.y));
    return new PVector(uA, uB);
  }

  PVector intersection (Line s2) {
    PVector p1 = start;
    PVector p2 = end;
    PVector p3 = s2.start;
    PVector p4 = s2.end;
    float d = (p1.x - p2.x) * (p3.y-p4.y) - (p1.y-p2.y) * (p3.x-p4.x);
    if (d == 0) return null;
    float xi = ((p3.x-p4.x)*(p1.x*p2.y-p1.y*p2.x)-(p1.x-p2.x)*(p3.x*p4.y-p3.y*p4.x))/d;
    float yi = ((p3.y-p4.y)*(p1.x*p2.y-p1.y*p2.x)-(p1.y-p2.y)*(p3.x*p4.y-p3.y*p4.x))/d;
    return new PVector(xi, yi);
  }
  
  float length () {
    return start.dist(end);
  }
  
  boolean matches (Line other) {
    return (matchVector(start, other.start) && matchVector(end, other.end)); 
  }
  
  public String toString() {
    return start + " - " + end; 
  }
}