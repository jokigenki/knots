class Segment {
  Line centre;
  Line left;
  Line right;

  Segment(Line centre, Line left, Line right) {
    this.centre = centre;
    this.left = left;
    this.right = right;
  }

  // clip the line by left and right
  // if not clipped, return the original
  // if clipped by one or the other, returns a single line
  // if clipped by both, returns two lines
  Line[] clip(Line clip, Line left, Line right) {
    if (clip == null) return null;
    PVector clippedByLeft = clip.secIntersection(left);
    PVector clippedByRight = clip.secIntersection(right);
    
    // no intersection
    if (clippedByLeft == null && clippedByRight == null) return null;
    
    // one of the intersections matches the start or end point of the original line
    if (clippedByLeft != null
      && (matchVector(clippedByLeft, clip.start) || matchVector(clippedByLeft, clip.end))) return null;
    if (clippedByRight != null
      && (matchVector(clippedByRight, clip.start) || matchVector(clippedByRight, clip.end))) return null;
      
    PVector closerPoint = closer(clippedByLeft, clippedByRight, clip.start);
    if (closerPoint == clippedByLeft) {
      if (clippedByRight == null) {
        if (matchVector(clip.end, clippedByLeft)) return null;
        return new Line[]{new Line(clip.start, clippedByLeft)};
      }
      else return new Line[]{new Line(clip.start, clippedByLeft), new Line(clippedByRight, clip.end)};
    } else {
      if (clippedByLeft == null) {
        if (matchVector(clip.end, clippedByRight)) return null;
        return new Line[]{new Line(clip.start, clippedByRight)};
      }else return new Line[]{new Line(clip.start, clippedByRight), new Line(clippedByLeft, clip.end)};
    }
  }
  
  // clip the other segment against the left and right of this segment
  // if not clipped, return null
  // if only one side is clipped, will clip the other side using a perpendicular line
  // to the clipped line and return 2 segments
  Segment[] clip2 (Segment segment) {
    
    Line[] leftClipped = clip(segment.left, left, right);
    Line[] rightClipped = clip(segment.right, left, right);
    Line[] centreClipped = clip(segment.centre, left, right);
    
    if (leftClipped == null && rightClipped == null) return null;
    if (leftClipped == null) leftClipped = new Line[]{segment.left};
    if (rightClipped == null) rightClipped = new Line[]{segment.right};
    
    // TODO: don't ignore when one line is clipped more than the other
    if (leftClipped.length != rightClipped.length) return null;
    
    Segment[] segments = new Segment[0];
    for (int i = 0; i < leftClipped.length; i++) {
      if (leftClipped[i].length() > 0.01
        && rightClipped[i].length() > 0.01
        && (!leftClipped[i].matches(segment.left) || rightClipped[i].matches(segment.right))) {
        segments = (Segment[])append(segments, new Segment(centreClipped[i], leftClipped[i], rightClipped[i])); 
      }
    }
    if (segments.length == 0) return null;
    return segments;
  }
  
  // clip the other segment against the left and right of this segment
  // if there is no intersection on the centre line,
  // or the centre line start and end points are not modified, return null
  Segment[] clip (Segment segment) {
    // first clip the centre line
    if (segment == null) {
      return null;
    }
    PVector rVsC = segment.centre.secIntersection(right);
    PVector lVsC = segment.centre.secIntersection(left);
    if (rVsC == null && lVsC == null) return null;
    boolean segmentPassesThrough = lVsC != null && rVsC != null;
    boolean hitsLeftFirst = lVsC != null && (rVsC == null || closer(lVsC, rVsC, segment.centre.start) == lVsC);

    Segment firstSegment = null;
    Segment secondSegment = null;
    if (hitsLeftFirst) {
      if (matchVector(lVsC, segment.centre.end)) {
        return null;
      }
      PVector lVsL = segment.left.secIntersection(left);
      PVector lVsR = segment.right.secIntersection(left);
      if (lVsL == null || lVsR == null) {
        return null;
      }
      if (!matchVector(segment.centre.start, lVsC)) {
        Line newC = new Line(segment.centre.start, lVsC);
        Line newL = new Line(segment.left.start, lVsL);
        Line newR = new Line(segment.right.start, lVsR);
        firstSegment = new Segment(newC, newL, newR);
      }
    } else {
      if (matchVector(rVsC, segment.centre.end)) {
        return null;
      }
      PVector rVsL = segment.left.secIntersection(right);
      PVector rVsR = segment.right.secIntersection(right);
      if (rVsL == null || rVsR == null) {
        return null;
      }
      if (!matchVector(segment.centre.start, rVsC)) {
        Line newC = new Line(segment.centre.start, rVsC);
        Line newL = new Line(segment.left.start, rVsL);
        Line newR = new Line(segment.right.start, rVsR);
        firstSegment = new Segment(newC, newL, newR);
      }
    }

    if (!segmentPassesThrough) {
      if (firstSegment == null) return null;
      return new Segment[]{firstSegment};
    } else {
      if (rVsC != null && hitsLeftFirst) {
        PVector rVsL = segment.left.secIntersection(right);
        PVector rVsR = segment.right.secIntersection(right);
        if (rVsL == null || rVsR == null) {
          return null;
        }
        if (!matchVector(rVsC, segment.centre.end)) {
          Line newC = new Line(rVsC, segment.centre.end);
          Line newL = new Line(rVsL, segment.left.end);
          Line newR = new Line(rVsR, segment.right.end);
          secondSegment = new Segment(newC, newL, newR);
        }
      } else if (lVsC != null) {
        PVector lVsL = segment.left.secIntersection(left);
        PVector lVsR = segment.right.secIntersection(left);
        if (lVsL == null || lVsR == null) {
          return null;
        }
        if (!matchVector(rVsC, segment.centre.end)) {
          Line newC = new Line(lVsC, segment.centre.end);
          Line newL = new Line(lVsL, segment.left.end);
          Line newR = new Line(lVsR, segment.right.end);
          secondSegment = new Segment(newC, newL, newR);
        }
      }
    }
    
    if (firstSegment == null && secondSegment == null) return null;
    if (firstSegment != null && secondSegment != null) return new Segment[]{firstSegment, secondSegment};
    if (firstSegment != null) return new Segment[]{firstSegment};
    else return new Segment[]{secondSegment};
  }

  void draw () {
    //centre.draw(255, 0, 0, true);
    
    /*
    fill(random(128,255), random(128,255), random(128,255), 128);
    beginShape();
    vertex(left.start.x, left.start.y);
    vertex(left.end.x, left.end.y);
    vertex(right.end.x, right.end.y);
    vertex(right.start.x, right.start.y);
    endShape();
    */
    left.draw(0, 0, 0, false);
    right.draw(0, 0, 0, false);
  }
  
  String toString() {
    return "-l:[" + left.start + ", " + left.end + "] r:[" + right.start + ", " + right.end + "]-";
  }
}