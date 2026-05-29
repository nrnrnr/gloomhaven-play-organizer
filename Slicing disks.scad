$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4/25.4;  // minimum size (fine resolution)


use <Gloomhaven/drawer.scad>

epsilon = 0.0001;

disk_diameter = 160; // mm
disk_thickness_at_rim = 2;
disk_thickness_at_center = 15;

tilt_angle = 75;

shelf_width = 51; // 2 inches

spacing = 20;

base_min_thickness = 1.8;
base_max_thickness = base_min_thickness + shelf_width * cos(tilt_angle);



build_volume = [shelf_width, 3 * (disk_diameter + spacing), 25.4];



module holder () {
  r = (disk_diameter+1)/2.0;
  translate([0.8, 0, base_max_thickness])
  rotate([0, 180 - tilt_angle, 0])
  translate([-r, r + spacing/2, 0])
    cylinder(r=r, h = 2*shelf_width);
}

screw_diameter = 6;
screw_well_diameter = 20;

module tap() {
  translate([0, 0, -0.5 * build_volume.z])
    cylinder(d=screw_diameter+0.6, h = 2 * build_volume.z);
  translate([0, 0, base_min_thickness])
    cylinder(d=screw_well_diameter, h = build_volume.z);
}

difference () {
  cube(build_volume);
  for (i = [0:2]) {
    translate([0, i * (disk_diameter + spacing), 0]) holder();
  }
  for (i = [1:2]) {
    translate([build_volume.x / 2, i * (disk_diameter + spacing), 0]) tap();
  }
}



