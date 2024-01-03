
function radians(d) = d * PI / 180.0;

epsilon = 0.001;
//huge = 1000 * 100; // 100 meters

huge = 400;

module half_cylinder(r,h) {
  // half a cylinder (half toward positive X axis), centered on Z
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


module anti_fillet(r,h) {
  // returns a rod of height `h` along the Z axis, `r+epsilon` on a side,
  // with a quarter-cylinder of radius `r` removed

  difference () {
    cube([r+epsilon,r+epsilon,h]);
    translate([0,0,-epsilon]) cylinder(r=r,h=h+2*epsilon);
  }
}

module anti_fillet_nw(r,h) {
  translate([r,-r,0])
  rotate([0,0,90]) anti_fillet(r,h);
}


module anti_fillet_ne(r,h) {
  translate([-r,-r,0])
  anti_fillet(r,h);
}


module anti_fillet_sw(r,h) {
  translate([r,r,0]) rotate([0,0,180]) anti_fillet(r,h);
}

module anti_fillet_se(r,h) {
  translate([-r,r,0])
  rotate([0,0,-90]) anti_fillet(r,h);
}


module huge_cube_above(z) {
 translate([-huge,-huge,z]) cube([2*huge,2*huge,huge]);
}

module huge_cube_right(x) {
 translate([x,-huge,-huge]) cube([huge,2*huge,2*huge]);
}

module huge_cube_behind(y) {
 translate([-huge,y,-huge]) cube([2*huge,huge,2*huge]);
}



module above(z) {
  intersection () {
    huge_cube_above(z);
    children();
  }
}

module below(z) {
  difference () {
    children();
    huge_cube_above(z);
  }
}

module right(x) {
  intersection () {
    children();
    huge_cube_right(x);
  }
}

module left(x) {
  difference () {
    children();
    huge_cube_right(x);
  }
}

module behind(y) {
  intersection () {
    children();
    huge_cube_behind(y);
  }
}

module infront(y) {
  difference () {
    children();
    huge_cube_behind(y);
  }
}

// ----------------------------------------------------------------

module hollow_cylinder(r1,r2,h,center=false) {
  difference () {
    cylinder(r=r2,h=h,center=center);
    translate([0,0,-epsilon])
      cylinder(r=r1,h=h+2*epsilon,center=center);
  }
}


// need theta such that (1 - cos theta) / sin theta = 2 * indent / curved

function curved_theta_function(theta) = (1 - cos(theta)) / sin(theta);

function curved_theta_delta(theta,curved,indent) =
  curved_theta_function(theta) - 2 * indent/ curved;

target_angle_epsilon = 0.005;

function best_curved_theta(curved,indent,lo,mid,hi) =
  curved_theta_delta(mid,curved,indent) > target_angle_epsilon
    ? best_curved_theta(curved,indent,lo, (lo + mid)/2, mid)
    : curved_theta_delta(mid,curved,indent) < -target_angle_epsilon
        ? best_curved_theta(curved,indent,mid, (mid+hi)/2, hi)
        : mid;

module curved_band(straight,curved,height,thickness,indent) {
  // step one: compute R and theta

  theta = best_curved_theta(curved,indent,0.1,22.5,45);
  R = curved / (2 * sin(theta));
  
  echo(oneminuscos=1-cos(theta),sintheta=sin(theta),ratio=curved_theta_function(theta),parmratio=2*indent/curved);
  echo(R=R,curved=curved,indent=indent,theta=theta,curved_from_theta=2*R*sin(theta),indent_from_theta=R-R*cos(theta));
  

  // dimensions given are *inside* dimensions, and origin
  // is on inside corner
  outerx = straight + 2 * thickness;
  outery = curved   + 2 * thickness;
  intersection () {
    translate([-thickness,-thickness,0])
      cube([outerx,outery,height]);
    union () {
      translate([-thickness,-thickness,0])
        cube([outerx,thickness,height]);
      translate([-thickness,curved,0])
        cube([outerx,thickness,height]);
      translate([-R*cos(theta)-thickness,curved/2,0])
        hollow_cylinder(r1=R,r2=R+thickness,h=height);
      translate([straight+R*cos(theta)+thickness,curved/2,0])
        hollow_cylinder(r1=R,r2=R+thickness,h=height);
    }
  }
}
//
//
//           
//
