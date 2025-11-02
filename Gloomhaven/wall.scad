function inches(x) = 25.4 * x;

epsilon = 0.001;

hex_side = inches(0.75);
hex_diameter = inches(1.5);

layer_height = 0.2;

module hex(height=3 * layer_height) {
  cylinder(h = height, d = hex_diameter, $fn = 6);
}

module half_hex(height) {
  difference() {
    hex();
    translate([-hex_diameter, -2 * hex_diameter, -epsilon])
      cube([2 * hex_diameter, 2 * hex_diameter, 10]);
  }
}

wall_thickness = 2;

half_hex();
translate([0, hex_diameter * sin(60), 0]) mirror([0,1,0]) half_hex();
translate([-hex_side/2, (hex_diameter * sin(60) - wall_thickness)/2, 0])
  cube([hex_side, wall_thickness, 20]);

