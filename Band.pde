class Band {

  int index;
  Segment main;
  private Segment[] segments = new Segment[0];
  boolean sorted = false;

  Band (Line centre, Line left, Line right) {
    main = new Segment(centre, left, right);
  }

  void draw () {
    for (Segment segment : segments) {
      segment.draw();
    }
  }

  void addSegment (Line centre, Line left, Line right) {
    Segment seg = new Segment(centre, left, right);
    segments = (Segment[])append(segments, seg);
  }

  // clip all the segments of this band with the main of the given band
  void clip (Band clippedBand) {
    print("\nclip " + clippedBand.index + " with " + index);
    if (index == 1 && clippedBand.index == 2) {
      print("");
    }
    if (index == clippedBand.index) return;
    int count = 0;
    Segment[] segmentsToClip = new Segment[1];
    if (clippedBand.segments.length == 0) segmentsToClip[0] = clippedBand.main;
    else segmentsToClip = clippedBand.segments;
    while (count < segmentsToClip.length) {
      Segment thatSeg = segmentsToClip[count];
      Segment[] clippedSegments = main.clip(thatSeg);
      if (clippedSegments != null) {
        segmentsToClip = replace(segmentsToClip, clippedSegments, count);
        print(" new:");
        for (Segment seg : clippedSegments) {
          print(" " + seg); 
        }
      }
      count++;
    }
    clippedBand.segments = segmentsToClip;
  }

  Segment[] replace (Segment[] oldSegments, Segment[] newSegments, int index) {
    if (index == 0) { 
      return (Segment[])splice((Segment[])subset(oldSegments, 1), newSegments, 0);
    } else if (index < oldSegments.length - 1) {
      Segment[] start = (Segment[])subset(oldSegments, 0, index);
      Segment[] end = (Segment[])subset(oldSegments, index + 1);
      start = (Segment[])splice(start, newSegments, start.length);
      return (Segment[])splice(start, end, start.length);
    }

    Segment[] start = (Segment[])subset(oldSegments, 0, oldSegments.length - 1);
    return (Segment[])splice(start, newSegments, start.length);
  }

  PVector findIntersection(Band otherBand) {
    return main.centre.secSecIntersection(otherBand.main.centre);
  }

  String toString () {
    return "" + index;
  }
}