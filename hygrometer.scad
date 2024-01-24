
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

module cube_filleted_columns(x,y,z,r) {
  if (is_list(x) && is_num(y)) {   // also accepts cube_filleted_columns (vector, r)
    cube_filleted_columns(x.x, x.y, x.z, y);
  } else {
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
}

module hollow_cube(vector, thickness) {
  difference() {
    cube(vector);
    translate([thickness, thickness, -epsilon])
      cube([vector.x - 2*thickness, vector.y - 2*thickness, vector.z + 2*epsilon]);
  }
}


epsilon = 0.001;   // help avoid issues with floating-point rounding error
eps_vector = [epsilon, epsilon, epsilon];

layer_height = 0.2;

frame = [49.5, 30.3, 2.0]; // frame around the front with 1mm clearance
grip  = [45.2, 26.2, 4.0];    // grips the hygrometer tightly
frame_wrap = 3; // distance from edge of frame to edge of block (was 4, a bit thick)
block = [frame.x + 2 * frame_wrap, frame.y + 2 * frame_wrap, frame.z + grip.z];


magnet_diameter = 8.5;  // diameter for pocket, not magnet itself
magnet_thickness = 2.0;
magnet_sep_layers = 1;   // how many layers separate the magnet from the front of the panel?
magnet_separator = magnet_sep_layers * layer_height; 
                         // thickness of panel separating magnet from front

module old_magnet_wing(glue, thickness = block.z) { // sticks out too far in X
   // origin at center of magnet pocket
  difference () {
    union () {
      cylinder(r = magnet_diameter, h = thickness);
      translate([-magnet_diameter, -block.y/2, 0])
        cube([magnet_diameter, block.y, thickness]);
    }
    translate([0, -2*magnet_diameter, -epsilon])
      cylinder(r = magnet_diameter, h = thickness + 2*epsilon);
    translate([0,  2*magnet_diameter, -epsilon])
      cylinder(r = magnet_diameter, h = thickness + 2*epsilon);
    if (glue) {
      error("glue not implemented here");
    } else {
      translate([0,0,-thickness-magnet_separator])
        cylinder(d = magnet_diameter, h = 2 * thickness);
    }      
  }
}

module magnet_wing(glue, thickness = block.z) {
   // origin at center of magnet pocket
  wrap = 3; // additional radius around magnet
  wing_y = 2 * (magnet_diameter + wrap); // cube dimension
  difference () {
    union () {
      cylinder(r = magnet_diameter/2 + wrap, h = thickness);
      translate([-magnet_diameter/2, -wing_y/2, 0])
        cube([magnet_diameter/2, wing_y, thickness]);
    }
    translate([0, -magnet_diameter-wrap, -epsilon])
      cylinder(d = magnet_diameter, h = thickness + 2*epsilon);
    translate([0,  magnet_diameter+wrap, -epsilon])
      cylinder(d = magnet_diameter, h = thickness + 2*epsilon);
    if (glue) {
      error("glue not implemented here");
    } else {
      translate([0,0,-thickness-magnet_separator])
        cylinder(d = magnet_diameter, h = 2 * thickness);
    }      
  }
}

module holder (glue=false, support=false) {
  // glue: put indentation for magnet on front of holder
  // support: model the support (will need to be cut away)
  rotate([glue || support ? 180 : 0, 0, 0])
    union () {
      difference () {
        union () {
          cube_filleted_columns(block, frame_wrap-0.7);
          translate([block.x + magnet_diameter/2, block.y/2, 0]) magnet_wing(glue=glue);
          translate([        - magnet_diameter/2, block.y/2, 0])
            rotate([0,0,180]) magnet_wing(glue=glue);
        }
        translate([frame_wrap, frame_wrap, grip.z])
          union () {
            cube(frame + 2 * eps_vector);
            translate((frame - grip) / 2)
              translate([0,0,-block.z/2-epsilon]) cube(grip + 2 * eps_vector);
        }
      }
      if (support) {
        bridge_width = 1;
        scube = [grip.x - 2*bridge_width, grip.y - 2*bridge_width, block.z - grip.z + epsilon];
        translate([block.x - scube.x, block.y - scube.y, 2*grip.z]/2)
          hollow_cube(scube, 2); // support cube
        hcube = [frame.x, frame.y, layer_height];
        color("blue",alpha=0.5)
        translate([block.x-hcube.x, block.y-hcube.y, 2*grip.z]/2)
          hollow_cube(hcube, bridge_width + hcube.x - grip.x); // bridge layer
      }
  }
}

octagonclearance = -0.1; // for placing separately printed octagonal pegs in holes
  //                       (needed only for prototype)
  // when printed horizontally:
  // 0.3 is too loose
  // 0.2 slides with zero resistance but is also a bit loose
  // 0.1 slides with notable friction but not a lot of force;
  //     one end may require sanding
  //
  // when printed vertically
  //  0.1 is too loose
  //  0.0 is too loose

module peg() {
  base_height = 2;
  core_height = 3;
  core_diameter = magnet_diameter + 1;  // acts as a stop
  cylinder(d = core_diameter + 4, h = base_height + epsilon); // the base, to be pulled
  translate([0,0,base_height])
    union () {
      cylinder(d = core_diameter, h = core_height + epsilon);
      translate([0,0,core_height])
        cylinder($fn = 8, // the insert, leaves room for 1 magnet
                 d = magnet_diameter - octagonclearance,
                 h = block.z - magnet_separator - 1.2 * magnet_thickness);
  }
}

//holder();

//magnet_wing();

//translate([75, 38/2, -7]) peg();

//peg();

holder(support=true);



