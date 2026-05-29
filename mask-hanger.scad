// thing

include <BOSL2/std.scad>

epsilon = 0.001;

bar_width = 25.2;

tolerance = 1.0;

inch = 25.4;

bar_radius = 16.5;
intolerant_bar_half_angle = 52.8;

pi = 3.1415926535;
function degrees(radians) = radians * 180 / pi;

// tolerance/2 = cos theta * R delta_theta

delta_theta = degrees((tolerance / 2) / cos(intolerant_bar_half_angle) / bar_radius);

bar_half_angle = intolerant_bar_half_angle + delta_theta;

//echo("delta theta", delta_theta);


//linear_extrude(7) {
//stroke(
//    arc(n = 20, r = bar_radius, angle = [90 - bar_half_angle, 90 + bar_half_angle])
//    );
//}


//linear_extrude(4) {
//  stroke(turtle([
//        "setdir", 180,
//        "arcleftto", bar_radius, 180 + bar_half_angle,
//        "turn", 180,
//        "arcrightto", bar_radius, - bar_half_angle,
//        "setdir", -90,
//        "move", 20, // bar height
//        "move", 27, // clearance
//"setdir", 0
//]));
//}

cane_width = 25.4;
mask_width = 45;
wall_width = 4;
hanger_depth = cane_width + mask_width + wall_width;


cane = turtle([
        "setdir", 90,
        "move", 20,
        "setdir", bar_half_angle,
//        "arcleftto", bar_radius, 180 + bar_half_angle,
//        "turn", 180,
        "arcrightto", bar_radius, - bar_half_angle,
        "setdir", -90,
        "move", 20, // bar height
        "move", 27, // clearance
"setdir", 0
]);

lastcane = cane[len(cane)-1];


hanger_radius = 40;
hanger_width = 75;
hanger_half_angle = asin(hanger_width/2/hanger_radius);

hanger = arc(n = 40, r = hanger_radius,
             angle = [90 + hanger_half_angle, 90 - hanger_half_angle]);


wall_cross_section = [[0,0], [wall_width, 0], [0, wall_width]];

module hanger() {

  linear_extrude(cane_width) {
    stroke(cane);
  }

  linear_extrude(hanger_depth) {
    translate(lastcane)
      translate([0, -hanger_radius])
      stroke(hanger);
  }

  translate([lastcane.x, lastcane.y - hanger_radius, hanger_depth])
  rotate([0,180,0])
  rotate([0,0,90 - hanger_half_angle])
  rotate_extrude(angle = 2 * hanger_half_angle)
    translate([hanger_radius, 0])
    polygon(wall_cross_section);

  // gusset
  linear_extrude(cane_width)
    translate([0,-1.2])
    translate(lastcane)
    polygon([[-10,0],[10,0],[0,10]]);

}

intersection() {
  hanger();
  cube([500,500,2], anchor=BOTTOM);
}
