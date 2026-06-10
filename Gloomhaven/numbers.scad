$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

include <BOSL2/std.scad>

layer_height = 0.2;
epsilon = 0.001;

side = 33; // 10% increase from 30mm
height = 2.8;
overhang_angle = 45;
overhang_block_width = 5;
front_back_width = 1.6;

depth = 0.6; // depth of floor

module dent() {
  w = 1.4;
  halfw = w/2;
  len = 7;
  translate([0,len/2,0])
  rotate([90,0,0])
  linear_extrude(len) {
    polygon(cumsum([[-halfw,0],[w,0],[-halfw,1.5*halfw]]));
  }
}
            

module number(n="1") {
  delta = [side/2 -height * cos(overhang_angle)-2, side/2-7]; //dent

  difference() {
    cuboid([side,side,height],chamfer=height,edges=[BOTTOM+LEFT,BOTTOM+RIGHT],anchor=BOTTOM);
    translate([0,0,depth])
      cuboid([side-2*overhang_block_width, side - 2*front_back_width, height - depth + epsilon],
             chamfer=height-depth+epsilon,edges=[BOTTOM+LEFT,BOTTOM+RIGHT],anchor=BOTTOM);
    translate([delta.x,delta.y, -epsilon])
      dent();
    translate([delta.x,-delta.y, -epsilon])
      dent();
    translate([-delta.x,delta.y, -epsilon])
      dent();
    translate([-delta.x,-delta.y, -epsilon])
      dent();
  }
  
    translate([delta.x,delta.y, height-0.4])
      dent();
    translate([delta.x,-delta.y, height-0.4])
      dent();
    translate([-delta.x,delta.y, height-0.4])
      dent();
    translate([-delta.x,-delta.y, height-0.4])
      dent();
  
}

number("7");
