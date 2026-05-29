include <BOSL2/std.scad>;

layer=0.2;


intersection() {
  import("Recycle.stl");
  cuboid([200,200,3*layer], p1=[-100,-100,0]);
}
