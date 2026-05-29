$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

#include <BOSL2/std.scad>

epsilon = 0.001;

module bottom() {
  rotate([180,0,0])
  difference() {
    union() {
      cylinder(d1 = 21.1, d2 = 20.8, h = 50); // main
      translate([0,0,30-epsilon])
        cylinder(d1 = 20.8, d2 = 18, h = 5); // tip
      cylinder(d2 = 22.5, d1 = 21.1, h = 1.6); // ring
    }
    translate([0,0,-epsilon])
      cylinder(d = 16, h = 60);
  }
}

module top() {
  tip_width = 21.1;
  extrusion_width = 0.4;
  difference() {
    cylinder(d1=21.1, d2=20.7, h = 15);
    translate([0,0,-epsilon])
      cylinder(d = 16, h = 40);
    translate([0,0,15-5+epsilon])
      cylinder(d1 = 16, d2 = tip_width-2*extrusion_width, h = 5);
  }
}

module part() {

 translate([0,0,15])
   rotate([180,0,0]) {
   top();
   bottom();
 }
}

module halfspace(side=200) {
  cube([side,side,side], anchor=TOP+CENTER);
}

intersection() {
  translate([0,0,30+10])
    rotate([0,60,0])
    halfspace();
  part();
}


