foot = 25.4 / 5.0; // mm per foot
mm = 1.0; // mm per mm

epsilon = 0.001;


tank_width = 2 * foot;

wall_width = 3;

tank = [15 * foot, 10 * foot, 10 * mm]; // total footprint

module tank_model() {
  cube([tank_width, tank.y, tank.z]);
  translate([tank.x - tank_width, 0, 0])
    cube([tank_width, tank.y, tank.z]);
  translate([0, tank.y - tank_width, 0])
    cube([tank.x, tank_width, tank.z]);
}


jelly_width = tank_width - 2 * wall_width;
jelly_depth = 1 * foot;


module jelly_model(tolerance=0.5) {
  translate([wall_width+tolerance/2, wall_width+tolerance/2, 0])
    cube([jelly_width - tolerance, tank.y - 2 * wall_width - tolerance, jelly_depth]);
  translate([tank.x - tank_width + wall_width+tolerance/2, wall_width+tolerance/2, 0])
    cube([jelly_width - tolerance, tank.y - 2 * wall_width - tolerance, jelly_depth]);
  translate([wall_width+tolerance/2, tank.y - tank_width + wall_width + tolerance/2, 0])
    cube([tank.x - 2 * wall_width - tolerance, jelly_width - tolerance, jelly_depth]);
}


torender = "assembly";

module render(what) {
  if (what == "assembly") {
    % tank_model();
    translate([0,0,tank.z  - jelly_depth + epsilon])
      jelly_model();
  } else if (what == "tank") {
    difference () {
      tank_model();
      translate([0,0,tank.z  - jelly_depth + epsilon])
        jelly_model(tolerance=0);
    }
  } else if (what == "jelly") {
    jelly_model();
  }
}

render(torender);


