$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

inch = 25.4 ;

internal_diameter = 2.5 * inch + 2 + 5; // needed extra 1/8th inch plus 2 more mm
height = 2.5 * inch;

thickness = 0.6 * 4; // good for 0.6mm nozzle

epsilon = 0.01;   // help avoid issues with floating-point rounding error
eps_vector = [epsilon, epsilon, epsilon];

difference () {
  cylinder(h = height, d = internal_diameter + 2 * thickness);
  translate([0, 0, thickness])
    cylinder(h = height, d = internal_diameter);
}
