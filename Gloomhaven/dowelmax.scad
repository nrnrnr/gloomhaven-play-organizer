$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;   // help avoid issues with floating-point rounding error

width = 227;
depth = 132;

collar_diameter = 23; // includes room for proud set screws
large_drill_diameter = 10.5;

floor = 1.8; // combined thickness of default top and bottom shells

height = floor + (collar_diameter + large_drill_diameter) / 2;

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

function pin_radius(small) = small ? 3.75 : 5.25;

module small_screw() {
  translate([0,0,1.8])
    mirror([0,0,1])
    union () {
      cylinder(d=3.9, h=9.5+0.8); // 0.8 is extra clearance
      cylinder(d2=3.9,d1=6.6,h=2.8); 
    }
}


small_drill_length = 102;


module small_drill() {
  sunken_cylinder(r=3.5, h=small_drill_length, depth = 7.25 - 3.5);
  translate([25,0,0]) // offset
    sunken_cylinder(d=collar_diameter,  h=52, depth = 13.4 - 10);
}

module large_drill() {
  sunken_cylinder(r=5.25, h=140, depth = 10.5 - 5.25);
  translate([39,0,0])
    sunken_cylinder(d=collar_diameter,  h=60.75, depth = 15 - 10);
}

registration_pin_length = 65;

module registration_pin(small=true) {
  radius = pin_radius(small);
  // depth  = small ? 3.50 : 5.50;
  depth = radius;
  //  sunken_cylinder(r = radius, h=65, depth = small ? 7 - radius : 10.5 - radius);
  sunken_cylinder(r = radius, h=registration_pin_length, depth = depth);
  sunken_cylinder(r = 9, h = 9, depth = depth);
}

module stop_pin() { // make both fit the large pin
  ringdepth = 7; // deeper than original
  translate([0,0,-depth-epsilon])
    cylinder(d = 11, h = depth + 2 * epsilon);

  translate([0,0,-ringdepth])
    cylinder(d = 19.6, h = ringdepth + epsilon);
}  

module alignment(x, y) {
  translate([is_undef(x) ? 0 : x, is_undef(y) ? 0 : y, -height-epsilon])
    cylinder(d=10,h=8);
}

module allen_key(long, short, outside, inside, thickness) {
  // long dimension along positive X, shot along positive Y
  // inside and outside are radii
  //
  // lower insides are more aggressive
  // higher outsides are more aggressive
  translate([0,0,epsilon-thickness])
    difference () {
      union () {
        cube([long, thickness, thickness]);
        cube([thickness, short, thickness]);
        translate([thickness, thickness, 0])
          anti_fillet_sw(r=inside, h=thickness);
      }
      translate([0,0,-epsilon])
        anti_fillet_sw(r=outside, h=thickness + 2 * epsilon);
    }
}

allen_key_lengths = [51.3, 60.5, 62];

module finger_hole() {
  chamfer_h = 6 / sqrt(2);
  translate([0,0,-height-epsilon])
    cylinder(d=25+epsilon,h=height + 2*epsilon);
  translate([0,0,-height-epsilon])
    cylinder(d1 = 25+chamfer_h+epsilon, d2 = 25, h = chamfer_h);
//  translate([0,0,epsilon-chamfer_h])
//    cylinder(d2 = 25+chamfer_h, d1 = 25, h = chamfer_h);

  rcyl = 25/2;
  rfillet = 6;

  difference() {
    rotate_extrude(angle=360)
      translate([rcyl,epsilon-rfillet])
      square(rfillet+epsilon);
    translate([0,0,epsilon-rfillet])
      rotate_extrude(angle=360)
      translate([rcyl+rfillet,0])
      circle(r=rfillet);
  }
}
  

module small_allen_key() {
  allen_key(long = allen_key_lengths[0], short=19, thickness=3, inside = 3, outside = 3);
  // old caddy, inside 3 outside 2.5
  // my measurements, inside 4, outside 3
  // 
}

module medium_allen_key() {
  allen_key(long = allen_key_lengths[1], short=23, thickness=3.8, inside = 5.0, outside = 7.0);
  // old caddy, outside 3 inside 5
  // my estimate inside 5 outside 7
}

module shim() {
  translate([0,0,-3.2])
    cube([86,20,3.2+epsilon]);
}

module pickup_cavity(x, y) {
  translate([0,0,floor-height])
    cube([x,y,height-floor+epsilon]);
}

module allen_key_set() {
  sep = [10,10,0];
  medium_allen_key();
  translate(sep)
    small_allen_key();
}




module block () {
  drill_stride = 25;
  right_y_shift = -5;
  drills_gap = 17;
  difference() {
    translate([0,0,-height])
      cube_filleted_columns([width, depth, height], 7.5);
    drills_y_start = 1 + depth - 4*drill_stride + 10 - drills_gap;
    translate([5, drills_y_start, 0])
      union () { // drills
        small_drill();
        translate([0,drill_stride,0])
          small_drill();
        translate([0,2*drill_stride+drills_gap,0])
          large_drill();
        translate([0,3*drill_stride+drills_gap,0])
          large_drill();
    }
    //stop_screw_y = 2+5+3.6+3.6+2+19.6/2;
    stop_screw_y = drills_y_start + (3 * drill_stride + drills_gap)/2;
    translate([5 + 0.3*small_drill_length, stop_screw_y,0]) small_screw();
    translate([5 + 0.7*small_drill_length, stop_screw_y,0]) small_screw();
    translate([-epsilon,5 + 3.6,0]) // registration rod
      sunken_cylinder(r=3.6,h = width + 2 * epsilon);
    translate([width-5, depth-13+right_y_shift, 0]) // registration pins
      rotate([0,0,180])
        union() {
          registration_pin(small=true);
          translate([0,20,0])
            registration_pin(small=false);
    }
    translate([5+19.6/2,stop_screw_y-4,0]) // stop pins
      union() {
        translate([4,0,0]) stop_pin();
        translate([small_drill_length-19.6-4,0,0])
          stop_pin();
    }
    translate([width-5, 19+right_y_shift+8, 0]) // shim
      mirror([1,0,0]) shim();

    translate([width-5, depth - 46 + right_y_shift, 0]) // allen keys
      rotate([0,0,-180])
      allen_key_set();

    translate([140,55 + right_y_shift, 0]) // allen keys
      allen_key_set();

    translate([width - 55,3,0])  // registration pins, allen keys, shim
      pickup_cavity(20, depth-6);

    translate([5+39,3,0]) // drills
      pickup_cavity(25, depth-6);
    
    translate([105.5,-epsilon,0]) // stop mounted to long right
      pickup_cavity(30, 20+epsilon);


    translate([105.5+15,0.3*depth-5,0])
      union () {
        finger_hole();
        translate([0,19+24-2,0])
          finger_hole();
      }

    if (false) {
      for(x=[10:(width-20)/7-epsilon:width-10]) {
        for(y=[10:(depth-20)/4-epsilon:depth-10]) {
          alignment(x,y);
        }
      }
    } else {
      normal = [[0,0,0],[1,0,0],[0,1,0],[1,1,0]];
      sw     = [[0,0,0],[1,0,0],[0,1,0]];
      for (v=sw) {
        translate([10,10,0] + 25 * v)
          alignment();
      }
      for (v=normal) { // northwest
        translate([10,depth-10-25,0] + 25 * v)
          alignment();
      }
      for (v=[[0,0,0], [1,0,0]]) { // north
        translate([width/2,depth-10,0] + 50 * v)
          alignment();
      }
      for (v=normal) { // southeast
        translate([width-10,10+50,0] - 50 * v)
          alignment();
      }
    }
    

    // xxx check dimensions: allen keys, small screws, shims
    //         2 finger holes
    //           pickup cavities
  }
}


module simple_test() {
  h = 4.6;
  difference () {
    translate([0,0,-h]) cube([68,40,h]);
    translate([3,3,0])
      allen_key_set();
    translate([60,30,0]) small_screw();
    translate([40,28,3]) stop_pin();
  }
}

//simple_test();
block();



