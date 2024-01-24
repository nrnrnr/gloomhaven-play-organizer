
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;
sq2 = sqrt(2);


leftcard = 12;

length = 278;  // confirm space in mm
width = 120;   // XXX TODO confirm enough room
height = 27;

tokenwidth = 15;
tokenthickness = 3;
tokenlength = 55;
tokendepth = 12;

clearances_thick = [0.3, 0.4, 0.5];
clearances_width = [0.3, 0.4, 0.5];

clearance_thick = 0.35;
clearance_width = 0.4;


cardslength = 50;
cardsthickness = 4.5;
cardsdepth = 25;

shoulder_width = 3;


/*
  -------
       ------
  -------
       ------
       ⋮
  -------
       ------

length == 18.5 * stride + sep + 2 * shoulder_width
sep = stride - cardsthickness  // distance between cards, also half distance 
                               // from cards to edge

∴ length = 19.5 * stride + 2 * shoulder_width - cardsthickness

  
*/

stride = (length + cardsthickness - 2 * shoulder_width) / 19.5;
sep = stride - cardsthickness;
  


//
//\draw (-1,-1) rectangle +(131,284);
//\draw (0,0) rectangle +(129,282);
//\foreach \i in {0,...,17} {
//  \draw ($(\leftcard,\i*\stride+12.5)$) rectangle +(50mm,4.5mm);
//  \draw ($(\leftcard+54,\i*\stride+12.5)$) rectangle +(50mm,4.5mm);
//}
//\foreach \i in {0,...,17} {
//  \draw ($(9,\i*\stride+6+4.25)$) node[rotate=-45,minimum width=16mm,minimum height=3.8mm,draw] { };
//  \draw ($(9+110,\i*\stride+6+4.25)$) node[rotate=45,minimum width=16mm,minimum height=3.8mm,draw] { };
//}
//\foreach \i in {1,2} {
//  \draw ($(64.5,\i*6*\stride+0.3*\stride+2)$) node [minimum height=2mm,minimum width=80mm,draw]{};
//}

//anti_chamfer_sw(5,30,hi_corner = true,lo_corner = true);


//module undercube(r) {
//  translate([0,0,-r.z]) cube(r);
//}
//
//cube([1,1,1]);
//
//sq2 = sqrt(2);
//
//v = [1,0,0];
//
//translate(-v)
//translate([1-sq2,0,0])
//%undercube([sq2,sq2,sq2]);



module chamfers_test() {
  difference () {
    cube([60,60,15]);
//    translate([15,20,15+epsilon])
//      union () {
//       anti_chamfer_south(5+epsilon,30,lo_corner = true);
//        translate([0,-7,-15])
//          union () {
//          cube([30,7+epsilon,15+epsilon]);
//          translate([epsilon,0,15+epsilon])
//          anti_chamfer_east(5,7,hi_corner = true);
//        }
//      }
    translate([10,40,15-5]) chamfered_well([30,7,5+epsilon],depth=2+epsilon);
  }
}

//chamfers_test();

//translate([0,-30,0]) chamfered_well([30,7,15], 5);


module tokens_test() {
  sep=6;
  depth = 15;
  surround = 3;
  height = depth + 5;

  module well(i) {
    translate([sep + i * (tokenthickness + sep), surround, height-depth+epsilon])
    chamfered_well([tokenthickness+clearances_thick[i],
                    tokenwidth + clearances_width[i],
                    depth],
                   depth=1);
  }

  difference () {
    cube([sep + 3 * (tokenthickness + sep), tokenwidth + 2 * surround, height]);
    well(0);
    well(1);
    well(2);
  }
}

module left_unit () {
  tlen = tokenwidth + clearance_width;
  twid = tokenthickness + clearance_thick;
  northeast = [cos(45), sin(45), 0];
  smallsep = 2;
  union () {
    translate([0, tlen * sin(45), height - tokendepth])
      rotate([0,0,-45])
      chamfered_well([tlen, twid, tokendepth], depth=1);
    shift = (tlen/2 + twid + smallsep) * northeast;
    lift(height-cardsdepth)
    translate(shift)
      chamfered_well([cardslength,cardsthickness,cardsdepth], 2);
  }
}

module right_unit() {
  mirror([1,0,0]) left_unit();
}

unit_shift = 3;

module unit_test() {
  difference() {
    cube([68, stride + sep, height]);
    translate([unit_shift, sep/2, epsilon])
      left_unit();
  }
}

//translate([0,50,0]) tokens_test();

translate([-80,-30,0]) unit_test();

module block () { // XXX TODO add shoulders
  difference () {
    cube([width, length, height]);
    i = 0;
    for (i = [0:1:17]) {
      translate([unit_shift + shoulder_width, shoulder_width + sep/2 + i * stride, epsilon])
        render () left_unit();
      translate([width - unit_shift - shoulder_width, shoulder_width + sep/2 + i * stride + stride/2, epsilon])
        render () right_unit();
    }
  }
}

block();



