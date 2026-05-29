$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

external_height = 80;
internal_length = 140;
internal_width = 80;  // could go down to 60

thickness = 1.8; // good for 0.6mm nozzle

epsilon = 0.01;   // help avoid issues with floating-point rounding error
eps_vector = [epsilon, epsilon, epsilon];

external_length = internal_length + 2 * thickness;
external_width = internal_width + 2 * thickness;

module negative_quarter (r) {
  translate([0, thickness + epsilon, 0])
  rotate([90, 0, 0])
  difference () {
    cube([r, r, thickness + 2 * epsilon]);
    translate([0, 0, - epsilon])
      cylinder(r = r, h = thickness + 4 * epsilon);
  }
}

  radius = 15;
  midx = external_length / 2;

  module top_curve() {
    translate([midx - 2 * radius + epsilon, 0, external_height - radius + epsilon])
      negative_quarter(radius);
    translate([midx + 2 * radius - epsilon, 0, external_height - radius + epsilon])
      mirror([1, 0, 0])
      negative_quarter(radius);
  }


difference () {
  cube([external_length, external_width, external_height]);
  translate([thickness, thickness, thickness])
    cube([internal_length, internal_width, external_height - thickness + epsilon]);
  translate([midx, external_width + epsilon, radius + thickness + 4])
    rotate([90, 0, 0])
    union ( ) {
      cylinder(h=external_width + 2 * epsilon, r = radius);
      translate([-radius, 0, 0])
        cube([2 * radius, external_height, external_width + 2 * epsilon]);
    }
  top_curve();
  translate([0, external_width - thickness, 0]) top_curve();
  
}


