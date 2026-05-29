$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

include <BOSL2/std.scad>

function inches(x) = x * 25.4;

layer_height = 0.2;

hex_side = inches(0.75);
hex_diameter = inches(1.5);

radius = hex_diameter / 2;
apothem = radius * cos(30);

thickness = 2.1;

height = 3.2;

module hex_ring() {
  linear_extrude(height)
  difference() {
    hexagon(od = hex_diameter + thickness);
    hexagon(od = hex_diameter - thickness);
  }
}

function polar(r, theta) = [r * cos(theta), r * sin(theta)];

  ur = polar(2 * apothem, 30);
  lr = polar(2 * apothem, -30);
  up = polar(2 * apothem, 90);

module test() {
  hex_ring();
  translate(ur) hex_ring();
  translate(2 * ur) hex_ring();
  translate(ur+lr) hex_ring();
  translate(up) hex_ring();
}

module ear0() {
  pie_slice(r=4, h=layer_height, ang=360-120, anchor=DOWN);
}

module turn(degrees) {
  rotate([0,0,degrees])
    children();
}

module ear(azimuth) {
  rot = azimuth - 120;
  translate(polar(radius, azimuth))
    turn(rot)
    ear0();
}


left = [-radius, 0];


module eleft() {
  translate(left) turn(60) ear();
}
module eright() {
  translate(-left) turn(-120) ear();
}
module eur() {
  translate(ur/2) turn(-60) ear();
}
module eul() {
  translate(ul/2) turn(0) ear();
}
module ell() {
  translate(-ur/2) turn(-60) ear();
}
module elr() {
  translate(-ul/2) turn(0) ear();
}


module testears() {

  ear(180);
  ear(240);
  ear(300);

  translate(up) {
    ear(60);
    ear(120);
    ear(170);
  }
  translate(ur+lr) {
    ear(0);
    ear(-60);
    ear(-120);
  }
  translate(ur+ur) {
    ear(0);
    ear(60);
    ear(120);
  }
}

module ears(angles) {
  for (i = angles) ear(i);
}

module wave_of_frost() {
  hex_ring();
  translate(ur) hex_ring();
  translate(ur+ur) hex_ring();
  translate(up) hex_ring();
  translate(up+ur) hex_ring();

  ears([180,240,300]);
  translate(up) ears([120,180]);
  translate(ur) ears([-60]);
  translate(ur+ur) ears([60,0,-60]);
  translate(ur+up) ears([60,120]);

}

translate([0, 80, 0]) wave_of_frost();

module pulsing_cores() {
  hex_ring();
  ears([120,180,240,300]);
  translate(up) {
    hex_ring();
    ears([60,120,180]);
  }
  translate(ur) {
    hex_ring();
    ears([60,0,-60]);
  }
}

pulsing_cores();
