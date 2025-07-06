$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4/25.4;  // minimum size (fine resolution)


use <Gloomhaven/drawer.scad>

module inches() {
  scale([25.4,25.4,25.4]) children();
}

epsilon = 0.0001;

spout_cylinder = false;
spout_cube = false;
rear_spouts = true;


width_inside = 6.5; // inches
length_inside = 8.25;

wall_thickness = 5/16;

depth = 1/2;

outside_corner_radius = 0.7;
inside_corner_radius = outside_corner_radius - wall_thickness;

extension = 1.5;
wing = 0.75; 

support_surround = 1; // blank area around supports
supports_width = width_inside - 2 * support_surround;
nsupports = 5;
support_spacing = supports_width / nsupports;

echo(support_spacing = support_spacing);


support_height = 5/16;

module support_row(n=nsupports,less=0) {
  for (i=[0:1:n-less]) {
    translate([i*support_spacing,0,-epsilon])
    cylinder(d=support_spacing/3,h=support_height+epsilon);
  }
}

module spout(h,theta=35,base=5*wall_thickness) {
  // create triangular prism with tip at origin and pointing to the negative Y axis
  linear_extrude(h)
    polygon([[0,0],[base*tan(theta),base],[-base*tan(theta),base]]);
}
  


module tray () {

  module xline(x) {
    color("blue")
    translate([x,-wall_thickness,-wall_thickness])
    cube([0.2 / 25.4, length_inside + 4 * wall_thickness, depth + 3 * wall_thickness]);
  }

  module yline(y) {
    color("blue")
    translate([-wall_thickness,y,-wall_thickness])
    cube([length_inside + 4 * wall_thickness, 0.2 / 25.4, depth + 3 * wall_thickness]);
  }


  wing_length = 1/4;


difference () {
  corner_theta = acos(inside_corner_radius/outside_corner_radius);
  delta_xy = outside_corner_radius * sin(corner_theta) - inside_corner_radius-1/25.4;

  union () {

    difference () {
      cube_filleted_columns(width_inside+2*wall_thickness,
                            length_inside+2*wall_thickness,
                            depth+wall_thickness+epsilon,
                            outside_corner_radius);
      
      translate([wall_thickness,wall_thickness,wall_thickness])
        cube_filleted_columns(width_inside,
                              length_inside,
                              depth+2*epsilon,
                              outside_corner_radius-wall_thickness);
      translate([wall_thickness,wall_thickness+length_inside/2+delta_xy,wall_thickness])
        cube([width_inside, length_inside/2, depth+2*epsilon]);
      
      // front cutout
      translate([wall_thickness+wing_length, -epsilon, wall_thickness+support_height])
        cube([width_inside-2*wing_length, 1.7 * wall_thickness+2*epsilon, depth+epsilon]);
    }
    
    if (spout_cube || spout_cylinder) {
      infront(outside_corner_radius)
      left(outside_corner_radius)
      translate([outside_corner_radius,outside_corner_radius,depth+wall_thickness])
      hollow_cylinder(r1=outside_corner_radius-wall_thickness,r2=outside_corner_radius,h=extension);
      translate([outside_corner_radius,0,depth+wall_thickness])
        cube([wing,wall_thickness,extension]);
      translate([0,outside_corner_radius,depth+wall_thickness])
        cube([wall_thickness,wing,extension]);
    }
  }

  if (false && rear_spouts) {
    h = depth + epsilon;
    xy = outside_corner_radius;

    //xline(wall_thickness);
    //yline(wall_thickness+length_inside);
    //
    //xline(wall_thickness - delta_xy);
    //yline(wall_thickness+length_inside+delta_xy);
    theta = asin(delta_xy/depth);

    translate([wall_thickness,wall_thickness+length_inside-outside_corner_radius,wall_thickness])
       translate([0,xy,0])
       rotate([0,0,-90])
      render() above(0)
      rotate([theta,-theta,0])
      //shear_along_z([-0*delta_xy,delta_xy,h])
      translate([0,0,-h])
      cube([xy, xy, 3*h+epsilon]);

  }


  if (spout_cylinder) {
    theta = asin((wall_thickness-2/16)/(extension+depth));
    echo (theta=theta);
    translate([outside_corner_radius,outside_corner_radius,wall_thickness])
    above(0)

      rotate([theta,-theta,0])
          cylinder(r=outside_corner_radius-wall_thickness,h=extension+depth+wall_thickness);
//        hollow_cylinder(r1=outside_corner_radius-wall_thickness,r2=outside_corner_radius,h=extension+depth+wall_thickness);
  } 
  if (spout_cube) {
    corner_dx_dy = outside_corner_radius - inside_corner_radius * sin(45);
    
    theta = atan((wall_thickness-0.5/25.4)/(extension+depth));
    echo (theta=theta);
      translate([corner_dx_dy,corner_dx_dy,wall_thickness])
      rotate([0,0,-45])
      rotate([theta,0,0])
      spout();
//      rotate([0,0,-45])
//      rotate([theta,0,0])
//      rotate([0,0,45])
//          cube([2*outside_corner_radius,2*outside_corner_radius,depth+extension+0.5]);
  }


  if (spout_cube || spout_cylinder) {
    translate([wing+outside_corner_radius,0,depth+wall_thickness])
    union () {
      anti_fillet_se(r=wall_thickness/2,h=extension+2*epsilon);
      translate([0,wall_thickness,0])
        anti_fillet_ne(r=wall_thickness/2,h=extension+2*epsilon);
    }
    translate([0,wing+outside_corner_radius,depth+wall_thickness])
    union () {
      anti_fillet_nw(r=wall_thickness/2,h=extension+2*epsilon);
      translate([wall_thickness,0,0])
        anti_fillet_ne(r=wall_thickness/2,h=extension+2*epsilon);
    }
  }


}





module support_row_pair(second = true) {
  support_row();
  if (second) { 
    translate([support_spacing * cos(60), support_spacing * sin(60), 0])
      support_row(less = 1);
  }
}

yslop = length_inside - 8 * support_spacing * sin(60);

  translate([0,yslop/2-support_surround,0])
    for (i=[0:1:4]) {
      translate([0, i*2*support_spacing*sin(60),0])
      translate([wall_thickness + support_surround,wall_thickness+support_surround,wall_thickness])
        support_row_pair(i < 4);
    }

}

//rotate([0,0,90]) 
inches() tray();

//color("blue") inches() spout();
