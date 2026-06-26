$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

include <BOSL2/std.scad>

layer_height = 0.2;
epsilon = 0.001;

side = 33; // 10% increase from 30mm
height = 2.8;
overhang_angle = 45;
overhang_block_width = 5.5;
front_back_width = 1.2;

dent_delta = [side/2 -height * cos(overhang_angle)-1.5, side/2-7];


font = "Beringas Block Military Stencil";

depth = 0.8; // depth of floor

notch_height = height - 4 * layer_height;
notch_depth = notch_height / 3;

four_corners = [[1,1,1],[1,-1,1],[-1,-1,1],[-1,1,1]];

module dent(plus=0) {
  w = 1.4;
  halfw = w/2;
  len = 7 + plus;
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
  inset = 0.5 * height; // less sharp than a true chamfer

  difference() {
    translate([0,side/2,0]) // basic block, a partly chamfered cube
      rotate([90,0,0])
      linear_extrude(side) { // y dimension
      polygon(cumsum([[-side/2,0], [side, 0], [-inset, height], [2*inset - side, 0]]));
    }
    translate([0,0,depth])
      cuboid([side-2*overhang_block_width, side - 2*front_back_width, height - depth + epsilon],
             anchor=BOTTOM);
    for (v = four_corners) {
      translate(v_mul(v, [delta.x,delta.y, -epsilon]))
        dent();
    }

    notch();

    if (n != " ") {
      translate([0,0,-depth/2])
        mirror([1,0,0])
        linear_extrude(2*height)
        text(n, font=font, size=side - 2 * front_back_width - 4, halign = "center",valign="center");
    }

  }

  for (v = four_corners) {
    translate(v_mul(v, [delta.x,delta.y, height-2*layer_height]))
      dent();
  }
}


module numbers(ns) {
  stride = 7;
  n = len(ns);
  for (i=[0:ceil(n/stride)-1]) {
    for (j=[0:stride - 1]) {
      if (stride * i + j < n) {
        translate([j*(side + stride), i*(side + stride), 0])
          number(str(ns[stride*i + j]));
      }
    }
  }
}

//numbers([2,4]);

spring_clearance = 2.0; // was 1.5 but springs tired overnight
spring_thickness = 1.0;
spring_length = side/2 - 2;
spring_travel = spring_clearance + spring_thickness;

color_patch_thickness = 2 * layer_height;

niche3d = [ side+0.10 // clearance
          , side+spring_thickness+notch_depth+0.05
          , height + 3 * layer_height // top clearance
//                   + color_patch_thickness // color patch
          ];


walls = 1.6;

stand_outer = [niche3d.x + 2 * walls,
               niche3d.y + 2 * walls,
               17]; // 17mm makes it easy to pick up

color_patch_3d = [stand_outer.x - 14, niche3d.y, 2 * color_patch_thickness];


module color_slot() {
  d = 0.8;
  l = stand_outer.x-14;
  translate([-l/2,0,0])
  rotate([90,0,90])
  linear_extrude(l)
    polygon(cumsum([[0,0],[d,0],[0,2*layer_height],[-d,d*sin(35)]]));
}



color_block_bottom_adjustment = -1.3; // -1.3  // length to add to bottom of color block

module color_block() {
  translate([0,-color_block_bottom_adjustment/2,0])
  cuboid([ side - 2 * overhang_block_width - 2
         , side - 2 * front_back_width - spring_travel + 1.0 + color_block_bottom_adjustment // 1.0 empirical
         , height - depth // exact fit; no room for a color patch
         ], anchor=BOTTOM);
}


module stand() {

  difference() {
    union () {
      difference() {
        cuboid(stand_outer,anchor=BOTTOM);
        translate([0,0,stand_outer.z+epsilon-niche3d.z])
          cuboid(niche3d, anchor=BOTTOM);
      }
//      translate([stand_outer.x/2,0,stand_outer.z-niche3d.z])
//        cuboid([(stand_outer.x-color_patch_3d.x)/2,stand_outer.y,color_patch_thickness],anchor=RIGHT+BOTTOM);
//      translate([-stand_outer.x/2,0,stand_outer.z-niche3d.z])
//        cuboid([(stand_outer.x-color_patch_3d.x)/2,stand_outer.y,color_patch_thickness],anchor=LEFT+BOTTOM);
    }
//    translate([0,stand_outer.y/2-walls-epsilon,stand_outer.z-niche3d.z])
//      color_slot();
    for (v = four_corners) {
      translate(v_mul(v, [dent_delta.x,dent_delta.y, stand_outer.z-niche3d.z+2*epsilon]))
        mirror([0,0,1])
        dent(5);
    }
    translate([side/2+7,0,0])
      cylinder(d=25,h=3*stand_outer.z,anchor=CENTER);
    translate([-(side/2+7),0,0])
      cylinder(d=25,h=3*stand_outer.z,anchor=CENTER);
  }

  // color block
  translate([0,0,stand_outer.z - niche3d.z])
    color_block();
  


  // springs

  translate([-(stand_outer.x/2-walls/2),0.5+walls-stand_outer.y/2,stand_outer.z-niche3d.z+0.4])
  rotate([0,0,asin(spring_clearance/spring_length)])
  cuboid([spring_length,spring_thickness,height-2*layer_height],anchor=LEFT+BACK+BOTTOM);

  translate([stand_outer.x/2-walls/2,0.5+walls-stand_outer.y/2,stand_outer.z-niche3d.z+0.4])
  rotate([0,0,-asin(spring_clearance/spring_length)])
  cuboid([spring_length,spring_thickness,height-2*layer_height],anchor=RIGHT+BACK+BOTTOM);


  // engagement with notch
  translate([0,stand_outer.y/2-side/2-walls+0.3,stand_outer.z-niche3d.z+color_patch_thickness])
    notch();

  

}


module stands(n=1) {
  for (i=[0:n-1]) {
    translate([0,i * (stand_outer.y-walls),0])
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


boxwalls=1.6;

function box_outer(capacity = 10) = [stand_outer.x,stand_outer.y+3, capacity*(height+0.2)+2*boxwalls];
function box_inner(capacity = 10) = [niche3d.x, stand_outer.y+3-2*boxwalls, 2*box_outer(capacity).z]; // sticks out in Z

module box(capacity=10,lip=false) {
  outer = box_outer(capacity);
  inner = box_inner(capacity);

  if (lip) {
    translate([0,-outer.y/2,outer.z]) // retaining lip
    cuboid([outer.x,boxwalls+1,boxwalls],anchor=FRONT+TOP);
  }

  difference() {
    cuboid(outer,anchor=BOTTOM);
    translate([0,0,boxwalls])
      cuboid(inner,anchor=BOTTOM);

    dA=10;
    side_height = 7;
    shift = inner.y/2-(side_height + dA/2);
    
    translate([0,shift,boxwalls])
    rotate([0,90,0])
    cyl(h=2*side, d=dA,anchor=RIGHT);
    translate([0,-shift,boxwalls])
    rotate([0,90,0])
    cyl(h=2*side, d=dA,anchor=RIGHT);

    translate([outer.x/2, 0, boxwalls])
    cuboid([3*boxwalls, 2*shift, outer.z], anchor=BOTTOM);
    translate([-outer.x/2, 0, boxwalls])
    cuboid([3*boxwalls, 2*shift, outer.z], anchor=BOTTOM);

    translate([outer.x/2, 0, boxwalls+dA/2])
    cuboid([3*boxwalls, 2*shift+dA, outer.z], anchor=BOTTOM);
    translate([-outer.x/2, 0, boxwalls+dA/2])
    cuboid([3*boxwalls, 2*shift+dA, outer.z], anchor=BOTTOM);

  }

}

module boxes(n=5,capacity=10,theta=40,phi=15) { // theta = each box, phi = tower
  outer = box_outer(capacity);
  module base(wingdepth=0) {
    rotate([90-theta,0,0])
      translate([0,outer.y/2,0]) {
      box(capacity=capacity,lip=theta<42);
      if (wingdepth > 0) {
        cuboid([outer.x, outer.y, wingdepth],anchor=TOP);
      }
    }
  }

  up_theta = [0,sin(theta),cos(theta)];
  forward_theta = [0,-cos(theta),sin(theta)];
  wd = (outer.y-boxwalls)*sin(theta-phi);

  rear_cut_y =
    (n-1)*(up_theta*(outer.y)+forward_theta*wd).y+n*outer.y*sin(phi) -n*wd*sin(theta);

  echo("boxes rear cut", rear_cut_y);

  if (phi<theta) {
   translate([0,rear_cut_y-epsilon,0])
   half_of(v=[0,-1,-1],cp=-rear_cut_y/sqrt(2)+3,show_frameref=false)
   cuboid([outer.x, rear_cut_y, rear_cut_y], anchor=FRONT+BOTTOM);
  }

//  front_half(y= rear_cut_y, s = 4 * n *outer.y, show_frameref=false)
   {
  for(i=[0:n-1]) {
    top_half(s=2*n*outer.y)
    translate(i*forward_theta*wd)
    translate(i*up_theta*(outer.y-boxwalls))
    if (theta > phi) {
      base(wingdepth=i*wd);
    } else {
      base(wingdepth=(n-i-1)*abs(wd)+n*outer.y*cos(theta));
    }      
  }
   }

//  { i = 4;
////    top_half(s=2*n*outer.y, show_frameref=false)
//    translate(i*forward_theta*wd)
//    translate(i*up_theta*(outer.y-boxwalls)) {
//    if (theta > phi) {
//      base(wingdepth=i*wd);
//    } else {
//      base(wingdepth=(n-i-1)*abs(wd)+n*outer.y*cos(theta));
//    }
//  }
//}


  // front base
  back_half(y=-outer.z*cos(theta))
  top_half(show_frameref=false)
  rotate([-theta,0,0])
  translate([0,-outer.z/2,epsilon])
  cuboid([outer.x,outer.z,outer.y],anchor=TOP);

  n_times_y = n*(outer.y-walls)+walls;

  // base rear
//  front_half(y=n_times_y*sin(theta),s=2*n*outer.y,show_frameref=false)
//  top_half(2*n*outer.y)
//  rotate([-theta,0,0])
//  cuboid([outer.x, n_times_y, n_times_y], anchor=BOTTOM+FRONT);

}


module double_boxes(n=5,capacity=10,gap=19,theta,phi) {
  module one () {
    boxes(n,capacity=capacity,theta=theta,phi=phi);
  }

  outer = box_outer(capacity);
  one();
  translate([gap+outer.y,0,0])
    one();

  up_theta = [0,sin(theta),cos(theta)];
  forward_theta = [0,-cos(theta),sin(theta)];
  wd = (outer.y-boxwalls)*sin(theta-phi);

  rear_cut_y =
    (n-1)*(up_theta*(outer.y)+forward_theta*wd).y; // +n*outer.y*sin(phi) -n*wd*sin(theta);

  echo("double rear cut", rear_cut_y);


  % cuboid([20,rear_cut_y,10], anchor=FRONT);

//  linear_extrude(gap+2*epsilon) {
//    polygon([[0,0], [rear_cut_y,0], [rear_cut_y,rear_cut_y/cos(phi)]]);
//  }
}

          
//number("2");

//numbers("  ");

//for (i=[0:1]) {
//  translate([i*40, 0,0])
//    stands(1);
// }

//translate([2*side,0,0]) number("6");

//numbers("00111112222223333344444555667789");

antiphi = 13;
antitheta = 45;

double_boxes(5,theta=90-antitheta,phi=90-antiphi);
//boxes(5,theta=90-antitheta,phi=90-antiphi);

//box();
//translate([2,box_outer(10).y-boxwalls,3])
//box();


if (false) {
 translate([0,1,0])
  translate([0,0,stand_outer.z-niche3d.z])
   translate([0,0,height])
    mirror([0,0,1])
    number("0");
}

//numbers("0123456789");
//numbers("01112223");
// 3345");
