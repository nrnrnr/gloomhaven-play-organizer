$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

epsilon = 0.001;
layer_height = 0.4;

include <BOSL2/std.scad>


function running_sum(vecs, i = 0, acc = []) =
    i >= len(vecs)
        ? acc
        : running_sum(
            vecs,
            i + 1,
            concat(acc, [i == 0 ? vecs[0] : acc[i-1] + vecs[i]])
          );

guard_width = 2;
plate_width = 0.46;
gripper_width = (guard_width - plate_width) / 2;
gripper_height = 5;

module gripper_shape() {
  linear_extrude(10)
    polygon([[0,0], [gripper_width, gripper_height/2], [0, gripper_height]]);
}  

module gripper(side, z) {
  if (side == "left") {
    translate([2 - epsilon, 13-gripper_height, z])
      gripper_shape();
  } else {
    translate([2+guard_width+epsilon, 13-gripper_height, z])
      mirror([1,0,0])
      gripper_shape();
  }
}
  
  
cross_section = running_sum([[0,0], [0,15], [2,-2], [0,-10], [2,0], [0,10], [2,2], [0,-15]]);

module end_cap() {
  linear_extrude(3)
    polygon(running_sum([[0,0], [0,15], [6,0], [0,-15]]));
}


module ear() {
  cyl(r=15,h=layer_height,anchor=BOTTOM);
  XXX BAD, make this two semicirles (U)
}

module guard() {
  rotate([90,0,0]) {
    linear_extrude(270)
      polygon(cross_section);
    for (z = [20:50:260])
      gripper("left", z);
    for (z = [45:50:260])
      gripper("right", z);
    end_cap();
    translate([0,0,270-3])
      end_cap();
  }  
  translate([3,0,0]) ear();
  translate([3,-270,0]) ear();
}
  
rotate([0,0,60])
guard();




  
