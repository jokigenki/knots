static class Knot {
  BandIntersection[] stack = new BandIntersection[0];

  int index;
  static int s_index = 0;
  Knot () {
    index = s_index++;
  }

  // adds an intersection. We do not want to add any intersections if there is already an intersection
  // with the same top
  void addBandIntersection (BandIntersection bandInt) {
    int index = getBandIndex(bandInt.a);
    if (index == -1) stack = (BandIntersection[])append(stack, bandInt);
  }
  
  boolean hasIntersection (BandIntersection intersection) {
    for (BandIntersection check : stack) {
        if (check.matches(intersection)) return true;
    }
    return false;
  }
  
  void moveBandToTop (Band band) {
    moveBandTo(band, 0);
  }
  
  void moveBandDown (Band band) {
     int index = getBandIndex(band);
     if (index == stack.length - 1) return;
     if (index == -1) moveBandTo(band, stack.length);
     else {
       Band underBand = stack[index + 1].a;
       if (!underBand.sorted) moveBandTo(band, index + 1); 
     }
  }
  
  BandIntersection getIntersectionForBand (Band band) {
    int index = getBandIndex(band);
    if (index == -1) return null;
    return stack[index];
  }
  
  int getBandIndex (Band band) { //<>// //<>//
     for (int i = 0; i < stack.length; i++) {
      if (stack[i].a == band) return i; 
     }
     return -1;
  }
  
  Band getFirstUnsortedBandThatIsnt(Band band) {
    for (BandIntersection intersection : stack) {
      if (intersection.a != band && !intersection.a.sorted) return intersection.a;  
    }
    return null;
  }
  
  void moveBandTo (Band band, int index) {
    BandIntersection intersection = removeBand(band);
    if (intersection == null) return;
    if (index >= stack.length) stack = (BandIntersection[])append(stack, intersection);
    else stack = (BandIntersection[])splice(stack, intersection, index);
  }
  
  BandIntersection removeBand (Band band) {
    BandIntersection[] newStack = new BandIntersection[0];
    BandIntersection intersection = null;
    for (int i = 0; i < stack.length; i++) {
      if (stack[i].a != band) {
        newStack = (BandIntersection[])append(newStack, stack[i]);
      } else {
        intersection = stack[i];  
      }
    }
    stack = newStack;
    
    return intersection;
  }
  
  void clip () {
    //print("\nclip " + this);
    for (int i = 0; i < stack.length - 1; i++) {
       for (int j = i + 1; j < stack.length; j++) {
         Band above = stack[i].a;
         Band below = stack[j].a;
         above.clip(below);
       }
    }
  }
  
  String toString() {
    String[] indices = new String[stack.length];
    int i = 0;
    for (BandIntersection band : stack) {
      indices[i++] = band.toString(); 
    }
    return "knot " + index + " [" + join(indices, ", ") + "]"; 
  }
}