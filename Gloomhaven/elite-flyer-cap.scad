
$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;   // help avoid issues with floating-point rounding error

thickness = 3.0;

base = [ 15.7, 15.9,  thickness ];

slop = 0.2; // slop around each edge

overhang = 0.6;

block = [ base.x + 2 * overhang, base.y + 2 * overhang, base.z ];


translate([0, 0, block.z])
rotate([0.0, 180, 0])
difference () {
  cube_filleted_columns(block, 1.5);
  translate([overhang - slop, overhang - slop, -1])
    cube_filleted_columns([base.x + 2 * slop, base.y + 2 * slop, base.z], 1);
  translate([block.x / 2.0 - thickness / 2.0 - slop, (block.y - 9.7) / 2.0, -epsilon])
    cube([thickness + 2 * slop, block.y, 2*block.z]);
}

