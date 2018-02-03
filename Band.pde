class Band {

  int index;
  Line centre;
  Line left;
  Line right;
  Line[] lefts = new Line[0];
  Line[] rights = new Line[0];
  boolean sorted = false;

  Band (Line centre, Line left, Line right) {
    this.centre = centre;
    this.left = left;
    this.right = right;
  }

  void draw () {
    for (Line line : lefts) {
      line.draw(0, 0, 0, false);
    }
    
    for (Line line : rights) {
      line.draw(0, 0, 0, false);
    }
}

  void clip (Band clippedBand) {
    if (index == clippedBand.index) return;
    clippedBand.lefts = clipSide(clippedBand.left, clippedBand.lefts);
    clippedBand.rights = clipSide(clippedBand.right, clippedBand.rights);
  }
  
  Line[] clipSide (Line mainToClip, Line[] lines) {
    
    Line[] linesToClip = new Line[1];
    if (lines.length == 0) linesToClip[0] = mainToClip;
    else linesToClip = lines;
        
    int count = 0;
    while (count < linesToClip.length) {
      Line thatLine = linesToClip[count];
      Line[] clippedLines = clipWithLeftAndRight(thatLine, mainToClip);
      if (clippedLines != null) {
        linesToClip = replace(linesToClip, clippedLines, count);
      }
      count++;
    }
    
    return linesToClip;
  }
  
  Line[] clipWithLeftAndRight (Line line, Line main) {
    PVector leftInt = line.secIntersection(left);
    PVector rightInt = line.secIntersection(right);
    // TODO: if the line is wholly enclosed by the left and right, return an empty set to remove the line
    // nullify points if they match the start or end
    if (matchVector(leftInt, line.start) || matchVector(leftInt, line.end)) leftInt = null;
    if (matchVector(rightInt, line.start) || matchVector(rightInt, line.end)) rightInt = null;
    // no intersection or intersection happens only at start or end
    if (leftInt == null && rightInt == null) return null;
    
    // we have an intersection
    // if the section finishes part way between left and right, we will not get second
    Line first = null;
    Line second = null;
    boolean closerToLeft = closer(leftInt, rightInt, main.start) == leftInt;
    
    // line is cut by both sides
    if (leftInt != null && rightInt != null) {
      if (closerToLeft) {
        first = new Line(line.start, leftInt);
        second = new Line(rightInt, line.end);
      } else {
        first = new Line(line.start, rightInt);
        second = new Line(leftInt, line.end);
      }
    } else {
      // single cut, check whether the start of the line is between l+r, or outside
      if (leftInt != null) {
        PVector r2 = line.intersection(right);
        if (closer(leftInt, r2, main.start) == leftInt) {
          first = new Line(line.start, leftInt);  
        } else {
          first = new Line(leftInt, line.end);
        }
      } else {
        PVector l2 = line.intersection(left);
        if (closer(rightInt, l2, main.start) == rightInt) {
          first = new Line(line.start, rightInt);  
        } else {
          first = new Line(rightInt, line.end);
        }
      }
    }
    
    if (second != null) return new Line[]{first, second};
    // line was modified?
    if (matchVector(first.start, line.start) && matchVector(first.end, line.end)) return null;
    return new Line[]{first};
  }

  Line[] replace (Line[] oldLines, Line[] newLines, int index) {
    if (index == 0) {
      return (Line[])splice((Line[])subset(oldLines, 1), newLines, 0);
    } else if (index < oldLines.length - 1) {
      Line[] start = (Line[])subset(oldLines, 0, index);
      Line[] end = (Line[])subset(oldLines, index + 1);
      start = (Line[])splice(start, newLines, start.length);
      return (Line[])splice(start, end, start.length);
    }
    
    Line[] start = (Line[])subset(oldLines, 0, oldLines.length - 1);
    return (Line[])splice(start, newLines, start.length);
  }

  PVector findIntersection(Band otherBand) {
    return centre.secSecIntersection(otherBand.centre);
  }

  String toString () {
    return "" + index;
  }
}