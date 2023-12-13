
$fa = 1;    // fine resolution
$fs = 0.4;  // fine resolution


tokenwidth = 30;
tokensep = 0.8;
ntokens = 8;
fullwidth = ntokens * (tokensep + tokenwidth) + tokensep;

width = fullwidth;
tokenheight=25;
fullheight = 33;


module body() {
  cube([width,123,tokenheight]);
  translate([0,32,0])
          cube([246.2,123-32,fullheight]);
}

// coins
coinwidth = 80.7;
coinsep = (width - 3.0 * coinwidth) / 4.0;
coindepth = 80; // Y axis
coinradius=41; // calculated radius = 41, angle = 77.3, depth = 32, chord = 79.99
coinheight=32;

function radians(d) = d * PI / 180.0;

coinarc = 41 * radians(77.3);


//translate([0,-coinarc-10,0]) cube([coinwidth,coinarc,0.2]);
//translate([coinwidth+10,-tokenarc-10,0]) cube([tokenwidth,tokenarc,0.2]);

module coin(index) {
  translate([coinsep+coinwidth/2+index *(coinwidth+coinsep),34+coindepth/2,coinradius+2])
    rotate([0,90,0])
      cylinder(h=coinwidth,r=coinradius,center=true);
}

module oldtoken(index) {
  width = tokenwidth;
  sep = 0.6;
  radius = 15.1;  // chord 30, depth 13.5
  depth = 13.5;
  

  translate([sep+width/2+index *(width+sep),1.2+radius,tokenheight+radius-depth])
    rotate([0,90,0])
      cylinder(h=width,r=radius,center=true);
}

module cards(index) {
  width = 77;
  depth = 20;
  sep =	(fullwidth - 3 * width) / 4;
  chamfer = 6;
  translate([coinsep + (coinwidth-width)/2 + (coinwidth+coinsep)*index,
             2+30+80+2+2,
             fullheight - depth])
    union() {
      color("red") cube([width,5,depth]);

      translate([0,2.5,depth-chamfer*1.414/2]) color("blue") 
         rotate([45,0,0]) cube([width,chamfer,chamfer]);
    }
}

//translate([0,20,0]) cards(0);

module lidhole(index) {
  width = 3;
  depth = fullheight - 5;
  translate([coinsep/2+index*(coinwidth+coinsep), 2+30+80+2+2+1+width/2, fullheight-depth/2])
    cylinder(h=depth+1,r=width/2,center=true);
}


epsilon = 0.001;

floor = 1;

module half_cylinder(r,h) {
  // half a cylinder (half toward positive X axis)
  difference() {
    cylinder(r=r,h=h,center=true);

    translate([-2*r,-r,-h])
      cube([2*r, 2*r, 2*h]);
  }
}

module drawer (h=25, w=30, l=40, r=10, theta=30, c=10, sep=0.8, floor_y_shift=-10, layer_height=0.2) {
  // h     = drawer height
  // w     = drawer width
  // l     = drawer length (depth) front to back
  // r     = radius of rear curve
  // theta = angle drawer front makes with vertical
  // c     = length of circumscribed line on front radius
  // sep   = material around drawer


  phi   = 90 - theta;         // complement of theta (90 - theta)
  R     = c / tan(phi/2);     // radius of front curve
  touch = l - h * tan(theta); // distance from rear to where front slant floor touches

  slant_length = h / cos(theta); // hypotenuse of front triangle

  cube_height = slant_length - c;


  translate([0,0,floor])
  difference () {
    // make cube including sep and epsilon
    translate([-sep, 0, -floor])
      cube([w + 2 * sep, l + sep + epsilon, h + floor]);

    // subtract upper back cube
    translate([0, l - r, r - epsilon])
      cube([w, r, h - r + 2 * epsilon]);

    // subtract central cube between cylinders
    translate([0, l - touch + c - epsilon, 0])
      cube([w, touch - r - c + 2 * epsilon, h + epsilon]);

    // subtract rear half-cylinder
    translate([w/2, l - r, r])
      rotate([90,0,0])
        rotate([0,90,0])
          half_cylinder(h=w,r=r);

    // subtract front half-cylinder
    translate([w/2, l - touch + c, R])
      rotate([-90,0,0])
        rotate([0,90,0])
          half_cylinder(h=w,r=R);



    // subtract tilted cube
    translate([0,0,h])
      rotate([theta,0,0])
        translate([0,0,-cube_height])
          cube([w, tan(phi) * cube_height, cube_height]);
  }

  floor_length = r * PI / 2 + touch - c - r + R * radians(phi) + slant_length - c;

  floor_trim = 0.6;

  translate([0,floor_y_shift-floor_length,0])
    cube([w-floor_trim,floor_length - floor_trim, layer_height]);


//  color("blue") translate([-w/2,0,0])
//    translate([0,0,h])
//      rotate([theta,0,0])
//        translate([0,0,-cube_height])
//          cube([w, tan(phi) * cube_height, cube_height]);


//  color("blue")
//    translate([0, touch, 0])
//      cube([w, touch - r - c + epsilon, h + epsilon]);
//
//  color("green")
//    translate([35, l - touch + c, 0])
//      cube([w, touch - r - c + epsilon, 2 * h + epsilon]);
//
//
//  color("red")
//     translate([w/2, l - touch + c, R])
//      rotate([-90,0,0])
//        rotate([0,90,0])
//          half_cylinder(h=w,r=R);
//
//  color("yellow")
//      rotate([-90,0,0])
//        rotate([0,90,0])
//          half_cylinder(h=w,r=R);



}

module token(index) {
  translate([index * (tokenwidth + tokensep),0,0])
    drawer(w=tokenwidth,h=tokenheight,sep=tokensep);
}



module caddy () {

//  union () {
    for (i=[0:1:7]) {
      token(i);
    }
//  }


//  difference () {
//    difference () {
//      body();
//      coin(0);
//      coin(1);
//      coin(2);
//      for (i=[0:1:7]) {
//        token(i);
//      }
//      for (i=[0:1:2]) {
//        cards(i);
//      }
//    }
//    lidhole(1);
//    lidhole(2);
//    // cut for prototyping
//    translate([coinsep*2+coinwidth,-1,-1]) cube([width,123*1.2,fullheight*1.2]);
//    translate([31,-1,-1]) cube([width,33, fullheight*1.2]);
//
//  }

}




drawer();

