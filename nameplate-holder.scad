include <BOSL2/std.scad>;

$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

layer_height = 0.2;

// measured dimensions of engraved plate

plate_width =  105.39; // 4.146 in, nominal width 105.6mm
plate_height = 62.6; // 2.46in, nominal height 62.8mm
plate_thickness = 3;
engraving_width = 100.4; // nominal 101.6

wood_thickness = 3;

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
peg_slop = 0.1;
peg_diameter = 3/16 * inch - peg_slop; // in PETG, it's 3/16 minus 0.5mm
groove_diameter = peg_diameter + 2 * peg_slop;
groove_depth = full_thickness / 3;

module holder() {

  difference() {
    union () {
      if (false) { // rounded corners
        cube_filleted_columns(full_width,
                              full_height,
                              full_thickness,
                              6);
      } else {
        cuboid([full_width, full_height, full_thickness],
               p1=[0,0,0],
               chamfer=2, edges=BOT);
      }
      // peg
      translate([peg_x, peg_y, 0])
        cyl(d = peg_diameter - peg_slop, h = full_thickness + wood_thickness, chamfer2 = 0.8, anchor=DOWN);
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
  cyl(d = peg_diameter, h = button_thickness + 3 + groove_depth - 0.6,
      chamfer2 = 0.8, anchor=DOWN);
  cyl(d=30, h = button_thickness, anchor=DOWN, chamfer1=button_thickness);
}



mul=1.0;

module test_round_chamfer() {

difference() {
  union() {
    difference() {
      cuboid([20,20,10], chamfer=2.5, edges=BOT);

    //  translate([7.5,-7.5,-0.5])
    //  cuboid([5+epsilon,5+epsilon,15]);

       translate([0,0,-5.5])
      linear_extrude(11) {
        polygon(points=[[10+epsilon, -(10-(mul*2.5))], [10+epsilon,-10-epsilon], [10-mul*2.5,-10-epsilon]]);
      }
    //  translate([10-2.5,-7.5,-0.5])
    //  cyl(r=2.5,h=11);
        
    }
  translate([10-1*2.5,-(10-1*2.5),0])
    cyl(r=2.5,h=10,rounding1=2.5);
  }
      translate([-10.5,0,5])
      rotate([0,90,0])
      linear_extrude(21) {
        polygon(points=[[10+epsilon, -(10-(mul*2.5))], [10+epsilon,-10-epsilon], [10-mul*2.5,-10-epsilon]]);
      }

      translate([0,-10.5,5])
      rotate([0,90,90])
      linear_extrude(21) {
        polygon(points=[[10+epsilon, -(10-(mul*2.5))], [10+epsilon,-10-epsilon], [10-mul*2.5,-10-epsilon]]);
      }


}

}


//  translate([-10.5,0,5])
//  rotate([0,90,0])
//  linear_extrude(21) {
//    polygon(points=[[10+epsilon, -(10-(mul*2.5))], [10+epsilon,-10-epsilon], [10-mul*2.5,-10-epsilon]]);
//  }
//  translate([10-2.5,-7.5,-0.5])


module slot_test() {
  intersection() {
    holder();
    cuboid([10,20,20], p1=[-1, 52, -1]);
  }
}

//holder();

slot_test();


translate([plate_width/2, plate_height/2, 0])
  button();
