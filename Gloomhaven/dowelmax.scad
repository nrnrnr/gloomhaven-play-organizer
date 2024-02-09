$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;   // help avoid issues with floating-point rounding error

width = 227;
depth = 132;
height = 30; // xxx temporary

module sunken_cylinder(r, d, h, depth) {
  // runs along X axis, sunk so center line is `depth` below XY plane
  diameter = is_undef(d) ? 2 * r : d;
  radius = diameter / 2;
  sink = is_undef(depth) ? radius : depth;

  translate([0,0,-sink])
    rotate ([0, 90])
    cylinder(r = radius, h = h);
  translate([0,-radius,-sink])
    cube([h, diameter, sink + epsilon]);
}


module small_drill() {
  sunken_cylinder(r=3.5, h=102, depth = 7.25 - 3.5);
  translate([25,0,0]) // offset
    sunken_cylinder(r=10,  h=52, depth = 13.4 - 10);
}

module large_drill() {
  sunken_cylinder(r=5.25, h=140, depth = 10.5 - 5.25);
  translate([25,0,0])
    sunken_cylinder(r=10,  h=60.75, depth = 15 - 10);
}

module registration_pin(small=true) {
  radius = small ? 3.75 : 5.25;
  // depth  = small ? 3.50 : 5.50;
  depth = radius;
  //  sunken_cylinder(r = radius, h=65, depth = small ? 7 - radius : 10.5 - radius);
  sunken_cylinder(r = radius, h=65, depth = depth);
  sunken_cylinder(r = 9, h = 9, depth = depth);
}


module block () {
  drill_stride = 24;
  difference() {
    translate([0,0,-height])
      cube_filleted_columns([width, depth, height], 7.5);
    translate([5, depth - 4*drill_stride + 10, 0])
      union () { // drills
        small_drill();
        translate([0,drill_stride,0])
          small_drill();
        translate([0,2*drill_stride,0])
          large_drill();
        translate([0,3*drill_stride,0])
          large_drill();
    }
    translate([-epsilon,5 + 3.6,0]) // registration rod
      sunken_cylinder(r=3.6,h = width + 2 * epsilon);
    translate([140,20,0])
      rotate([0,0,90])
      union() {
        registration_pin(small=true);
        translate([0,20,0])
          registration_pin(small=false);
    }
  }
}

block();


