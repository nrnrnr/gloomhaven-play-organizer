$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

// measured dimensions of engraved plate

plate_width =  105.39; // 4.146 in, nominal width 105.6mm
plate_height = 62.6; // 2.46in, nominal height 62.8mm
plate_thickness = 3;
engraving_width = 100.4; // nominal 101.6

epsilon = 0.001;

slop = 0.3;

bezel_width = 12;

module cube_filleted_columns(x,y,z,r) {
  if (is_list(x) && is_undef(z)) {
    cube_filleted_columns(x.x, x.y, x.z, y);
  } else {
    union () {
      translate ([r,  r,  0]) cylinder(h=z, r=r);
      translate ([x-r,r,  0]) cylinder(h=z, r=r);
      translate ([r,  y-r,0]) cylinder(h=z, r=r);
      translate ([x-r,y-r,0]) cylinder(h=z, r=r);

      translate([r,     0,  0])  cube([x-2*r, 2*r, z]);
      translate([r, y-2*r,  0])  cube([x-2*r, 2*r, z]);

      translate([0,     r,  0])  cube([2*r, y-2*r, z]);
      translate([x-2*r, r,  0])  cube([2*r, y-2*r, z]);

      translate([r, r, 0]) cube([x-2*r,y-2*r,z]);
    }
  }
}

full_thickness = plate_thickness + 2;
full_width = engraving_width + 2 * bezel_width;
full_height = plate_height + 2 * bezel_width;

difference() {
  cube_filleted_columns(full_width,
                        full_height,
                        full_thickness,
                        6);
  // niche for plate
  translate([(full_width - plate_width) / 2 - slop,
             bezel_width,
             full_thickness - plate_thickness - slop])
  cube([plate_width + slop, plate_height + slop + 20, plate_thickness + slop + epsilon]);
    // + 20 room to slide in

  // window
  translate([bezel_width, bezel_width, -epsilon])
    cube([engraving_width, plate_height + 20, full_thickness + 2 * epsilon]);

}

                      
                      
