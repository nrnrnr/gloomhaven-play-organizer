
$fa = true ? 4 : 2;    // minimum angle (fine resolution)
$fs = true ? 1 : 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

dry_run = true;
final_run = !dry_run;
add_text = false;

epsilon = 0.001;

module pirata(s,size=8,valign="baseline") {
  // place 2D text with default parameters
  if (add_text) {
    text(s, font = "Pirata One", halign = "center", size=size, valign=valign);
  }
}

///////////////////////////////////

northeast = [cos(45), sin(45), 0]; // unit length
v110 = [1, 1, 0];

layer_height = 0.2;



length = final_run ? 278 : 30;  // confirmed
width = final_run ? 121 : 20;   // confirmed
height = 27;

tokenwidth = 15;    // slot to hold initiative tokens
tokenthickness = 3;
tokenlength = 55;
tokendepth = 12;

clearances_thick = [0.35, 0.45, 0.55]; // testing initiative-token slots
clearances_width = [0.4, 0.45, 0.50];

clearance_thick = 0.35; // final decision on initiative-token slots
clearance_width = 0.4;

sleevedsmallheight = 73; // measure sleeved cards
sleevedsmallwidth = 46;

cardslength = sleevedsmallwidth + 4;
cardsthickness = 4.3;
cardsdepth = 25; // leaves room for monster name to show, at least partially
cardsceiling = dry_run ? 3 : sleevedsmallwidth + 2 - cardsdepth;

shoulder_width = dry_run ? 2.5 : 4.4; // need 4.4 so wall not too thin behind thumb indent
shadow_line_width = dry_run ? 1 : 7;
shoulder_clearance = 0.4;
shoulder_cover_thickness = 1;
tab_relief = 2; // space on shoulder cover above and below tab

wedge_clearance = 0.5; // horizontal space
wedgelen = min(30, 0.4 * length);
tab_guarantee = 0.6;  // inserts at least this much even when shifted
                      // 1.0 felt too big (too tight a fit)
tabdepth = shoulder_clearance + tab_guarantee;
tabheight = // shoulder_overlap - tab_relief - 1;
  2 * tabdepth * tan(dry_run ? 60 : 60);

shoulder_overlap = min(dry_run ? 6.5 : 10, tabheight + 2 * tab_relief);


// groups_gap = 4; // need space because single block has two partial caps
groups_gap = 5; // use single full cap, print on diagonal
cap_thickness = 2;
full_cap_chamfer_width = dry_run ? 5 : 7; // 0.75 * cap_thickness;
capheight = shoulder_overlap + cardsceiling + cap_thickness;
echo(capheight=capheight);


/*
Calculate stride for interleaved layout:
  -------
       ------
  -------
       ------
       ⋮
  -------
       ------

length == 18.5 * stride + sep / 2 + smallsep + 2 * shoulder_width + 2 * groups_gap
sep = stride - cardsthickness  // distance between cards, also half distance 
                               // from cards to edge

 length == 18.5 * stride + stride / 2 - cardsthickness / 2 + smallsep + 2 * shoulder_width + 2 * groups_gap


∴ length = 19 * stride + 2 * shoulder_width - cardsthickness / 2 + smallsep + 2 * groups_gap

  
*/

smallsep = 2;
stride = (length + cardsthickness / 2 - 2 * shoulder_width - 2 * groups_gap - smallsep) / 19;
sep = stride - cardsthickness;
//echo (sep=sep);




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
           shoulder_width + extra + (groups_covered - 1) * 2 * groups_gap;


module partial_cap(groups_covered) {
  // OBSOLETE
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

textthickness = 0.8;

module place_bottom_text() {
  translate([0,0,textthickness-epsilon])
    rotate([0,180,0])
    rotate([0,0,-90])
    linear_extrude(textthickness+epsilon)
    children();
}

  

module half_sphere(r) {
  above(0)
  sphere(r);
}

module full_cap(chamfer_angle = 45, label) {

    thumb_radius = 57;

    module thumb_holes(y) {
      translate([shoulder_width - 1 - thumb_radius,y,8])
        half_sphere(r=thumb_radius);
      translate([width - (shoulder_width - 1 - thumb_radius),y,8])
        half_sphere(r=thumb_radius);
    }



  delta = shoulder_cover_thickness;
  difference () {
    cube([width, length, capheight]);
    translate(delta * v110)
      translate([0,0, capheight - shoulder_overlap])
      cube([width - 2 * delta, length - 2 * delta, capheight]);
    translate(shoulder_width * v110)
      translate([0,0, cap_thickness])
      cube([width - 2 * shoulder_width, length - 2 * shoulder_width, capheight]);
    w = full_cap_chamfer_width;
    anti_chamfer_bottom([width, length, capheight], w, 45);

    if (final_run) {
      translate([0.2 * width,length/2,0])
        place_bottom_text()
        pirata("Gloomhaven",size=21,valign="center");

      translate([0.6 * width,length/2,0])
        place_bottom_text()
        pirata("Monster Ability Cards",size=16,valign="center");

      translate([0.8 * width,length/2,0])
        place_bottom_text()
        pirata("Monster Initiative Tokens",size=16,valign="center");

      thumb_holes(1 * length/4);
      thumb_holes(3 * length/4);

    }

    if (is_string(label)) {
      translate([width/2, length/2, cap_thickness - 0.8 + epsilon])
        linear_extrude(0.8)
        text(label, halign="center", valign="center", size=10);
    }


  }
  translate([shoulder_cover_thickness - epsilon, (length - wedgelen) / 2, capheight - tab_relief ])
    mirror([0,0,1]) wedge(wedgelen);
  translate([width - shoulder_cover_thickness + epsilon, (length - wedgelen) / 2, capheight - tab_relief])
    mirror([0,0,1]) mirror([1,0,0]) wedge(wedgelen);
}

module tilted_full_cap(theta=45, label) {
  w = full_cap_chamfer_width;
  translate([0,width,0])
  rotate([0,0,-90])
  translate([0, (capheight - w * sin(theta)) * sin(theta), 0])
  translate([0,w,0])
  rotate([theta, 0, 0])
    translate([0, - w * cos(theta), 0])
    full_cap(theta,label=label);
}
    

module supported_full_cap(theta=45,label) {
  tilted_full_cap(theta,label=label);
  w = full_cap_chamfer_width;  
  text_shift = dry_run ? 0 : 5;
  translate([w + (capheight - w * sin(theta)) * sin(theta),width/2+text_shift,0])
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

module block () { 
  difference () {
    delta = shoulder_cover_thickness + shoulder_clearance;
    union () { // make block with shoulders
      cube([width, length, height - (shoulder_overlap + shadow_line_width)]);
        translate(delta * v110)
        cube([width - 2 * delta, length - 2 * delta, height]);
    }
    for (i = [0:1:17]) {
      gap = i >= 12 ? 2 * groups_gap : (i >= 6 ? groups_gap : 0);
      translate([unit_shift + shoulder_width,
                 shoulder_width + gap + smallsep + i * stride,
                 epsilon])
        render () left_unit();
      translate([width - unit_shift - shoulder_width, shoulder_width + gap + smallsep + i * stride + stride/2, epsilon])
        render () right_unit();
    }
    slotlen = wedgelen + 2 * shoulder_clearance;
    wedgeheight = height - shoulder_overlap + tab_relief;
    translate([0     + delta - epsilon, (length-slotlen)/2, wedgeheight])
      wedge(slotlen);
    translate([width - delta + epsilon, (length-slotlen)/2, wedgeheight])
      mirror([1,0,0])
      wedge(slotlen);
  }
}

test_fit_block_height = shoulder_overlap + shadow_line_width + 2;
module test_fit_block (label) { 
  assert(is_string(label));
  test_height = test_fit_block_height;
  difference () {
    delta = shoulder_cover_thickness + shoulder_clearance;
    union () { // make block with shoulders
      cube([width, length, test_height - (shoulder_overlap + shadow_line_width)]);
        translate(delta * v110)
        cube([width - 2 * delta, length - 2 * delta, test_height]);
    }
    translate([width/2, length/2, test_height - 0.6 + epsilon])
      rotate([0,0,-90])
      linear_extrude(0.6)
      text(label, halign="center", valign="center", size=10);
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
  line(shoulder_width +smallsep + 6 * stride + groups_gap);
  color("red") line(shoulder_width +smallsep + 6.5 * stride);
  color("red") line(shoulder_width +smallsep + 6.5 * stride + 2 * groups_gap);
  color("red") line(shoulder_width +smallsep + 12.5 * stride);
  color("red") line(shoulder_width +smallsep + 12.5 * stride + 2 * groups_gap);
  line(shoulder_width +smallsep + 12 * stride + groups_gap);
  line(shoulder_width +smallsep + 12 * stride + 2 * groups_gap);
  line(shoulder_width +smallsep + 18 * stride + 2 * groups_gap);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * groups_gap);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * groups_gap + sep/2);
  line(shoulder_width +smallsep + 18.5 * stride + 2 * groups_gap + sep/2 + shoulder_width);

  green() line(length - shoulder_width - sep/2);
  green() line(length - shoulder_width - sep/2 - cardsthickness);
//  translate([5, 0,0]) green() line(length - shoulder_width - sep/2 - 12 * stride - 2 * groups_gap);
  translate([10, 0,3]) color("#0ff") line(length - (shoulder_width + sep/2 + 12 * stride + 2 * groups_gap));
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

module test_fit_pair (label) {
  test_fit_block(label);
  translate([2 * width, 0, 0]) supported_full_cap(label=label);
}

if (dry_run) {

  test_fit_pair("C");
  // test C: tab depth is *single* shoulder clearance plus guarantee
  //         shoulder clearance is 0.4
}



module capped_block() {
  %block();
  translate([0,0,height-shoulder_overlap])
    translate([0,length,capheight])
    rotate([180,0,0])
    full_cap();
}

if (final_run) capped_block();
//supported_full_cap();




//build_volume();

//rotate([0, 45, 0])
//tokens_test(theta=45);
//mirror([1,0,0]) support_fin(theta=45, length=30);


//support_fin(theta=60, length=50);





