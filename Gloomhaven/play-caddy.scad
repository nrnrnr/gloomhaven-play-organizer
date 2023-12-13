
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

//  echo(coinwidth=coinwidth,coinsep=coinsep);

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


default_r = 10;

module card_label(index, s) {
  thickness = 0.4;
  translate([coinsep + index * (coinsep + coinwidth) + coinwidth/2,
             tokenlength+coinlength+thickness-epsilon,
             coinheight-default_r+3])
  rotate([90,0,0])
  linear_extrude(thickness)
  text(s, font = "Pirata One", halign = "center", size=6, valign="baseline");
}

module token_label(index, s) {
  thickness = 0.4;
  translate([index * (tokensep + tokenwidth) + tokenwidth/2,
             thickness-epsilon,
             tokenheight/2+1])
  rotate([90,0,0])
  linear_extrude(thickness)
  text(s, font = "gloomhaven conditions", halign = "center", size=9, valign="center");
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
    card_label(0, "Player Curse");
    card_label(1, "Bless");
    card_label(2, "Monster Curse");
    token_label(0, "P");
    token_label(1, "W");
    token_label(2, "I");
    token_label(3, "D");
    token_label(4, "U");
    token_label(5, "M");
    token_label(6, "S");
    token_label(7, "V");
  }

}


//translate([0,-10,0]) text("P", font = "gloomhaven conditions", halign="center", size = 6, valign="baseline");

translate ([0, 10, 0]) caddy();

// ruler
//for (i=[0:1:35]) translate([-tokensep+i-0.05, 0, 14]) color("blue") cube([0.1, 2, 7]);

//difference () { coin(0); card_label(0, "Player Curse"); }




