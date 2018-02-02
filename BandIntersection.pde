class BandIntersection {
  Band a;
  Band b;
  PVector location;

  BandIntersection (Band a, Band b, PVector location) {
    this.a = a;
    this.b = b;
    this.location = location;
  }

  boolean matches (BandIntersection other) {
    return (a == other.a && b == other.b) || (b == other.a && a == other.b);
  }
  
  BandIntersection reverse () {
    return new BandIntersection(b, a, location); 
  }
  
  String toString() {
    return "a:" + a + " b:" + b; 
  }
}