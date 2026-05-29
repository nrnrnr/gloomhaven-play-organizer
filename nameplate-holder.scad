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
vertical_backing_width = bezel_width - (plate_width - engraving_width)/2;


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

groove_depth=1.6;
groove_width = 2 * groove_depth;

module groove(length) {
  translate([0,0,full_thickness+epsilon])
  linear_sweep([[groove_depth,0], [0,groove_depth], [-groove_depth,0]], length,
               spin=-90, orient=RIGHT);
}

module gluepot(x=0, y=0) {
  translate([x, y, full_thickness+epsilon-groove_depth])
  cylinder(d=2 * groove_width, h=groove_width);
}

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

    // glue grooves
    translate([(vertical_backing_width-groove_width)/2, bezel_width/2, 0])
      groove(full_width-vertical_backing_width+groove_width);
    translate([vertical_backing_width/2, (bezel_width-groove_width)/2, 0])
      rotate([0,0,90])
      groove(full_height-bezel_width+groove_width);
    translate([full_width-(vertical_backing_width/2), (bezel_width-groove_width)/2, 0])
      rotate([0,0,90])
      groove(full_height-bezel_width+groove_width);

    // glue pots
    for (i=[18:22:full_width-10]) {
      gluepot(i, bezel_width/2);
    }
    for (i=[20:20:full_height-5]) {
      gluepot(vertical_backing_width/2,i);
      gluepot(full_width-vertical_backing_width/2,i);
    }
  }
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


top_bezel_slop=0.2;

module top_bezel() {
  diff()
    cuboid([plate_width, bezel_width, full_thickness],
           p1=[0,0,0],
           chamfer=2, edges=TOP+BACK) {
    tag("remove") {
      position(TOP+LEFT)
        cuboid([(plate_width-engraving_width)/2+top_bezel_slop,
                full_height - plate_height - bezel_width + epsilon,
                full_thickness-plate_thickness+top_bezel_slop],
               anchor=TOP+LEFT);
      position(TOP+RIGHT)
        cuboid([(plate_width-engraving_width)/2+top_bezel_slop,
                full_height - plate_height - bezel_width + epsilon,
                full_thickness-plate_thickness+top_bezel_slop],
               anchor=TOP+RIGHT);
    }
  }
}


module assembly() {

  holder();

  % translate([full_width - (full_width - plate_width)/2, full_height - bezel_width, full_thickness])
    rotate([0,180,0])
    top_bezel();
}

holder();

translate([bezel_width-(plate_width-engraving_width)/2, -bezel_width-2, 0])
  top_bezel();




