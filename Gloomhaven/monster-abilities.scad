
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;
sq2 = sqrt(2);
northeast = [cos(45), sin(45), 0];
v110 = [1, 1, 0];


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

sleevedsmallheight = 73;
sleevedsmallwidth = 46;

cardslength = sleevedsmallwidth + 4;
cardsthickness = 4.5;
cardsdepth = 25;
cardsceiling = sleevedsmallwidth + 2 - cardsdepth;

shoulder_width = 4;
shoulder_reveal = 7;
shoulder_overlap = 10;
tab_relief = 2;

covers_gap = 4; // need space because single block has two covers
cap_thickness = 2;
capheight = shoulder_overlap + cardsceiling + cap_thickness;


/*
  -------
       ------
  -------
       ------
       ⋮
  -------
       ------

length == 18.5 * stride + sep / 2 + smallsep + 2 * shoulder_width + 2 * covers_gap
sep = stride - cardsthickness  // distance between cards, also half distance 
                               // from cards to edge

 length == 18.5 * stride + stride / 2 - cardsthickness / 2 + smallsep + 2 * shoulder_width + 2 * covers_gap


∴ length = 19 * stride + 2 * shoulder_width - cardsthickness / 2 + smallsep + 2 * covers_gap

  
*/

smallsep = 2;
stride = (length + cardsthickness / 2 - 2 * shoulder_width - 2 * covers_gap - smallsep) / 19;
sep = stride - cardsthickness;
//echo (sep=sep);



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
  tinysep = 2;
  union () {
    translate([0, tlen * sin(45), height - tokendepth])
      rotate([0,0,-45])
      chamfered_well([tlen, twid, tokendepth], depth=1);
    shift = (tlen/2 + twid + tinysep) * northeast;
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
    cube([68, stride + sep / 2 + smallsep, height]);
    translate([unit_shift, smallsep, epsilon])
      left_unit();
  }
}

//translate([0,50,0]) tokens_test();

//translate([-80,-30,0]) unit_test();

// TODO cap needs small hook on end to engage block center and not slide off

// TODO cap needs to be enlarged by clearance!

wedge_clearance = 0.5;
wedgelen = 30;
tablen = wedgelen / 2 - shoulder_width / 4;
tabheight = shoulder_overlap - tab_relief - 1;

module wedge(len, blowup = 1) {
  depth = shoulder_width / 2 + unit_shift - 2;
  translate([0, len * blowup, 0])
    rotate([90,0,0])
    scale(blowup)
    linear_extrude(len)
    polygon([[0,0], [depth, depth/2], [0, tabheight]]);
}

function caplen(groups_covered) = let (
  extra = groups_covered == 1 ? smallsep : sep / 2 - stride / 2
  ) (groups_covered * 6 + 0.5) * stride +
           shoulder_width + extra + (groups_covered - 1) * 2 * covers_gap;


module cap(groups_covered) {
  extra = groups_covered == 1 ? smallsep : sep / 2 - stride / 2;

  difference () {
    cube([width, caplen(groups_covered), capheight]);
    translate(shoulder_width * v110)
      lift(cap_thickness)
      cube([width - 2 * shoulder_width, caplen(groups_covered), capheight]);
    translate(shoulder_width / 2 * v110)
      lift(cap_thickness + cardsceiling)
      cube([width - shoulder_width, caplen(groups_covered), capheight]);
    
  }
  translate([shoulder_width / 2 - epsilon, caplen(groups_covered) - tablen, capheight - tab_relief ])
    mirror([0,0,1]) wedge(tablen);
  translate([width - shoulder_width/2 + epsilon, caplen(groups_covered) - tablen, capheight - tab_relief])
    mirror([0,0,1]) mirror([1,0,0]) wedge(tablen);
}
  

module block () { // XXX TODO add retaining tabs
  difference () {
    union () { // make block with shoulders
      cube([width, length, height - (shoulder_overlap + shoulder_reveal)]);
      translate(shoulder_width / 2 * v110)
        cube([width - shoulder_width, length - shoulder_width, height]);
    }
    for (i = [0:1:17]) {
      gap = i >= 12 ? 2 * covers_gap : (i >= 6 ? covers_gap : 0);
      translate([unit_shift + shoulder_width,
                 shoulder_width + gap + smallsep + i * stride,
                 epsilon])
        render () left_unit();
      translate([width - unit_shift - shoulder_width, shoulder_width + gap + smallsep + i * stride + stride/2, epsilon])
        render () right_unit();
    }
    wedgeheight = height - shoulder_overlap + tab_relief;
    translate([shoulder_width/2 - epsilon, caplen(1) - wedgelen/2, wedgeheight]) wedge(wedgelen);
    translate([width - shoulder_width/2 + epsilon, caplen(1) - wedgelen/2, wedgeheight]) mirror([1,0,0]) wedge(wedgelen);
  }
}

module line (y = 0) {
  translate([0, y - 0.1, height - 5])
    color ("blue") cube([1.5* width, 0.2, 7]);
}


module green() { color("#080") children(); }

if (false) {
  line(0);
  color("red") line(shoulder_width/2);
  line(shoulder_width);
  line(shoulder_width +smallsep);
  line(shoulder_width +smallsep + 1 * stride);
  color("red") line(shoulder_width +smallsep + 1.5 * stride);
  line(shoulder_width +smallsep + 6 * stride);
  line(shoulder_width +smallsep + 6 * stride + covers_gap);
  color("red") line(shoulder_width +smallsep + 6.5 * stride);
  color("red") line(shoulder_width +smallsep + 6.5 * stride + 2 * covers_gap);
  color("red") line(shoulder_width +smallsep + 12.5 * stride);
  color("red") line(shoulder_width +smallsep + 12.5 * stride + 2 * covers_gap);
  line(shoulder_width +smallsep + 12 * stride + covers_gap);
  line(shoulder_width +smallsep + 12 * stride + 2 * covers_gap);
  line(shoulder_width +smallsep + 18 * stride + 2 * covers_gap);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * covers_gap);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * covers_gap + sep/2);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * covers_gap + sep/2 + shoulder_width);

  green() line(length - shoulder_width - sep/2);
  green() line(length - shoulder_width - sep/2 - cardsthickness);
//  translate([5, 0,0]) green() line(length - shoulder_width - sep/2 - 12 * stride - 2 * covers_gap);
  translate([10, 0,3]) color("#0ff") line(length - (shoulder_width + sep/2 + 12 * stride + 2 * covers_gap));
  translate([5,0,0]) green() line(7 * stride + shoulder_width - cardsthickness/2 + smallsep - sep/2);
}


translate([width+20,0,0]) cap(1);
//translate([width+6,0,2]) cap(2);
//
//translate([width+20,length+1,2]) mirror([0,1,0]) cap(2);

%block();

translate([width, 0, height + capheight - shoulder_overlap]) rotate([0,180,0]) cap(1);


//%translate([-5, 0, 0]) %wedge(40);

wedge(tablen/2);
