
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <Gloomhaven/drawer.scad>  // reusable primitives

epsilon = 0.001;   // help avoid issues with floating-point rounding error
eps_vector = [epsilon, epsilon, epsilon];

frame = [49.5, 30.3, 2.0]; // frame around the front with 1mm clearance
grip  = [45.2, 26.2, 4.0];    // grips the hygrometer tightly
frame_wrap = 4; // distance from edge of frame to edge of block
block = [frame.x + 2 * frame_wrap, frame.y + 2 * frame_wrap, frame.z + grip.z];


magnet_diameter = 8.5;  // diameter for pocket, not magnet itself
magnet_thickness = 2.0;
magnet_separator = 0.40; // thickness of panel separating magnet from front

module magnet_wing(glue, thickness = block.z) {
   // origin at center of magnet pocket
  difference () {
    union () {
      cylinder(r = magnet_diameter, h = thickness);
      translate([-magnet_diameter, -block.y/2, 0])
        cube([magnet_diameter, block.y, thickness]);
    }
    translate([0, -2*magnet_diameter, -epsilon])
      cylinder(r = magnet_diameter, h = thickness + 2*epsilon);
    translate([0,  2*magnet_diameter, -epsilon])
      cylinder(r = magnet_diameter, h = thickness + 2*epsilon);
    if (glue) {
      error("glue not implemented here");
    } else {
      translate([0,0,-thickness-magnet_separator])
        cylinder(d = magnet_diameter, h = 2 * thickness);
    }      
  }
}

module holder (glue=false) {
  difference () {
    union () {
      cube(block);
      translate([block.x + magnet_diameter, block.y/2, 0]) magnet_wing(glue=glue);
      translate([        - magnet_diameter, block.y/2, 0])
        rotate([0,0,180]) magnet_wing(glue=glue);
    }
    translate([frame_wrap, frame_wrap, grip.z])
      union () {
        cube(frame + 2 * eps_vector);
        translate((frame - grip) / 2)
          translate([0,0,-block.z/2-epsilon]) cube(grip + 2 * eps_vector);
    }
  }
}

holder();

//magnet_wing();

