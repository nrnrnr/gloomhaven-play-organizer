$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

#include <BOSL2/std.scad>

epsilon = 0.001;


module bad_finned_cylinder(d1, d2, h, thickness) { // d2 is pure fiction
  cyl(d = d1, h = h, anchor = BOTTOM);
  theta = acos(d1/d2);
  N = floor(360/theta);
  phi = 360/N;

  d = d2 * sin(theta) / 2;

  for (angle = [0:phi:359]) {
    rotate([0,0,angle])
    translate([0,d1/2,0])
      cube([d, thickness, h], anchor = BOTTOM + RIGHT + BACK);
  }
  
}


module weird_finned_cylinder(d1, d2, h, thickness) { // d2 is pure fiction
  theta = acos(d1/d2);
  N = floor(360/theta);
  phi = 360/N;

  difference() {
    cyl(d = d2, h = h, anchor = BOTTOM);
    for (angle = [0:phi:359]) {
      rotate([0,0,angle])
        translate([0,d2/2-thickness,-epsilon])
        cube([2 * d2, thickness + 2*epsilon, h], anchor = BOTTOM + RIGHT + BACK);
    }
  }
}

fin_angle = 45;

module finned_cylinder(d1, d2, h, thickness) { // d2 is pure fiction
  intersection() {
    cyl(d = d2, h = h, anchor = BOTTOM);
    union () {
      cyl(d = d1, h = h, anchor = BOTTOM);
      theta = acos(d1/d2) * cos(fin_angle);
      N = floor(360/theta);
      phi = 360/N;

      d = d2 * sin(theta) / 2;

      for (angle = [0:phi:359]) {
        rotate([0,0,angle])
          translate([0,d1/2,0])
          rotate([0,0,-fin_angle])
          cube([d2, thickness, h], anchor = BOTTOM + RIGHT + BACK);
      }
    }
  }
}




// finned_cylinder(25, 27, 50, 0.4);

//finned_cylinder(5, 6.86+0.3, 11.4, 0.4);

//translate([20,0,0]) 

//finned_cylinder(5.9, 6.86+0.3, 11.4, 0.4);


module key() {
  cube([2.4, 5, 5.4], anchor=TOP+FRONT); // x should be 1.8, but make larger
                                         // so tiny weird bits don't stick out
}



intersection() {
  waist = (6.86+0.3-5.6)/2;
  difference () {
    finned_cylinder(5.6, 6.86+0.3, 15.4, 0.4);
    
    translate([0, (6.86+0.3)/2 - 1.8, 15.4+ epsilon])
      key();



    rotate_extrude() {
      polygon(cumsum([[(6.86+0.3)/2 + 10 * epsilon,3.5], [-waist, waist], [waist, waist]]));
    }
  }
  cyl(h=15.4, d = 6.86+0.3, anchor= BOTTOM, chamfer2 = 1.2);
}


