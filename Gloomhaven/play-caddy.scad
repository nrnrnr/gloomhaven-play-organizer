
$fa = 1;    // fine resolution
$fs = 0.4;  // fine resolution

use <drawer.scad>

epsilon = 0.001;


tokenwidth = 29.8;
tokensep = 1.2;
ntokens = 8;
fullwidth = ntokens * (tokensep + tokenwidth) + tokensep;
tokenlength = 40;

width = fullwidth;
tokenheight = 25 - 9;

floor=1;

//epsilon = 0.001;

module token(index) {
  translate([index * (tokenwidth + tokensep),0,0])
    drawer(w=tokenwidth,h=tokenheight,l=tokenlength,sep=tokensep,theta=45,floor=floor);
}


// coins
//coinwidth = 80.7;
//coinsep = (width - 3.0 * coinwidth) / 4.0;

coinsep = tokensep;
coinwidth = (width - 4 * coinsep) / 3.0;
coinlength = 63;
coinheight = 20;

module coin(index) {
  translate([index * (coinwidth + coinsep),tokenlength,0])
    drawer(w=coinwidth,h=coinheight,l=coinlength,sep=coinsep,theta=45,floor_y_shift=2*coinlength+30,floor=floor);
}

//translate([0,-coinarc-10,0]) cube([coinwidth,coinarc,0.2]);
//translate([coinwidth+10,-tokenarc-10,0]) cube([tokenwidth,tokenarc,0.2]);

//module coin(index) {
//  translate([coinsep+coinwidth/2+index *(coinwidth+coinsep),34+coindepth/2,coinradius+2])
//    rotate([0,90,0])
//      cylinder(h=coinwidth,r=coinradius,center=true);
//}
//
//module oldtoken(index) {
//  width = tokenwidth;
//  sep = 0.6;
//  radius = 15.1;  // chord 30, depth 13.5
//  depth = 13.5;
//  
//
//  translate([sep+width/2+index *(width+sep),1.2+radius,tokenheight+radius-depth])
//    rotate([0,90,0])
//      cylinder(h=width,r=radius,center=true);
//}

module oldcards(index) {
  width = 77;
  depth = 20;
  sep =	(fullwidth - 3 * width) / 4;
  chamfer = 6;
//  translate([10 * index + 50 + coinsep + (coinwidth-width)/2 + (coinwidth+coinsep)*index,
//             tokenlength + coinlength,
//             fullheight - depth])
    translate([10 * index, 0, 0])
    union() {
      color("red") cube([width,5,depth]);

//   translate([10 * index,0,0])
      translate([0,2.5,depth-chamfer*1.414/2]) color("blue") 
         rotate([45,0,0]) cube([width,chamfer,chamfer]);
    }
}

cardthickness = 5;
carddepth = 20;
cardheight = max(carddepth + floor, coinheight);

module cardtranslate(index) {
   translate([index * (coinwidth+coinsep) - coinsep, tokenlength+coinlength,0])
   children();
}


module cardbounding(index) {
   cardtranslate(index)
   cube([coinwidth+2*coinsep+epsilon, cardthickness+ 2 * coinsep+epsilon, cardheight]);
}

module cards(index) {
  width = 77;
  sep =	(fullwidth - 3 * width) / 4;
  depth = carddepth;
  height = cardheight;
  chamfer = (cardthickness + coinsep) / sqrt(2);

  echo(coinwidth=coinwidth,coinsep=coinsep);

  difference () {
    cardbounding(index);
    cardtranslate(index)
      translate([coinsep+index*(coinwidth-width)/2, coinsep, height-depth])
        union () {
          cube([width+epsilon,cardthickness+epsilon,depth+epsilon]);
          translate([0,cardthickness/2,depth-chamfer/sqrt(2)]) 
            rotate([45,0,0]) cube([width+epsilon,chamfer,chamfer]);
        }
   }
}


//// //  translate([10 * index + 50 + coinsep + (coinwidth-width)/2 + (coinwidth+coinsep)*index,
//// //             tokenlength + coinlength,
//// //             fullheight - depth])
////     translate([10 * index, 0, 0])
////     union() {
////       color("red") cube([width,5,depth]);
//// 
//// //   translate([10 * index,0,0])
////       translate([0,2.5,depth-chamfer*1.414/2]) color("blue") 
////          rotate([45,0,0]) cube([width,chamfer,chamfer]);
////    }
//}

//translate([0,20,0]) cards(0);

module lidhole(index) {
  width = 3;
  depth = fullheight - 5;
  translate([coinsep/2+index*(coinwidth+coinsep), 2+30+80+2+2+1+width/2, fullheight-depth/2])
    cylinder(h=depth+1,r=width/2,center=true);
}





module caddy () {

  difference () {
    union () {
      for (i=[0:1:7]) {
        token(i);
      }
      for (i=[0:1:2]) {
        coin(i);
      }
    }
    for (i=[0:1:2]) {
      cardbounding(i);
    }
  }
  for (i=[0:1:2]) {
    cards(i);
  }

//  difference () {
//    lidhole(1);
//    lidhole(2);
//    // cut for prototyping
//    translate([coinsep*2+coinwidth,-1,-1]) cube([width,123*1.2,fullheight*1.2]);
//    translate([31,-1,-1]) cube([width,33, fullheight*1.2]);
//
//  }

}


module test() {
  token(0);
//  coin(0);
}


//token(0);

caddy();

//test();




