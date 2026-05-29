epsilon=0.01;

layer=0.2;

// Convert inches to millimeters
inch = 25.4;
base = 3 * inch;     // 76.2 mm
height = 3 * inch;   // 76.2 mm
thickness = 2;       // mm

module mouse_ear() {
  cylinder(r=7,h=layer);
}

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




// Define the 2D triangle shape (isosceles, flat base)
module dnd_cone(distance,thickness=2,ears=true) { // distance in feet
  base = distance / 5 * inch;
  height = base;
  linear_extrude(height=thickness)
  polygon(points=[
     [0,0], // apex
     [-base/2, height],                  // left base corner
     [base/2, height]
  ]);

  if (ears) {
    mouse_ear();
    translate([base/2,height,0]) mouse_ear();
    translate([-base/2,height,0]) mouse_ear();
  }
}

difference() {
  dnd_cone(15);
  small_in_inches = 3 - (0.5 + 1.118)/2;
  // total height is 3 inches, minus half an inch, minus 1.118 inches
  translate([0,1.118*inch/2,-epsilon])
    dnd_cone(15*small_in_inches/3,thickness=3,ears=false);
  translate([0,height-inch/8,thickness-default_label_thickness])
    negative_label("15 feet",size=4,valign="center");  


}

