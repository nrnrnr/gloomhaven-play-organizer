$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

include <BOSL2/std.scad>

module rounded_ring(d, w, angle) {
  theta = angle;
  ring(d = d, ring_width = w, angle = [theta, 360-theta], n = 32);
  r = (d + w)/2; // distance to circle
  translate([r * cos(theta),   r * sin(theta)])
    circle(d = w);
  translate([r * cos(theta), - r * sin(theta)])
    circle(d = w);
}

tolerance = 0.1;
hose_diameter = 5.05 + tolerance;
thickness = 2;
gripper_angle = 60;
  delta_y = hose_diameter + 2 * thickness - 0.2; // distance between grippers

module gripper() {
  rounded_ring(d = hose_diameter, w = thickness, angle = gripper_angle);
}

module grippers(n) {
  r = hose_diameter / 2;
  max_x = (r + thickness/2) * cos(gripper_angle) + thickness/2;
  min_x = - r - thickness; 
  end_center_y = (r + thickness/2) * sin(gripper_angle);

  for (i = [0:n-1]) {
     translate([0, i * delta_y, 0]) gripper();
  }
  for (i = [0:n-2]) {
    translate([min_x, end_center_y + i * delta_y])
      rect([max_x - min_x, delta_y - 2 * end_center_y], anchor=FRONT+LEFT);
  }


  translate([min_x, 0])
    rect([thickness, 9 * (n-1)], anchor = FRONT+LEFT);
}

fullwidth = 120;

module holder(n = 5) {
  r = hose_diameter / 2;
  max_x = (r + thickness/2) * cos(gripper_angle) + thickness/2;
  min_x = - r - thickness; 

  width = (n - 1) * delta_y + hose_diameter + 2 * thickness;

  linear_extrude(15) {
    grippers(n);

    translate([0, fullwidth  - width])
      grippers(n);

    translate([min_x, width - hose_diameter/2 - 2 * thickness])
      rect([max_x - min_x, fullwidth - 2 * width + 2 * thickness], anchor = FRONT + LEFT, rounding=thickness/2);

    translate([min_x, width - hose_diameter/2 - 2 * thickness - 20])
      rect([thickness, fullwidth - 2 * width + 2 * thickness + 40], anchor = FRONT + LEFT);

  }

}


holder();



