use <play-caddy.scad>


octagonclearance = 0.1; // for placing separately printed octagonal pegs in holes
  //                       (needed only for prototype)
  // 0.3 is too loose
  // 0.2 slides with zero resistance but is also a bit loose
  // 0.1 slides with notable friction but not a lot of force;
  //     one end may require sanding

hidden = 16;
pegheight   = 5;      // height of cylindrical part of the peg
spikeheight = 3;      // height of cone ending in peg tip
spiketipdiameter = 0.5;

alignmentholediameter = 3;
alignmentpegclearance = 0.3; // difference in diameter betweeen the hole

epsilon = 0.001;

module peg() {
  diameter = alignmentholediameter - alignmentpegclearance;
  cylinder(h=hidden + epsilon, d = alignmentholediameter - octagonclearance, $fn=8);
  rotate([0,0,-5])
  translate([0,0,hidden])
    union () {
      cylinder(h=pegheight+epsilon, d = diameter);
      translate([0,0,pegheight])
        cylinder(d1=diameter,d2=spiketipdiameter,h=spikeheight+epsilon);
  }
}

module flatpeg() {
  rotate([180-1.5*45,0,0])
  rotate([0,90,0]) peg();
}


flatpeg();
translate([0,7,0])
flatpeg();


