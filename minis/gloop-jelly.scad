//
// Big slow “gloops” jelly block: cuboid-ish base + hulled cap blobs.
// Designed to still look good after you difference() out wide channels,
// because it includes a light lattice of “anchors” across the whole footprint.
//
// Parameters:
//   size = [X,Y,Z] mm overall envelope
//   gloopiness = 0..1  (0 = subtle, 1 = very gloopy)
//   seed = deterministic randomness
//   cap_frac = fraction of Z used as the “active” top layer
//   wall_anchors = keep the cap pulled to the outer walls (more cuboid-ish)
//   lattice_anchors = sprinkle gentle anchors across the footprint (good after U-cut)
//

function _clamp(x,a,b) = x<a ? a : (x>b ? b : x);
function _lerp(a,b,t) = a + (b-a)*t;

module jelly_gloops(
  size=[50,75,22],
  gloopiness=0.75,
  freq=1.0,              // NEW: >1 = shorter wavelength, <1 = longer wavelength
  seed=1,
  cap_frac=0.28,
  wall_anchors=true,
  lattice_anchors=true
){
  lx=size[0]; ly=size[1]; h=size[2];
  g=_clamp(gloopiness, 0, 1);
  f=max(0.4, freq);

  cap = max(1.2, h*cap_frac);
  base_h = max(0.2, h - cap);

  // Frequency affects feature count and size.
  blob_n = round(_lerp(5, 14, g) * f*f);    // quadratically increases count with freq
  r_min  = _lerp(cap*0.55, cap*0.80, g) / sqrt(f);
  r_max  = _lerp(cap*0.90, cap*1.55, g) / sqrt(f);
  z_min  = _lerp(cap*0.55, cap*0.85, g);
  z_max  = _lerp(cap*0.90, cap*1.90, g);

  fn_blob = round(_lerp(18, 28, g));

  xs = rands(0, lx, blob_n, seed+101);
  ys = rands(0, ly, blob_n, seed+202);
  rs = rands(r_min, r_max, blob_n, seed+303);
  zs = rands(z_min, z_max, blob_n, seed+404);

  union() {
    cube([lx, ly, base_h], center=false);

    hull() {
      // Main random gloops (now more numerous + smaller when freq>1)
      for (i=[0:blob_n-1])
        translate([xs[i], ys[i], base_h])
          cylinder(h=zs[i], r=rs[i], $fn=fn_blob);

      if (wall_anchors) {
        edge_r = (cap*0.22) / sqrt(f);
        edge_h = cap*0.85;
        for (p=[[0,0],[lx,0],[0,ly],[lx,ly]])
          translate([p[0], p[1], base_h])
            cylinder(h=edge_h, r=edge_r, $fn=16);
        for (p=[[lx/2,0],[lx/2,ly],[0,ly/2],[lx,ly/2]])
          translate([p[0], p[1], base_h])
            cylinder(h=edge_h*0.95, r=edge_r*1.1, $fn=16);
      }

      if (lattice_anchors) {
        // Smaller step = higher spatial frequency support (good after U-cut).
        step = _lerp(26, 16, g) / f;
        a_r  = (cap*0.18) / sqrt(f);
        a_h  = cap*0.70;

        for (x=[step/2 : step : lx-step/2])
          for (y=[step/2 : step : ly-step/2]) {
            t = 0.5 + 0.5*sin((x*0.21 + y*0.17 + seed)*0.9);
            translate([x, y, base_h])
              cylinder(h=_lerp(a_h*0.65, a_h*1.15, t),
                       r=_lerp(a_r*0.85, a_r*1.25, t),
                       $fn=14);
          }
      }
    }
  }
}

// Examples:
// Longer wavelength: jelly_gloops([50,75,22], 0.8, freq=0.8, seed=7);
// Default:          jelly_gloops([50,75,22], 0.8, freq=1.0, seed=7);
jelly_gloops([50,75,22], 0.8, freq=3.0, seed=7);

// Example:
// jelly_gloops([50,75,22], gloopiness=0.99, seed=17,cap_frac=0.1);
// difference() { jelly_gloops([50,75,22], 0.8, 7); <your U-cut here>; }
