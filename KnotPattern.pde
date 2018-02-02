class KnotPattern {
  int subDiv;
  float bandThickness;
  Bounds bounds;
  PVector[] allPoints;
  Band[] allBands;
  Knot[] allKnots;

  KnotPattern(int subDivisions, float bandThickness, Bounds bounds, int i) {
    this.subDiv = subDivisions;
    this.bandThickness = bandThickness;
    this.bounds = bounds;

    buildPointArrays(subDivisions);
    joinPoints(subDivisions + i);
    makeKnots();
    tieKnots();
    makeSegments();
  }

  void draw () {
    textSize(18);
    for (Band band : allBands) {
      band.draw();
      PVector s = band.main.centre.start;
      PVector e = band.main.centre.end;
      fill(0);
      text("" + band.index, s.x, s.y);
      noFill();
      stroke(0);
    }

    for (PVector point : allPoints) {
      stroke(0);
      ellipse(point.x, point.y, 10, 10);
    }
  }

  ///-------------------------------------------------------------------------
  /// POINTS

  PVector[][] getCorners () {
    return new PVector[][]{
      new PVector[]{bounds.bl, bounds.tl}, 
      new PVector[]{bounds.tl, bounds.tr}, 
      new PVector[]{bounds.tr, bounds.br}, 
      new PVector[]{bounds.br, bounds.bl}
    };
  }

  // create a set of points around the circumference of the view
  void buildPointArrays (int subDivisions) {
    PVector[][] corners = getCorners();
    allPoints = new PVector[0];
    boolean yAxis = true;
    for (int px = 0; px < corners.length; px++) {
      PVector[] points = corners[px];
      PVector p1 = points[0];
      PVector p2 = points[1];
      PVector d = p2.copy().sub(p1).div(subDivisions + 1);
      for (int i = 0; i < subDivisions; i++) {
        PVector subPoint = new PVector(p1.x + (d.x * (i + 1)), p1.y + (d.y * (i + 1)), 0);
        allPoints = (PVector[])append(allPoints, subPoint);
      }
      yAxis = !yAxis;
    }
  }

  ///-------------------------------------------------------------------------
  /// BASE LINES

  // using every other point in the circumference, try to connect to a point +offset points away.
  // if the point is already taken, use the next point until we find an empty one.
  void joinPoints (int offset) {
    allBands = new Band[0];
    HashMap<Integer, Boolean> takenPoints = new HashMap<Integer, Boolean>();
    int index = 0;
    for (int i = 0; i < allPoints.length; i+=2) {
      int start = i;
      while (takenPoints.get(start) != null) {
        start++;
        if (start >= allPoints.length) { // we have run out of points!
          return;
        }
      }
      takenPoints.put(start, true);

      int targetStart = (start + offset) % allPoints.length;
      int target = targetStart;
      while (takenPoints.get(target) != null) {
        target = (target + 1) % allPoints.length;
        if (target == targetStart) { // we have run out of points!
          return;
        }
      }
      takenPoints.put(target, true);

      Line centreLine = new Line(allPoints[start], allPoints[target]);//getClockwiseLine(allPoints[start], allPoints[target], centre);
      Band band = createClippedBand(centreLine, bandThickness, bounds);
      band.index = index++;
      allBands = (Band[])append(allBands, band);
    }
  }

  Band createClippedBand (Line centreLine, float lineThickness, Bounds bounds) {
    PVector leftNormal = centreLine.leftNormal(lineThickness / 2);
    PVector rightNormal = centreLine.rightNormal(lineThickness / 2);

    Line left = new Line(centreLine.start.copy().add(leftNormal), centreLine.end.copy().add(leftNormal));
    Line right = new Line(centreLine.start.copy().add(rightNormal), centreLine.end.copy().add(rightNormal));

    return new Band(bounds.clipLine(centreLine), bounds.clipLine(left), bounds.clipLine(right));
  }

  ///-------------------------------------------------------------------------
  /// KNOTS

  // find collisions between lines, and group together any collisions closer than bandThickness / 2 into knots
  void makeKnots () {
    allKnots = new Knot[0];
    BandIntersection[] allIntersections = new BandIntersection[0];
    // get all the collisions between the knots
    int c = 0;
    for (int i = 0; i < allBands.length - 1; i++) {
      for (int j = i + 1; j < allBands.length; j++) {
        BandIntersection intersection = findIntersection(allBands[i], allBands[j]);
        if (intersection != null) {
          allIntersections = (BandIntersection[])append(allIntersections, intersection);
        }
      }
    }

    // iterate all the collisions and bundle any collisions closer than bandThickness
    for (int i = 0; i < allIntersections.length - 1; i++) {
      BandIntersection[] intersections = new BandIntersection[0];
      BandIntersection a = allIntersections[i];
      for (int j = i + 1; j < allIntersections.length; j++) {
        BandIntersection b = allIntersections[j];
        if (matchVector(a.location, b.location, bandThickness / 2)
          && !hasIntersection(b, intersections, allKnots)) {
          intersections = (BandIntersection[])append(intersections, b);
        }
      }
      
      if (intersections.length == 0
        && !hasIntersection(a, intersections, allKnots)) {
        intersections = (BandIntersection[])append(intersections, a);
      }
      
      if (intersections.length > 0) {
        // once we have all of the close intersections, create a knot containing all of these
        Knot knot = new Knot();
        for (BandIntersection intersection : intersections) {
          knot.addBandIntersection(intersection);
          knot.addBandIntersection(intersection.reverse());
        }
        allKnots = (Knot[])append(allKnots, knot);
      }
    }
  }
  
  BandIntersection findIntersection (Band a, Band b) {
    PVector intersection = a.findIntersection(b);
    if (intersection == null) return null;
    return new BandIntersection(a, b, intersection);
  }

  boolean hasIntersection (BandIntersection intersection, BandIntersection[] intersections, Knot[] allKnots) {
    for (BandIntersection check : intersections) {
      if (check.matches(intersection)) return true;
    }
    for (Knot knot : allKnots) {
      if (knot.hasIntersection(intersection)) return true;
    }
    return false;
  }

  // For each band, set the position of the band within each subsequent knot in an over/under pattern.
  // This does not quite produce perfect ties on all bands, but is close enough I think.
  void tieKnots() {
    Band band = allBands[0];
    while (true) {    
      Knot[] sortedKnots = sortKnotsForBand(allKnots, band);
      boolean startWithOver = shouldStartWithOver(sortedKnots);
      if (!band.sorted) tieBand(band, sortedKnots, startWithOver);
      band = getNextBand(allBands, band, sortedKnots);
      if (band == null) return;
    }
  }

  // returns a list of knots in order of distance from the start point of the band
  Knot[] sortKnotsForBand (Knot[] knots, Band band) {
    Knot[] sorted = new Knot[0];
    PVector start = band.main.centre.start;
    for (Knot knot : knots) {
      if (knot.getBandIndex(band) == -1) continue;
      BandIntersection intersection = knot.getIntersectionForBand(band);
      sorted = spliceKnotUsingDistance(band, knot, intersection.location, start, sorted);
    }

    return sorted;
  }

  void printKnots (Knot[] knots, PVector start) {
    for (Knot knot : knots) {
      print(" " + knot + "-" + start.dist(knot.stack[0].location)); 
    }
  }
  
  Knot[] spliceKnotUsingDistance (Band band, Knot knot, PVector location, PVector start, Knot[] sorted) {
    float dist = start.dist(location);
    boolean added = false;
    for (int i = 0; i < sorted.length; i++) {
      Knot sortedKnot = sorted[i];
      PVector sortedLocation = sortedKnot.getIntersectionForBand(band).location;
      float sortedDist = start.dist(sortedLocation);
      if (sortedDist > dist) {
        sorted = (Knot[])splice(sorted, knot, i);
        added = true;
        break;
      }
    }
    if (!added) {
      sorted = (Knot[])append(sorted, knot);
    }
    return sorted;
  }

  // checks the knots for this band, and returns true if the first set over knot we find is on an odd value
  // returns a random value if there are no set knots
  boolean shouldStartWithOver (Knot[] sortedKnots) {
    int firstSortedOverKnot = 0;
    for (Knot knot : sortedKnots) {
      if (knot.stack[0].a.sorted) break;
      firstSortedOverKnot++;
    }

    // i.e. there are no sorted knots
    if (firstSortedOverKnot >= sortedKnots.length) return random(1) > 0.5;

    return firstSortedOverKnot % 2 == 0;
  }

  void tieBand (Band band, Knot[] sortedKnots, boolean useOver) {
    for (Knot knot : sortedKnots) {
      if (!useOver) {
        knot.moveBandDown(band); // if under, move the band down in the stack
      } else {
        if (knot.stack[0].a.sorted) {
          knot.moveBandTo(band, 1); // if top item is already sorted, move to below that
        } else {
          knot.moveBandToTop(band); // otherwise move it to the top
        }
      }
      useOver = !useOver;
    }
    band.sorted = true;
  }

  Band getNextBand(Band[] allBands, Band band, Knot[] sortedKnots) {
    for (Knot knot : sortedKnots) {
      Band nextBand = knot.getFirstUnsortedBandThatIsnt(band);
      if (nextBand != null) {
        return nextBand;
      }
    }

    for (Band aBand : allBands) {
      if (!aBand.sorted) {
        return aBand;
      }
    }

    return null;
  }

  ///-------------------------------------------------------------------------
  /// SEGMENTATION

  void makeSegments () {
    for (Knot knot : allKnots) {
      knot.clip();
    }
  }
}