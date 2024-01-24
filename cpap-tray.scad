$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4/25.4;  // minimum size (fine resolution)


use <Gloomhaven/drawer.scad>

module inches() {
  scale([25.4,25.4,25.4]) children();
}

epsilon = 0.0001;

spout_cylinder = false;


width_inside = 6.5; // inches
length_inside = 8.25;

wall_thickness = 5/16;

depth = 1 + 1/4;

outside_corner_radius = 0.7;
inside_corner_radius = outside_corner_radius - wall_thickness;

extension = 1.5;
wing = 0.75; 

support_surround = 1; // blank area around supports
supports_width = width_inside - 2 * support_surround;
nsupports = 5;
support_spacing = supports_width / nsupports;

echo(support_spacing = support_spacing);


support_height = 1/4;

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


difference () {
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
      
    }
    
    infront(outside_corner_radius)
    left(outside_corner_radius)
    translate([outside_corner_radius,outside_corner_radius,depth+wall_thickness])
    hollow_cylinder(r1=outside_corner_radius-wall_thickness,r2=outside_corner_radius,h=extension);
    translate([outside_corner_radius,0,depth+wall_thickness])
      cube([wing,wall_thickness,extension]);
    translate([0,outside_corner_radius,depth+wall_thickness])
      cube([wall_thickness,wing,extension]);
  }

  if (spout_cylinder) {
    theta = asin((wall_thickness-2/16)/(extension+depth));
    echo (theta=theta);
    translate([outside_corner_radius,outside_corner_radius,wall_thickness])
    above(0)
      rotate([theta,-theta,0])
          cylinder(r=outside_corner_radius-wall_thickness,h=extension+depth+wall_thickness);
//        hollow_cylinder(r1=outside_corner_radius-wall_thickness,r2=outside_corner_radius,h=extension+depth+wall_thickness);
  } else {
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
