// passage to summer house hideout

include <BOSL2/std.scad>

epsilon = 0.1;

function bigger(d, delta) = [d.x+2*delta, d.y+2*delta, d.z+2*delta];

inch = 25.4;

inside = [30, inch, 50];

thickness = 1.6;

module inch_hall() {
  xrot(90, cp=[0,-0.5*inch,0])
  difference() {
    cube([inside.x + 2 * thickness, inside.y-2*epsilon, inside.z + thickness], anchor = TOP);
    translate([0,0,epsilon])  cube(inside, anchor = TOP);
  }
}


inch_hall();



