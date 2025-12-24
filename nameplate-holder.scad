include <BOSL2/std.scad>;

$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

layer_height = 0.2;

// measured dimensions of engraved plate

plate_width =  105.39; // 4.146 in, nominal width 105.6mm
plate_height = 62.6; // 2.46in, nominal height 62.8mm
plate_thickness = 3;
engraving_width = 100.4; // nominal 101.6

inch = 25.4;

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

peg_x = (bezel_width + (engraving_width - plate_width)/2)/2;
peg_y = 30;
peg_slop = 0.4;
peg_diameter = 3/16 * inch - peg_slop;
groove_diameter = peg_diameter + 2 * peg_slop;
groove_depth = full_thickness / 3;

module holder() {

  difference() {
    union () {
      cube_filleted_columns(full_width,
                            full_height,
                            full_thickness,
                            6);
      // peg
      translate([peg_x, peg_y, 0])
        //    cylinder(d = 3 / 16 * inch, h = full_thickness + 3);
        cyl(d = peg_diameter - peg_slop, h = full_thickness + 3, chamfer2 = 0.8, anchor=DOWN);
    }
    // niche for plate
    translate([(full_width - plate_width) / 2 - slop,
               bezel_width,
               full_thickness - plate_thickness - slop])
    cube([plate_width + slop, plate_height + slop + 20, plate_thickness + slop + epsilon]);
      // + 20 room to slide in

    // window
    translate([bezel_width, bezel_width, -epsilon])
      cube([engraving_width, plate_height + 20, full_thickness + 2 * epsilon]);

    // registration groove
    translate([peg_x - groove_diameter / 2, peg_y + 1*inch, full_thickness - groove_depth + epsilon])
      cube([groove_diameter, 3 * peg_diameter, groove_depth]);
  }
}

button_thickness = 3*layer_height;

module button() {
  translate([plate_width/2, plate_height/2, 0])
   union() {
    cyl(d = peg_diameter, h = button_thickness + 3 + groove_depth - 0.6,
        chamfer2 = 0.8, anchor=DOWN);
    cyl(d=30, h = button_thickness, anchor=DOWN, chamfer1=button_thickness);
  }
}

button();
