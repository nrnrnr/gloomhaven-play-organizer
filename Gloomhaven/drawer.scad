
function radians(d) = d * PI / 180.0;

epsilon = 0.001;

module half_cylinder(r,h) {
  // half a cylinder (half toward positive X axis)
  difference() {
    cylinder(r=r,h=h,center=true);

    translate([-2*r,-r,-h])
      cube([2*r, 2*r, 2*h]);
  }
}

module drawer (h=25, w=30, l=40, r=10, theta=30, c=10, sep=0.8, 
               floor_y_shift=-10, layer_height=0.2, floor=1, insert=true) {
  // h     = drawer height
  // w     = drawer width
  // l     = drawer length (depth) front to back
  // r     = radius of rear curve
  // theta = angle drawer front makes with vertical
  // c     = length of circumscribed line on front radius
  // sep   = material around drawer

  // insert = model the smooth insert for the bottom of the drawer


  phi   = 90 - theta;         // complement of theta (90 - theta)
  R     = c / tan(phi/2);     // radius of front curve
  touch = l - h * tan(theta); // distance from rear to where front slant floor touches

  slant_length = h / cos(theta); // hypotenuse of front triangle

  cube_height = slant_length - c;


  translate([0,0,floor])
  difference () {
    // make cube including sep and epsilon
    translate([-sep, 0, -floor])
      cube([w + 2 * sep, l + sep + epsilon, h + floor]);

    // subtract upper back cube
    translate([0, l - r, r - epsilon])
      cube([w, r, h - r + 2 * epsilon]);

    // subtract central cube between cylinders
    translate([0, l - touch + c - epsilon, 0])
      cube([w, touch - r - c + 2 * epsilon, h + epsilon]);

    // subtract rear half-cylinder
    translate([w/2, l - r, r])
      rotate([90,0,0])
        rotate([0,90,0])
          half_cylinder(h=w,r=r);

    // subtract front half-cylinder
    translate([w/2, l - touch + c, R])
      rotate([-90,0,0])
        rotate([0,90,0])
          half_cylinder(h=w,r=R);



    // subtract tilted cube
    translate([0,0,h])
      rotate([theta,0,0])
        translate([0,0,-cube_height])
          cube([w, tan(phi) * cube_height, cube_height]);
  }

  floor_length =  // r * PI / 2 +  // don't cover the rear curve
     touch - c - r + R * radians(phi) + slant_length - c;

  floor_trim = 0.4; // amount to reduce width and length

  if (insert) {
    translate([0,floor_y_shift-floor_length,0])
      cube([w-floor_trim,floor_length - floor_trim, layer_height]);
  }


}

//  color("blue") translate([-w/2,0,0])
//    translate([0,0,h])
//      rotate([theta,0,0])
//        translate([0,0,-cube_height])
//          cube([w, tan(phi) * cube_height, cube_height]);


//  color("blue")
//    translate([0, touch, 0])
//      cube([w, touch - r - c + epsilon, h + epsilon]);
//
//  color("green")
//    translate([35, l - touch + c, 0])
//      cube([w, touch - r - c + epsilon, 2 * h + epsilon]);
//
//
//  color("red")
//     translate([w/2, l - touch + c, R])
//      rotate([-90,0,0])
//        rotate([0,90,0])
//          half_cylinder(h=w,r=R);
//
//  color("yellow")
//      rotate([-90,0,0])
//        rotate([0,90,0])
//          half_cylinder(h=w,r=R);


////////////////////////////////////////////////////////////////

module cube_filleted_columns(x,y,z,r) {
  union () {
    translate ([r,  r,  0]) cylinder(h=z, r=r);
    translate ([x-r,r,  0]) cylinder(h=z, r=r);
    translate ([r,  y-r,0]) cylinder(h=z, r=r);
    translate ([x-r,y-r,0]) cylinder(h=z, r=r);

    translate([r,     0,  0])  cube([x-2*r, 2*r, z]);
    translate([r, y-2*r,  0])  cube([x-2*r, 2*r, z]);

    translate([0,     r,  0])  cube([2*r, y-2*r, z]);
    translate([x-2*r, r,  0])  cube([2*r, y-2*r, z]);

    translate([r, r, 0]) cube([x-2*r,y-2*r,z]);
  }
}

