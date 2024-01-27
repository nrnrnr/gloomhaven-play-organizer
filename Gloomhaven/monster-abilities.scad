
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

dry_run = true;
final_run = !dry_run;

epsilon = 0.001;
sq2 = sqrt(2);
northeast = [cos(45), sin(45), 0];
v110 = [1, 1, 0];

layer_height = 0.2;


leftcard = 12;

length = final_run ? 278 : 30;  // confirmed
width = final_run ? 121 : 20;   // confirmed
height = 27;

tokenwidth = 15;
tokenthickness = 3;
tokenlength = 55;
tokendepth = 12;

clearances_thick = [0.35, 0.45, 0.55];
clearances_width = [0.4, 0.45, 0.50];

clearance_thick = 0.35;
clearance_width = 0.4;

sleevedsmallheight = 73;
sleevedsmallwidth = 46;

cardslength = sleevedsmallwidth + 4;
cardsthickness = 4.5;
cardsdepth = 25;
cardsceiling = dry_run ? 3 : sleevedsmallwidth + 2 - cardsdepth;

shoulder_width = dry_run ? 2.5 : 4;
shadow_line_width = dry_run ? 1 : 7;
shoulder_overlap = dry_run ? 6.5 : 10;
shoulder_clearance = 0.5;
shoulder_cover_thickness = 1;
tab_relief = 2;

// covers_gap = 4; // need space because single block has two partial caps
covers_gap = 0; // use single full cap, print on diagonal
cap_thickness = 2;
full_cap_chamfer_width = dry_run ? 5 : 7; // 0.75 * cap_thickness;
capheight = shoulder_overlap + cardsceiling + cap_thickness;
echo(capheight=capheight);


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

tokens_test_cw = 3; // chamfer width

module tokens_test(theta = 60) {
  sep=7;
  depth = 15;
  surround = 3;
  height = depth + 5;

  module well(i) {
    wellsize = [tokenthickness+clearances_thick[i], tokenwidth + clearances_width[i], depth];
    translate([sep + i * (tokenthickness + sep), surround, height-depth+epsilon])
    rotate_at([0,0,45], wellsize/2)
    chamfered_well(wellsize, depth = 1);
  }

  box = [sep + 3 * (tokenthickness + sep), tokenwidth + 2 * surround, height]; 
  cw = tokens_test_cw; // chamfer width

  translate([cw * cos(theta) - box.x, 0, 0])
  difference () {
    cube(box);
    well(0);
    well(1);
    well(2);
    anti_chamfer_bottom(box, width = cw, theta = theta);
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

unit_shift = 4;

module unit_test() {
  difference() {
    cube([68, stride + sep / 2 + smallsep, height]);
    translate([unit_shift, smallsep, epsilon])
      left_unit();
  }
}

//translate([0,50,0]) tokens_test();

//translate([-80,-30,0]) unit_test();

// XXX TODO cap needs to be enlarged by clearance!

wedge_clearance = 0.5;
wedgelen = min(30, 0.4 * length);
tab_guarantee = 1;  // inserts at least this much even when shifted
tabdepth = 2 * shoulder_clearance + tab_guarantee;
tabheight = // shoulder_overlap - tab_relief - 1;
  2 * tabdepth * tan(dry_run ? 45 : 60);

assert(tabheight + tab_relief < shoulder_overlap);

module old_wedge(len, blowup = 1) {
  // meant to prevent slideout of partial cap
  depth = shoulder_width / 2 + unit_shift - 2;
  translate([0, len * blowup, 0])
    rotate([90,0,0])
    scale(blowup)
    linear_extrude(len)
    polygon([[0,0], [depth, depth/2], [0, tabheight]]);
}

module wedge(len) {
  translate([0, len, tabheight/2])
    rotate([90,0,0])
    linear_extrude(len)
    polygon([[0, -tabheight/2], [tabdepth, 0], [0, tabheight/2]]);
}

function caplen(groups_covered) = let (
  extra = groups_covered == 1 ? smallsep : sep / 2 - stride / 2
  ) (groups_covered * 6 + 0.5) * stride +
           shoulder_width + extra + (groups_covered - 1) * 2 * covers_gap;


module partial_cap(groups_covered) {
  extra = groups_covered == 1 ? smallsep : sep / 2 - stride / 2;

  tablen = wedgelen / 2 - shoulder_width / 4;


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

module full_cap(chamfer_angle = 45) {
  // XXX TODO thumb holes
  // XXX TODO text
  delta = shoulder_cover_thickness;
  difference () {
    cube([width, length, capheight]);
    translate(delta * v110)
      translate([0,0, capheight - shoulder_overlap])
      cube([width - 2 * delta, length - 2 * delta, capheight]);
    translate(shoulder_width * v110)
      translate([0,0, cap_thickness])
      cube([width - 2 * shoulder_width, length - 2 * shoulder_width, capheight]);
//    translate([-epsilon, -epsilon, -epsilon])
//      mirror([0,0,1])
//      anti_chamfer_south(full_cap_chamfer, width + 2 * epsilon);
//    translate([-epsilon, length + epsilon, -epsilon])
//      mirror([0,0,1])
//      anti_chamfer_north(full_cap_chamfer, width + epsilon * 2);


    w = full_cap_chamfer_width;
//    translate([-epsilon, w * cos(chamfer_angle), -epsilon])
//      rotate([90 - chamfer_angle, 0, 0])
//      translate([0,-length,0])
//      cube([width + 2 * epsilon, length, capheight]);
//    translate([-epsilon, length - w * cos(chamfer_angle), -epsilon])
//      rotate([chamfer_angle - 90, 0, 0])
//      cube([width + 2 * epsilon, length, capheight]);
    anti_chamfer_bottom([width, length, capheight], w, 45);
  }
  translate([shoulder_cover_thickness - epsilon, (length - wedgelen) / 2, capheight - tab_relief ])
    mirror([0,0,1]) wedge(wedgelen);
  translate([width - shoulder_cover_thickness + epsilon, (length - wedgelen) / 2, capheight - tab_relief])
    mirror([0,0,1]) mirror([1,0,0]) wedge(wedgelen);
}

module tilted_full_cap(theta=45) {
  w = full_cap_chamfer_width;
  translate([0,width,0])
  rotate([0,0,-90])
  translate([0, (capheight - w * sin(theta)) * sin(theta), 0])
  translate([0,w,0])
  rotate([theta, 0, 0])
    translate([0, - w * cos(theta), 0])
    full_cap(theta);
}
    

module supported_full_cap(theta=45) {
  tilted_full_cap(theta);
  w = full_cap_chamfer_width;  
  translate([w + (capheight - w * sin(theta)) * sin(theta),width/2,0])
    support_fin(theta = 45, length = 0.60 * length, base_width = 0.70 * width);
  // add adhesion support ("mouse ears")
  ear_size = 15;
  ear_distance = 5;
  translate([(capheight - w * sin(theta)) * sin(theta),-(ear_distance+ear_size/2),0])
    union () {
      cube([w, width + 2 * (ear_distance + ear_size / 2), layer_height]);
      translate([w/2, 0, 0]) cylinder(d=ear_size, h=layer_height);
      translate([w/2, width + 2 * ear_distance + ear_size, 0]) cylinder(d=ear_size, h=layer_height);
    }
}

module old_supported_full_cap(theta=45) {
  tilted_full_cap(theta);


  fin_length = 0.55 * length;
  fin_thickness = 2;
  fin_gap = 0.75;
  fin_base_length = fin_length * cos(theta);
  fin_height = fin_length * sin(theta);
  fin_base_width = 40;
  w = full_cap_chamfer_width;

  module anti_tooth(d, h) {
    translate([-d/2, -d/2, -h/2])
    cube([d, d, h]);
  }

  module unplaced_sprue() {
    thickness = 0.5;  // from video
    tooth = 0.25;
    length = fin_gap / sin(theta)  + thickness / tan(theta);
    translate([thickness / tan(theta) - length + epsilon, -thickness/2, 0])
      difference() {
        cube([length, thickness, thickness]);
        translate([tooth/cos(theta),0,thickness/2])
          rotate([0, -theta-90, 0])
          anti_tooth(d=tooth, h = 2 * thickness / sin(theta));
        translate([tooth/cos(theta),thickness,thickness/2])
          rotate([0, -theta-90, 0])
          anti_tooth(d=tooth, h = 2 * thickness / sin(theta));
    }
  }

  sprue_vertical_spacing = 10;

  module sprue(i) {
    translate([i * sprue_vertical_spacing / tan(theta), 0, i * sprue_vertical_spacing])
      unplaced_sprue();
  }


  translate([fin_gap / sin(theta),0,0])
  translate([w + (capheight - w * sin(theta)) * sin(theta),width/2,0])
    union () {
      sprue(0);
      for(i=[1:fin_height/sprue_vertical_spacing])
        sprue(i);
      translate([0, fin_thickness/2, 0])
      rotate([90,0,0])
        linear_extrude(fin_thickness)
        polygon([[0,0], [fin_base_length, 0], [fin_base_length, fin_length * sin(theta)]]);
      linear_extrude(fin_thickness)
        hull() {
        translate([10 - 2.5, 0, 0]) circle(r=2.5);
        offset = fin_base_width / 2 + 5;
        translate([fin_base_length - 5, offset, 0])  circle(r=5);
        translate([fin_base_length - 5, -offset, 0]) circle(r=5);
        }
  }

}


module block () { 
  difference () {
    delta = shoulder_cover_thickness + shoulder_clearance;
    union () { // make block with shoulders
      cube([width, length, height - (shoulder_overlap + shadow_line_width)]);
        translate(delta * v110)
        cube([width - 2 * delta, length - 2 * delta, height]);
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

test_fit_block_height = shoulder_overlap + shadow_line_width + 2;
module test_fit_block () { 
  test_height = test_fit_block_height;
  difference () {
    delta = shoulder_cover_thickness + shoulder_clearance;
    union () { // make block with shoulders
      cube([width, length, test_height - (shoulder_overlap + shadow_line_width)]);
        translate(delta * v110)
        cube([width - 2 * delta, length - 2 * delta, test_height]);
    }
    wedgeheight = test_height - shoulder_overlap + tab_relief;
    translate([shoulder_cover_thickness + shoulder_clearance - epsilon, (length-wedgelen)/2, wedgeheight]) wedge(wedgelen);
    translate([width - (shoulder_cover_thickness + shoulder_clearance) + epsilon, (length-wedgelen)/2, wedgeheight]) mirror([1,0,0]) wedge(wedgelen);
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

module build_volume() {
  color("Cyan", alpha=0.2) cube([250, 210, 220]);
}


//translate([width+20,0,0]) partial_cap(1);
//translate([width+6,0,2]) partial_cap(2);
//
//translate([width+20,length+1,2]) mirror([0,1,0]) partial_cap(2);

//translate([width+20,0,0]) full_cap();

//block();

//translate([width, 0, height + capheight - shoulder_overlap]) rotate([0,180,0]) partial_cap(1);


//%translate([-5, 0, 0]) %wedge(40);

//wedge(wedgelen);

//tilted_full_cap(15);

//tilted_full_cap(45);
//supported_full_cap(45);

module tilted_supported_block () {
  cw = 7;
translate([10,0,0])
union () {
  translate([-cw * tan(45) / 2, 0, -cw * tan(45) / 2])
  translate([height * sin(45), 0, 0])
  rotate([0,-45,0])
  translate([0,width,0])
  rotate([0,0,-90])
  difference () { 
    block();
    anti_chamfer_bottom([width, length, height], theta = 45, width = cw);
  }
  translate([height * sin(45), width/2, 0])
  support_fin(length = 0.60 * length, theta = 45, base_width = 0.70 * width);
}

}


//tilted_supported_block();

//block();

test_fit_block();

//full_cap();

//translate([0,0,test_fit_block_height-shoulder_overlap]) translate([0,length,capheight]) rotate([180,0,0]) full_cap();

translate([2 * width, 0, 0]) supported_full_cap();


//build_volume();

//rotate([0, 45, 0])
//tokens_test(theta=45);
//mirror([1,0,0]) support_fin(theta=45, length=30);


//support_fin(theta=60, length=50);




