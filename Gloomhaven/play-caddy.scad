$fa = 1;    // fine resolution
$fs = 0.4;  // fine resolution

use <drawer.scad>

epsilon = 0.001;

inserts = false;
add_text = false;

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

fulllength = tokenlength+coinlength + cardthickness + 2 * coinsep;


module displayed_cards(index) {
  translate([0,0,floor])
    cardtranslate(index)
      cube([cardwidth, cardthickness, 46]);
}


smallcardheight = 68;
smallcardwidth = 44;


module rear_card_slot(index) {
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
          cube([width+epsilon,cardthickness+epsilon,smallcardwidth+epsilon]);
          translate([0,cardthickness/2,depth-chamfer/sqrt(2)]) 
            rotate([45,0,0]) cube([width+epsilon,chamfer,chamfer]);
        }
   }
}

module rear_cards(index) {
  width = cardwidth;
  sep =	(fullwidth - 3 * width) / 4;
  depth = carddepth;
  height = cardheight;
  chamfer = (cardthickness + coinsep) / sqrt(2);

//  echo(coinwidth=coinwidth,coinsep=coinsep);

    cardtranslate(index)
      translate([coinsep+index*(coinwidth-width)/2, coinsep, height-depth])
        union () {
          cube([width+epsilon,cardthickness+epsilon,smallcardwidth+epsilon]);
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
  if (add_text) {
    rotate([90,0,0])
    linear_extrude(thickness)
    text(s, font = "Pirata One", halign = "center", size=6, valign="baseline");
  } else {
    color ("white") translate([-20,0,0]) cube([40,10,thickness]);
  }
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

// GH conditions: D disarm
//                I immobilize
//                M muddle
//                P poison
//                S strengthen
//                U stun
//                V invisible
//                W wound
//                Z regenerate


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
        rear_card_slot(i);
      }
    }
    lidhole(1);
    lidhole(2);
    card_label(0, "Player Curse");
    card_label(1, "Bless");
    card_label(2, "Monster Curse");
    if (add_text) {
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

}


//translate([0,-10,0]) text("P", font = "gloomhaven conditions", halign="center", size = 6, valign="baseline");

//translate ([0, 10, 0]) caddy();

// ruler
//for (i=[0:1:35]) translate([-tokensep+i-0.05, 0, 14]) color("blue") cube([0.1, 2, 7]);

//difference () { coin(0); card_label(0, "Player Curse"); }

////////////////////////////////////////////////////////////////



eventcardheight = 88;
eventcardwidth = 63;

cardleeway = 1;

exteriorcardsep = 5;
interiorcardsep = (fullwidth - 
                   2 * exteriorcardsep - 
                   2 * (eventcardwidth + smallcardwidth + 2 * cardleeway)) / 3.0;


separator_thickness = 2;

numberthickness = 27;
eventthickness = 27; // TODO measure
caddyheight = floor + max(numberthickness,eventthickness) + 3;


module thumbcutout () {
  union () {
    translate([-14,-14,-50]) cube([28,28+epsilon,100]);
    translate([0,14,0]) cylinder(r=14,h=100,center=true);
  }
}



module event_cards(thickness=26) {
  union () {
    difference() {
      color("red")
      cube_filleted_columns(eventcardwidth+cardleeway,eventcardheight+cardleeway,thickness+separator_thickness,1.5);
      translate([0,2,thickness/2]) event_separator_gap();
    }
    color("white") translate([0,2,thickness/2]) event_separator();
  }
}

module event_cards_negated(thickness=26) {
   cube_filleted_columns(eventcardwidth+cardleeway,eventcardheight+cardleeway,thickness+50,1.5);
}

module event_separator_gap(x_shift=cardleeway) {
  color("white") translate([-10,-10,0]) cube_filleted_columns(eventcardwidth+20,eventcardheight+20,separator_thickness,1.5);
}

module event_separator(x_shift=cardleeway) {
  leeway = 3;
  color("white") cube_filleted_columns(eventcardwidth,eventcardheight-leeway,separator_thickness,1.5);
  wrapwidth = 14; // must be larger than for front card cout
  color("white")
  translate([wrapwidth,-exteriorcardsep,0]) cube_filleted_columns(eventcardwidth - 2 * wrapwidth, leeway+ exteriorcardsep + epsilon + 1.5, separator_thickness, 1.5);
}
  

module frontcardcutout(width) {
  union () {
   cube([width, smallcardheight, 1000]);
   translate([width/2,0,0]) thumbcutout();
  }
}
  

module small_cards(thickness=27,sleeved=false) { 
  if (sleeved) {
    cube_filleted_columns(46+cardleeway,73+cardleeway,thickness,1.5);
  } else {
    cube_filleted_columns(smallcardwidth+cardleeway,smallcardheight+cardleeway,thickness,1.5);
  }
}
module small_cards_negated(thickness=27,sleeved=false) { 
  if (sleeved) {
    cube_filleted_columns(46+cardleeway,73+cardleeway,thickness+50,1.5);
  } else {
    cube_filleted_columns(smallcardwidth+cardleeway,smallcardheight+cardleeway,thickness+50,1.5);
  }
}

token_radius_slop = 0.3;


module number_letter_access(diameter=22) {
  // meant to be placed where center of cylinder is placed
  slot_width = diameter - 7;
  depth = 20;  // front to back

  translate([0,-slot_width/2,0]) cylinder(r=slot_width/2,h=100, center=true);
  translate([-slot_width/2, -slot_width/2-depth, -50]) cube([slot_width,depth+epsilon,100]);
  translate([0,-slot_width/2-depth,0]) cylinder(r=slot_width/2,h=100, center=true);
}

module number_tokens(negative=false) {
  h = negative ? 100 : 27;
  cylinder(r=11+token_radius_slop,h=h);
  if (negative) {
    number_letter_access();
  }
}
module letter_tokens(negative=false) {
  h = negative ? 100 : 23;
  cylinder(r=10.5+token_radius_slop,h=h);
  if (negative) {
    number_letter_access();
  }
}

wrapwidthevents = 10;
wrapwidthsmall = 6;

  cards1x = exteriorcardsep - coinsep;
  cards2x = cards1x + eventcardwidth + interiorcardsep;
  cards3x = cards2x + smallcardwidth + interiorcardsep;
  cards4x = cards3x + smallcardwidth + interiorcardsep;


  cards2midx = cards2x + smallcardwidth/2;
  cards3midx = cards3x + smallcardwidth/2;

  cardsfront = exteriorcardsep; // common y coordinate


module setup_caddy_contents (negative=false) {
  // city events
  // road events
  // battle goals
  // -1 cards
  // monster deck
  // number tokensa
  // number tokens

  if (!negative) {
    color("blue") union () {
      translate([0,0,tokenheight-coinheight])          cube([fullwidth, tokenlength, floor]);
      translate([0,tokenlength,0]) cube([fullwidth, fulllength - tokenlength, floor]);
    }
  }

  back = tokenlength + coinlength;
  baseheight = floor;


  module ev(x) {
    if (negative) {
      wrapwidth = wrapwidthevents;
      translate([x,cardsfront, baseheight]) event_cards_negated();
      translate([x+wrapwidth,-epsilon, baseheight])
        frontcardcutout(eventcardwidth-2*wrapwidth);
    } else {
      translate([x,cardsfront, baseheight]) event_cards();
    }
  }
  // city and road events
  ev(cards1x);
  ev(cards4x);

  smallstart = exteriorcardsep+2*(eventcardwidth+interiorcardsep+cardleeway);

  smallthickness = 6; // MEASURE!!!

  if (negative) {
    wrapwidth = wrapwidthsmall;
    translate([cards2x+wrapwidth,-epsilon,baseheight])
      frontcardcutout(smallcardwidth-2*wrapwidth);
    color("red") translate([cards2x, cardsfront,baseheight])
      small_cards_negated(); // battle goals
  } else {
    color("red") translate([cards2x, cardsfront,baseheight])
      small_cards(); // battle goals
  }

  numbery = cardsfront + smallcardheight + cardleeway + 3;

  tokenshift = 0;

  color("yellow") translate([cards2midx+tokenshift,numbery+10.5, baseheight])
    letter_tokens(negative);

  color("yellow") translate([cards3midx-tokenshift,numbery+11, baseheight])
    number_tokens(negative);

  stacksep = 10;

  if (!negative) {

    color("green") translate([cards3x, cardsfront,baseheight])
      small_cards(smallthickness);  // -1 cards

    color("green") translate([cards3x, cardsfront,baseheight+smallthickness+ stacksep])
      small_cards(smallthickness);  // monster attack deck

  } else {
    wrapwidth = wrapwidthsmall;
    difference () {
      union () {
        translate([cards3x+wrapwidth,-epsilon,baseheight])
          frontcardcutout(smallcardwidth-2*wrapwidth);
        color("red") translate([cards3x, cardsfront,baseheight])
          small_cards_negated(); // battle goals
      }
      cube([0,0,0]);
    }
  }


//  color("green") translate([fullwidth-cardssep-27,cardssep+11, 11+tokenheight + floor])
//    rotate([0,90,0])
//    number_tokens();
//
//    color("yellow") translate([fullwidth-2*(cardssep+27),cardssep+11, 11+tokenheight + floor])
//    rotate([0,90,0])
//    letter_tokens();


  color("purple") union () {
    rear_cards(0);
    rear_cards(1);
    rear_cards(2);
  }
}

module setup_caddy() {
  fradius = exteriorcardsep/2; // for fillets

    


  difference () {
    translate([-coinsep,0,0]) cube([fullwidth, tokenlength+coinlength+coinsep/3, caddyheight]);
    setup_caddy_contents(negative=true);
    translate ([wrapwidthevents+exteriorcardsep-fradius-coinsep,
                exteriorcardsep-fradius,
                floor])
    union () {
      anti_fillet(r=fradius,h=caddyheight+epsilon);

      translate([eventcardwidth+interiorcardsep+wrapwidthsmall-wrapwidthevents,0,0])
      union () {
        anti_fillet(r=fradius,h=caddyheight+epsilon);
        translate([smallcardwidth+interiorcardsep,0,0])
        union () {
          anti_fillet(r=fradius,h=caddyheight+epsilon);
          translate([smallcardwidth+interiorcardsep+wrapwidthevents-wrapwidthsmall,0,0])
            anti_fillet(r=fradius,h=caddyheight+epsilon);
        }
      }
    }
    translate([cards1x+eventcardwidth+fradius-wrapwidthevents,cardsfront-fradius,floor])
    union () {
      anti_fillet_nw(r=fradius,h=caddyheight+epsilon);
      translate([smallcardwidth+interiorcardsep+wrapwidthevents-wrapwidthsmall,0,0])
      union () {
        anti_fillet_nw(r=fradius,h=caddyheight+epsilon);
        translate([smallcardwidth+interiorcardsep,0,0])
        union () {
          anti_fillet_nw(r=fradius,h=caddyheight+epsilon);
          translate([eventcardwidth+interiorcardsep+wrapwidthsmall-wrapwidthevents,0,0])
            anti_fillet_nw(r=fradius,h=caddyheight+epsilon);
        }
      }
    }

  }
}

//caddy();

//translate([0,0,2]) setup_caddy_contents();

//translate([0,-10-fulllength, 2+coinheight]) setup_caddy();

setup_caddy();


