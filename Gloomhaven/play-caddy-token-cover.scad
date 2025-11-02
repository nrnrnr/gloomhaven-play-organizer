edition = 1;

include <play-caddy.scad>

translate([0,0,coinheight-tokenheight])
rotate([180,0,0])
  token_cover();

