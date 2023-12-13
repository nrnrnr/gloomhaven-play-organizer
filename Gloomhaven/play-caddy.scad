
$fa = 1;    // fine resolution
$fs = 0.4;  // fine resolution

use <drawer.scad>

epsilon = 0.001;

inserts = false;

tokenwidth = 29.8;
tokensep = 1.2;
ntokens = 8;
fullwidth = ntokens * (tokensep + tokenwidth) + tokensep;
tokenlength = 40;

width = fullwidth;
tokenheight = 25 - 9;

floor=1;

module token(index) {
  translate([index * (tokenwidth + tokensep),0,0])
    drawer(w=tokenwidth,h=tokenheight,l=tokenlength,sep=tokensep,theta=45,floor=floor,insert=inserts);
}

coinsep = tokensep;
coinwidth = (width - 4 * coinsep) / 3.0;
coinlength = 63;
coinheight = 20;

module coin(index) {
  translate([index * (coinwidth + coinsep),tokenlength,0])
    drawer(w=coinwidth,h=coinheight,l=coinlength,sep=coinsep,theta=45,floor_y_shift=2*coinlength+30,floor=floor,insert=inserts);
}

cardthickness = 5;
carddepth = 20;
cardheight = max(carddepth + floor, coinheight);
cardwidth = 77;

module cardtranslate(index) {
   translate([index * (coinwidth+coinsep) - coinsep, tokenlength+coinlength,0])
   children();
}

module cardbounding(index) {
   cardtranslate(index)
   cube([coinwidth+2*coinsep+epsilon, cardthickness+ 2 * coinsep+epsilon, cardheight]);
}

module cards(index) {
  width = cardwidth;
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

blockwidth = coinsep + (coinwidth - cardwidth) * 1.5;


module lidhole(index) {
  width = 3;
  depth = cardheight - 5;

  cardtranslate(index)
    translate([(3 - index) * (cardwidth-coinwidth)/2 + blockwidth/2, cardthickness/2+coinsep, cardheight-depth])
    cylinder(h=depth+epsilon,r=width/2);
}





module caddy () {

  difference () {
    union () {
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
    }
    lidhole(1);
    lidhole(2);
  }

}


module test() {
  token(0);
//  coin(0);
}


//token(0);

caddy();

//test();




