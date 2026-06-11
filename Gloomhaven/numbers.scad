$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

include <BOSL2/std.scad>

layer_height = 0.2;
epsilon = 0.001;

side = 33; // 10% increase from 30mm
height = 2.8;
overhang_angle = 45;
overhang_block_width = 7;
front_back_width = 1.2;

dent_delta = [side/2 -height * cos(overhang_angle)-3, side/2-7];


font = "Beringas Block Military Stencil";

depth = 0.8; // depth of floor

notch_height = height - 4 * layer_height;
notch_depth = notch_height / 3;

module dent() {
  w = 1.4;
  halfw = w/2;
  len = 7;
  translate([0,len/2,0])
  rotate([90,0,0])
  linear_extrude(len) {
    polygon(cumsum([[-halfw,0],[w,0],[-halfw,1.5*halfw]]));
  }
}
            

module notch() { // for top
  h = notch_height;
  d = notch_depth;
  len = side - overhang_block_width - 2 * height;
  translate([-len/2,side/2+epsilon,height/2])
  rotate([180,-90,0])
  linear_extrude(len) {
    polygon(cumsum([[-h/2,0],[h/3,h/3],[h/3,0],[h/3,-h/3]]));
  }
}
  

module number(n="1") {
  delta = dent_delta;

  difference() {
    cuboid([side,side,height],chamfer=height,edges=[BOTTOM+LEFT,BOTTOM+RIGHT],anchor=BOTTOM);
    translate([0,0,depth])
      cuboid([side-2*overhang_block_width, side - 2*front_back_width, height - depth + epsilon],
             chamfer=height-depth+epsilon,edges=[BOTTOM+LEFT,BOTTOM+RIGHT],anchor=BOTTOM);
    translate([delta.x,delta.y, -epsilon])
      dent();
    translate([delta.x,-delta.y, -epsilon])
      dent();
    translate([-delta.x,delta.y, -epsilon])
      dent();
    translate([-delta.x,-delta.y, -epsilon])
      dent();

    notch();


    translate([0,0,-depth/2])
      linear_extrude(2*height)
      text(n, font=font, size=side - 2 * front_back_width, halign = "center",valign="center");



  }


  
    translate([delta.x,delta.y, height-2*layer_height])
      dent();
    translate([delta.x,-delta.y, height-2*layer_height])
      dent();
    translate([-delta.x,delta.y, height-2*layer_height])
      dent();
    translate([-delta.x,-delta.y, height-2*layer_height])
      dent();


  
}

//for (i=[0:4]) {
//  translate([i * (side+3),0,0]) number(str(i));
//}
//for (i=[0:4]) {
//  translate([i * (side+3),side+3,0]) number(str(i+5));
//}
////number("7");

module numbers(ns) {
  n = len(ns);
  for (i=[0:ceil(n/5)-1]) {
    for (j=[0:4]) {
      if (5 * i + j < n) {
        translate([j*(side + 5), i*(side + 5), 0])
          number(str(ns[5*i + j]));
      }
    }
  }
}

//numbers([2,4]);

spring_clearance = 1.5;
spring_thickness = 1.0;
spring_length = side/2 - 2;

color_patch_thickness = 2 * layer_height;

niche3d = [ side+0.10 // clearance
          , side+spring_thickness+notch_depth+0.05
          , height + 3 * layer_height // top clearance
                   + color_patch_thickness // color patch
          ];


walls = 1.6;

outer = [niche3d.x + 2 * walls,
         niche3d.y + 2 * walls,
         niche3d.z + 5];

color_patch_3d = [outer.x - 14, niche3d.y, 2 * color_patch_thickness];


module color_slot() {
  d = 0.8;
  l = outer.x-14;
  translate([-l/2,0,0])
  rotate([90,0,90])
  linear_extrude(l)
    polygon(cumsum([[0,0],[d,0],[0,2*layer_height],[-d,d*sin(35)]]));
}

module stand() {

  difference() {
    union () {
      difference() {
        cuboid(outer,anchor=BOTTOM);
        translate([0,0,outer.z+epsilon-niche3d.z])
          cuboid(niche3d, anchor=BOTTOM);
      }
      translate([outer.x/2,0,outer.z-niche3d.z])
        cuboid([(outer.x-color_patch_3d.x)/2,outer.y,color_patch_thickness],anchor=RIGHT+BOTTOM);
      translate([-outer.x/2,0,outer.z-niche3d.z])
        cuboid([(outer.x-color_patch_3d.x)/2,outer.y,color_patch_thickness],anchor=LEFT+BOTTOM);
    }
    translate([0,outer.y/2-walls-epsilon,outer.z-niche3d.z])
      color_slot();
    translate([side/2+7,0,0])
      cylinder(d=25,h=3*outer.z,anchor=CENTER);
    translate([-(side/2+7),0,0])
      cylinder(d=25,h=3*outer.z,anchor=CENTER);
  }

  // springs

  translate([-(outer.x/2-walls/2),0.5+walls-outer.y/2,outer.z-niche3d.z+0.4])
  rotate([0,0,asin(spring_clearance/spring_length)])
  cuboid([spring_length,spring_thickness,height-2*layer_height],anchor=LEFT+BACK+BOTTOM);

  translate([outer.x/2-walls/2,0.5+walls-outer.y/2,outer.z-niche3d.z+0.4])
  rotate([0,0,-asin(spring_clearance/spring_length)])
  cuboid([spring_length,spring_thickness,height-2*layer_height],anchor=RIGHT+BACK+BOTTOM);


  // engagement with notch
  translate([0,outer.y/2-side/2-walls+0.3,outer.z-niche3d.z+color_patch_thickness])
    notch();
}


module stands(n=1) {
  for (i=[0:n-1]) {
    translate([0,i * (outer.y-walls),0])
      stand();
  }
}

module color_patch() {
  cuboid(color_patch_3d, anchor=BOTTOM);
}

module patches(n=10) {
  for (i=[0:floor(n/5)-1]) {
    for (j=[0:4]) {
      if (5 * i + j < n) {
        translate([j*side, i*(side + 5), 0])
          color_patch();
      }
    }
  }
}

//patches(10);




          
numbers("01112223");
// 3345");
