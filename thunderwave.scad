epsilon=0.01;

layer=0.2;

// Convert inches to millimeters
inch = 25.4;
thickness = 2;       // mm

function feet(n) = n * inch / 5.0;

module pirata(s,size=8,valign="baseline") {
  text(s, font = "Pirata One", halign = "center", size=size, valign=valign);
}

default_label_thickness = 0.4;  // for incised/recessed labels

module negative_label(s, size=10, valign="baseline") {
  // place 3D label at origin at default thickness plus a lot
  // (meant to be subtracted from a solid)
  thickness = default_label_thickness+epsilon;
  linear_extrude(thickness+1)
    pirata(s, size=size, valign=valign);
}

width = 0.3 * inch;

module spin(degrees) {
  rotate([0,0,degrees])
    children();
}

difference() {
  cube([feet(15), feet(15), thickness]);
  translate([width, width, -epsilon])
    cube([feet(15) - 2 * width, feet(15) - 2 * width, thickness+2*epsilon]);
  translate([feet(15)/2,width/2,thickness-default_label_thickness])
    negative_label("15 feet",size=5,valign="center");  
  translate([feet(15)/2,feet(15)-width/2,thickness-default_label_thickness])
    spin(180)
    negative_label("15 feet",size=5,valign="center");  
  translate([feet(15)-width/2,feet(15)/2,thickness-default_label_thickness])
    spin(90)
    negative_label("15 feet",size=5,valign="center");  
  translate([width/2,feet(15)/2,thickness-default_label_thickness])
    spin(-90)
    negative_label("15 feet",size=5,valign="center");  
}

