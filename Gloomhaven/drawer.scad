
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
  rotate([0,0,-90]) anti_fillet(h,r);
}

module rotate_at(rotation, translation) {
  translate(translation)
    rotate(rotation)
    translate(-translation)
    children();
}


module anti_chamfer_sw(w,h,lo_corner=false, hi_corner=false) {
  top_extension = hi_corner ? w : 0;
  bot_extension = lo_corner ? w : 0;
  negative_thickness = w * sqrt(2) + epsilon;
  total_h = h + top_extension + bot_extension;
  difference () {
    render () intersection () {
      translate([0,0,-bot_extension])
        cube([w,w,total_h]);
      rotate_at([0,0,45],[w,0,0])
        translate([w-negative_thickness,0,-epsilon-bot_extension])
        cube([negative_thickness,negative_thickness,total_h]);
    }
    nt = negative_thickness + 2*epsilon;
    if (hi_corner) {
      translate([-epsilon,0,h])
        rotate([45,0,0])
        cube([nt,nt,nt]);
    }
    if (lo_corner) {
      translate([-epsilon,0,0])
        rotate([45+180,0,0])
        cube([nt,nt,nt]);
    }
  }
}

module anti_chamfer_south(w,h,lo_corner=false, hi_corner=false) {
  // south side of a solid, north side of a hole
  rotate([0,90,0]) anti_chamfer_sw(w,h,lo_corner=lo_corner, hi_corner=hi_corner);
}

module anti_chamfer_east(w,h,lo_corner=false, hi_corner=false) {
  rotate([0,0,90]) anti_chamfer_south(w,h,lo_corner=lo_corner, hi_corner=hi_corner);
}
module anti_chamfer_north(w,h,lo_corner=false, hi_corner=false) {
  translate([h,0,0]) rotate([0,0,180]) anti_chamfer_south(w,h,lo_corner=lo_corner, hi_corner=hi_corner);
}
module anti_chamfer_west(w,h,lo_corner=false, hi_corner=false) {
  rotate([0,0,90]) anti_chamfer_north(w,h,lo_corner=lo_corner, hi_corner=hi_corner);
}


module chamfered_well(size,depth) {
  cube(size);
  translate([-epsilon,epsilon,size.z])
    anti_chamfer_north(w=depth+epsilon,h=size.x+2*epsilon,hi_corner = true, lo_corner = true);
  translate([epsilon,-epsilon,size.z])
    anti_chamfer_east(w=depth+epsilon,h=size.y+2*epsilon,hi_corner = true, lo_corner = true);
  translate([-epsilon,size.y-epsilon,size.z])
    anti_chamfer_south(w=depth+epsilon,h=size.x+2*epsilon,hi_corner = true, lo_corner = true);
  translate([size.x-epsilon,-epsilon,size.z])
    anti_chamfer_west(w=depth+epsilon,h=size.y+2*epsilon,hi_corner = true, lo_corner = true);
}




////////////////////////////////////////////////////////////////

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


module lift(z) {
  translate([0,0,z])
    children();
}


////////////////////////////////////////////////////////////////

// shear such that point will translate by [p.x,p.y] as z-axis is traversed by p.z units
module shear_along_z(p) {
  multmatrix([
    [1,0,p.x/p.z,0],
    [0,1,p.y/p.z,0],
    [0,0,1,0]
  ]) children();
}


module support_fin(theta, length, base_width=40, layer_height = 0.2) {
  // bottom tip shifted from origin by fin_gap (along X)
  fin_length = length;
  fin_thickness = 2;
  fin_gap = 0.75;
  base_length = fin_length * cos(theta);
  fin_height = fin_length * sin(theta);
  base_thickness = 1;
  base_gap = 5; // between bottom point of fin and base

  module anti_tooth(d, h) {
    translate([-d/2, -d/2, -h/2])
    cube([d, d, h]);
  }

  module old_unplaced_sprue() {
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

  module unplaced_sprue() {
    // center bottom tip is at origin
    tip_thickness = 0.5;  // from video
    sprue_length = fin_gap / sin(theta)  + tip_thickness / tan(theta);
    tip_length = 0.1 + tip_thickness / tan(theta);
    base_points =  [[0,-tip_thickness/2],
                    [tip_length,-tip_thickness/2],
                    [sprue_length, -fin_thickness/2],
                    [sprue_length, fin_thickness/2],
                    [tip_length,tip_thickness/2],
                    [0,tip_thickness/2]];
 //   translate([tip_thickness / tan(theta) - sprue_length + epsilon, 0, 0])
    shear_along_z([1/tan(theta),0,1])
      linear_extrude(tip_thickness)
      polygon(base_points);
  }

  sprue_vertical_spacing = 10;

  module sprue(i) {
    translate([i * sprue_vertical_spacing / tan(theta), 0, i * sprue_vertical_spacing])
      unplaced_sprue();
  }

  sprue(0.1);
  for(i=[1:fin_height/sprue_vertical_spacing])
    sprue(i);

  translate([fin_gap / sin(theta),0,0])
    union () {
      translate([0, fin_thickness/2, 0])
      rotate([90,0,0])
        linear_extrude(fin_thickness)
        polygon([[0,0], [base_length, 0], [base_length, fin_length * sin(theta)]]);
      translate([base_gap, 0, 0])
        cylinder(r=base_gap, h=layer_height); // mouse ear
      linear_extrude(base_thickness)
        hull() {
          translate([base_gap + 2.5, 0, 0]) circle(r=2.5);
          offset = base_width / 2 - 5;
          translate([base_length - 5, offset, 0])  circle(r=5);
          translate([base_length - 5, -offset, 0]) circle(r=5);
        }
  }

}


module anti_chamfer_bottom(dimens, width, theta) {
  w = width;
  translate([-epsilon, w * cos(theta), -epsilon])
    rotate([90 - theta, 0, 0])
    translate([0,-dimens.y,0])
    cube([dimens.x + 2 * epsilon, dimens.y, dimens.z]);
  translate([-epsilon, dimens.y - w * cos(theta), -epsilon])
    rotate([theta - 90, 0, 0])
    cube([dimens.x + 2 * epsilon, dimens.y, dimens.z]);

  translate([w * cos(theta), -epsilon, -epsilon])
    rotate([0, theta - 90, 0])
    translate([-dimens.x,0,0])
    cube([dimens.x, dimens.y + 2 * epsilon, dimens.z]);

  translate([dimens.x - w * cos(theta), -epsilon, -epsilon])
    rotate([0, 90 - theta, 0])
    cube([dimens.x, dimens.y + 2 * epsilon, dimens.z]);
}
