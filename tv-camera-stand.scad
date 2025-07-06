$fa = 2;    // minimum angle (fine resolution)
$fs = 0.2;  // minimum size (fine resolution)


epsilon = 0.01;

pi = 3.1415926535;

layer = 0.2;

width = 3; // temporary; eventually to be 60

function radians(deg) = deg * pi / 180;

module down(k) {
  translate([0,0,-k])
  children();
}


slop = 1; // extra width in mm

theta_d = 4; // degrees
theta1 = 3.8;
theta_avg = theta1 + theta_d / 2.0;
theta2 = theta1 + theta_d;

radius = 40.6 / radians(theta_d);

gapheight = 3;
h1 = 10 + gapheight; // z thickness of stand in mm

y = radius * cos(theta1) + h1;

// d1 = 30; // depth of rear stop, mm
d1 = 6;
d2 = 7.9; // depth of front stop, mm

h2 = y - radius * cos(theta1 + theta_d);

front_triangle_top = y - 21;

x1 = radius * sin(theta1);
x2 = radius * sin(theta2);

y1 = radius * cos(theta2);
y2 = radius * cos(theta2);

thickness = 3; // of front and back tabs

mountx = 25; // tab for camera mount
mounty = 25; 

nubradius = 1.5;

translate([thickness - x1, h1 + d1 - y, 0]) 
  union () {


//    difference () {
//      translate([x1 - thickness, bot, 0])
//        cube([x2 - x1 + 2 * thickness, y - bot, width]);
//      down(epsilon) cylinder(r=radius, h = width + 2 * epsilon);
//    }

    difference () {
      translate([x1 - epsilon, y2, 0])
        cube([x2 - x1 + 2 * epsilon, y - y2, width]);
      down(epsilon) cylinder(r=radius, h = width + 2 * epsilon);
      touch = 7;  // approx length in x of touching surface in mm
      translate([x1+touch, y2, -epsilon])
        cube([x2 - x1 - 2 * touch, 2.2 * gapheight, width+2*epsilon]);
    }

  translate([x1 + epsilon - thickness, y - (h1 + d1), 0]) // rear stop
    union () {
      cube([thickness+epsilon, d1 + h1, width]);
      translate([thickness, nubradius, 0])
         cylinder(r=nubradius, h = width);
    }

  linear_extrude(height=width)
    polygon(points=[ [x2+epsilon, front_triangle_top]
                   , [x2+epsilon, y - (h2 + d2)]
                   , [x2-1.7, (front_triangle_top + y - (h2 + d2)) / 2]
                   ]);
                     

  translate([x2 - epsilon, y - (h2 + d2), 0])
    cube([thickness+epsilon, d2 + h2, width]);

//  translate([(x1+x2)/2 - mountx/2, y - epsilon, 0])
//    cube([mountx, mounty, thickness]);

  }

        
