////////////////////////////////////////////////////////////////
//
// Organizer/Storage for Gloomhaven setup and play
//
//
//

//  This organizer is split into two trays: 
//
//    * The upper tray holds supplies that are needed during scenario setup:
//
//        - City events and road events
//        - Battle goals
//        - Monster attack-modifier deck
//        - Player -1 penalty cards (if needed)
//        - Number tokens (if needed)
//        - Letter tokens (if needed)
//
//    * The lower tray holds supplies that are not put into play
//      immediately, but that may need to be accessible during play:
//
//        - Bless and curse cards
//        - Coins
//        - Damage tokens
//        - Condition tokens
//



$fa = 2;    // minimum angle (fine resolution)
$fs = 0.4;  // minimum size (fine resolution)

use <drawer.scad>  // reusable primitives

epsilon = 0.001;   // help avoid issues with floating-point rounding error

drawer_inserts = false;   // if true, model thin sheets for bottoms of drawers
add_text       = true;    // include text labels (set to false cuts rendering time)

///////////////////
///
///  Dimensions of Gloomhaven components

smallcardheight = 68;  // AMD cards and battle goals
smallcardwidth = 44;

eventcardheight = 89.5; // confirmed
eventcardwidth = 64;    // confirmed


///////////////////
///
///  Utility functions

module pirata(s,size=8) {
  // place 2D text with default parameters
  if (add_text) {
    text(s, font = "Pirata One", halign = "center", size=size, valign="baseline");
  }
}




////////////////
//
// The outer left edge of the lower_tray is at X = -coinsep,
// and the bottom edge is at Z = -floor.  These decisions
// are regrettable.
//

////////////////////////////////////////////////////////////////
///////////////////////   Lower Tray ///////////////////////////
////////////////////////////////////////////////////////////////


/////// drawers to hold condition tokens

tokenheight = 25 - 9;  // depth/height of a token drawer in Z direction
tokenwidth = 29.8;     // width of drawer for tokens in X direction
tokensep = 1.2;        // thickness of separator between drawers
ntokens = 8;           // number of drawers
tokenlength = 40;      // length of a token drawer in Y direction

fullwidth =            // full size of lower tray (and the whole unit), X direction
  ntokens * (tokensep + tokenwidth) + tokensep;

floor=1;  // thickness of the floor under the token/coin drawers

module token_drawer(index) {
  // place a token drawer at position `index` where `0 <= index < ntokens`
  translate([index * (tokenwidth + tokensep),0,0])
    drawer(w=tokenwidth,h=tokenheight,l=tokenlength,sep=tokensep,
           theta=45,floor=floor,insert=drawer_inserts);
}

//////// drawers to hold coins and damage tokens

coinsep = tokensep;     // width of a separator between coin drawers
coinwidth =             // width of a single coin drawer in X direction
  (fullwidth - 4 * coinsep) / 3.0;
coinlength = 63;        // length of a coin drawer in Y direction
coinheight = 20;        // height of a coin drawer in Z direction

module coin_drawer(index) {
  // place a token drawer at position `index` where `0 <= index < 3`
  translate([index * (coinwidth + coinsep),tokenlength,0])
    drawer(w=coinwidth,h=coinheight,l=coinlength,sep=coinsep,theta=45,floor_y_shift=2*coinlength+30,floor=floor,insert=drawer_inserts);
}


// slots to hold bless and curse cards

cursecardthickness = 5;   // measures a deck of sleeved curse or bless cards
cursecardslotdepth = 20;  
cursecardheight =         // Z height of front rim of curse card slot
  max(cursecardslotdepth + floor, coinheight);
cursecardslotwidth = 77;           // X width of a curse-card slot

cursecardrearextra = 15;  // amount by which back Z is higher than front

fulllength = // Y direction length of the entire structure
  tokenlength + coinlength + cursecardthickness + 2 * coinsep;

module cursecardboxtranslate(index) {
   // place child at lower left front corner of a cube containing a curse-card slot?
   // or is it above the floor?
   translate([index * (coinwidth+coinsep) - coinsep, tokenlength+coinlength,0])
   children();
}

module cursecardboundingbox(index) {
   // place a cube of the right size and position to enclose a curse-card slot, 
   // plus it matches up with the other dimensions we are looking for.
   // (essentially the cube we will punch the slot out of)
   cursecardboxtranslate(index)
     cube([coinwidth+2*coinsep+epsilon, cursecardthickness+ 2 * coinsep+epsilon, cursecardheight]);
}

module cursecardslottranslate(index,z=0,width=cursecardslotwidth) {
   // place child at left front corner of an empty slot for curse cards, with given Z
   cursecardboxtranslate(index)
     translate([coinsep+index*(coinwidth-width)/2, coinsep, z])
        children();
}

module cursecardslot(index) {
  // place appropriately formed cube with a curse-card slot cut into it
  width = cursecardslotwidth;
  sep =	(fullwidth - 3 * width) / 4;
  depth = cursecardslotdepth;
  height = cursecardheight;
  chamfer = (cursecardthickness + coinsep) / sqrt(2);

  difference () {
    cursecardboundingbox(index);
    cursecardslottranslate(index)
      union () {
        cube([width+epsilon,cursecardthickness+epsilon,smallcardwidth+epsilon]); // slot
        translate([0,cursecardthickness/2,depth-chamfer/sqrt(2)])  // chamfers
          rotate([45,0,0]) cube([width+epsilon,chamfer,chamfer]);
      }
   }
}

// blocks between curse/bless cards (hold alignment holes/pegs)

blockwidth = coinsep + (coinwidth - cursecardslotwidth) * 1.5;

alignmentholediameter = 3;
alignmentpegclearance = 0.3; // difference in diameter betweeen the hole
                             // and a peg designed to fit into it

/* peg geometry:  /\    <-- height is `spikeheight`
                  ||    <-- height is `pegheight`, diameter is hole size less clearance
*/

pegheight   = 5;      // height of cylindrical part of the peg
spikeheight = 3;      // height of cone ending in peg tip
spiketipdiameter = 0.5;

module alignmentholetranslate(index,depth=-epsilon) {
  // place child at the center of the indexed alignment hole (1 or 2),
  // at given depth below the rim of the curse-card slots
  cursecardboxtranslate(index)
    translate([(3 - index) * (cursecardslotwidth-coinwidth)/2 + blockwidth/2,
               cursecardthickness/2+coinsep,
               cursecardheight-depth])
      children();
}

module alignmenthole(index,depth=cursecardheight-5,width=alignmentholediameter) {
  // place the hole in indexed the alignment block
  alignmentholetranslate(index,depth)
    cylinder(h=depth+epsilon,r=width/2);
}

module alignmentpeg(index,depth=pegheight,diameter=alignmentholediameter-alignmentpegclearance,base) {
  // place the indexed alignment peg, pointing up.  `base` is the Z height of the block
  module alignmentblock(height) {
    cube([blockwidth, cursecardthickness + 2 * coinsep+epsilon, height + epsilon]);
  }

  module peg() {
    translate([0,0,base])
      cylinder(h=depth+epsilon,d=diameter);
    translate([0,0,depth+base])
      cylinder(d1=diameter,d2=spiketipdiameter,h=spikeheight+epsilon);
    if (base > 0) {
      translate([-blockwidth/2,-(cursecardthickness/2+coinsep),0])
        alignmentblock(base);
    }
  }

  alignmentholetranslate(index) peg();
}

default_r = 10; // amount to drop text of card labels?
default_label_thickness = 0.4;  // for incised/recessed labels

module curse_card_label(index, s) {
  // place a label on the front of a curse-card slot (usually subtracted)
  thickness = default_label_thickness;
  translate([coinsep + index * (coinsep + coinwidth) + coinwidth/2,
             tokenlength+coinlength+thickness-epsilon,
             coinheight-default_r+3])
  if (add_text) {
    rotate([90,0,0])
    linear_extrude(thickness)
    pirata(s, size=6);
  } else {
    color ("white") translate([-20,0,0]) cube([40,10,thickness]);
  }
}

module token_label(index, s) {
  // place a label on the front of a token drawer
  thickness = default_label_thickness;
  translate([index * (tokensep + tokenwidth) + tokenwidth/2,
             thickness-epsilon,
             tokenheight/2+1])
  rotate([90,0,0])
  linear_extrude(thickness) 
  text(s, font = "gloomhaven conditions", halign = "center", size=9, valign="center");
    // N.B. different font!
    // GH conditions: D disarm
    //                I immobilize
    //                M muddle
    //                P poison
    //                S strengthen
    //                U stun
    //                V invisible
    //                W wound
    //                Z regenerate
}

module negative_label(s, size=10) {
  // place 3D label at origin at default thickness plus a lot
  // (meant to be subtracted from a solid)
  if (add_text) {
    thickness = default_label_thickness+epsilon;
    linear_extrude(thickness+1)
      pirata(s, size=size);
  }
}


module lower_tray () {
  // place the lower tray (at [-coinsep,0,-floor]?)
  difference () {
    union () {
      color("red", alpha=0.6)
      translate([-coinsep,fulllength-coinsep, cursecardheight-epsilon])
      cube([fullwidth,coinsep,cursecardrearextra]);
      alignmentpeg(1,base=cursecardrearextra);
      alignmentpeg(2,base=cursecardrearextra);
      difference () {
        union () {
          for (i=[0:1:7]) {
            token_drawer(i);
          }
          for (i=[0:1:2]) {
            coin_drawer(i);
          }
        }
        for (i=[0:1:2]) {
          cursecardboundingbox(i);
        }
      }
      for (i=[0:1:2]) {
        cursecardslot(i);
      }
    }
    // alignmenthole(1); // prototype had holes; final version has pegs
    // alignmenthole(2);
    curse_card_label(0, "Player Curse");
    curse_card_label(1, "Bless");
    curse_card_label(2, "Monster Curse");
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



////////////////////////////////////////////////////////////////
///////////////////////   Upper Tray ///////////////////////////
////////////////////////////////////////////////////////////////


cardleeway = 1; // extra width and height added to card spaces

exteriorcardsep = 5;
interiorcardsep = (fullwidth - 
                   2 * exteriorcardsep - 
                   2 * (eventcardwidth + smallcardwidth + 2 * cardleeway)) / 3.0;


separator_thickness = 2; // separates active/inactive events;
                         // also -1 from monster AMD

numberthickness = 27; 
letterthickness = 23; // confirmed
numberlift = 5; // room for finger underneath, could be 4
cityeventthickness = 27;
roadeventthickness = 22;
battlegoalthickness = 26.5;
amdthickness = 12;  // monster attack-modifier deck
minusonethickness = 10; // could squeeze down to 9
ceiling = 5; // space between highest stack and top
caddytopclearance = ceiling; // space between top of stack and rim; could be 4

sleevedsmallwidth = 46;
sleevedsmallheight = 73;

smallthickness = amdthickness + minusonethickness; 



thicknesses = [ numberthickness + numberlift
              , letterthickness + numberlift 
              , cityeventthickness + separator_thickness
              , roadeventthickness + separator_thickness
              , battlegoalthickness
              , smallthickness + separator_thickness
              ];



caddyheight = floor + max(thicknesses) + caddytopclearance;

echo(caddyheight = caddyheight, totalheight = caddyheight + coinheight, caddy_above_token = caddyheight + coinheight - tokenheight);

module thumbcutout () { // origin at center?
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
    cube([sleevedsmallwidth+cardleeway,sleevedsmallheight+cardleeway,thickness]);
  } else {
    cube_filleted_columns(smallcardwidth+cardleeway,smallcardheight+cardleeway,thickness,1.5);
  }
}
module small_cards_negated(thickness=27,sleeved=false) { 
  if (sleeved) {
    cube([sleevedsmallwidth+cardleeway,sleevedsmallheight+cardleeway,thickness+50]);
  } else {
    cube_filleted_columns(smallcardwidth+cardleeway,smallcardheight+cardleeway,thickness+50,1.5);
  }
}

token_radius_slop = 0.3;

numberdiameter = 21.7;
letterdiameter = 20.2;
numberleeway = 1.3;

numberradius = (numberdiameter + numberleeway) / 2;
letterradius = (letterdiameter + numberleeway) / 2;

module number_letter_access(diameter=2*numberradius) {
  // meant to be placed where center of cylinder is placed
  slot_width = diameter - 7;
  depth = 20;  // front to back

  translate([0,-slot_width/2,0]) cylinder(r=slot_width/2,h=100, center=true);
  translate([-slot_width/2, -slot_width/2-depth, -50]) cube([slot_width,depth+epsilon,100]);
  translate([0,-slot_width/2-depth,0]) cylinder(r=slot_width/2,h=100, center=true);
}

module number_tokens(negative=false) {
  h = negative ? 100 : numberthickness + caddytopclearance;
  cylinder(r=numberradius,h=h);
  if (negative) {
    number_letter_access();
    if (add_text) {
      translate([0,2,-default_label_thickness])
        negative_label("Numbers", size=4);
    }
  }
}
module letter_tokens(negative=false) {
  h = negative ? 100 : letterthickness + caddytopclearance;
  cylinder(r=10.5+token_radius_slop,h=h);
  if (negative) {
    number_letter_access();
    if (add_text) {
      translate([0,2,-default_label_thickness])
        negative_label("Letters", size=4);
    }
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
  sleevedcardsfront = cardsfront - 2;

  numbery = cardsfront + smallcardheight + cardleeway + 3;

module curse_or_bless_cards(index) {
  // place a deck of curse (or bless) cards with the given index
  width = cursecardslotwidth;
  sep =	(fullwidth - 3 * width) / 4;
  depth = cursecardslotdepth;
  height = cursecardheight;
  chamfer = (cursecardthickness + coinsep) / sqrt(2);

  cursecardboxtranslate(index)
    translate([coinsep+index*(coinwidth-width)/2, coinsep, height-depth])
      cube([width+epsilon,cursecardthickness+epsilon,smallcardwidth+epsilon]);
}





module upper_tray_contents (negative=false) {
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

  if (negative) {
    h = baseheight - default_label_thickness;
    translate([cards1x+eventcardwidth/2, cardsfront+0.6*eventcardheight, h])
      negative_label("City Events");
    translate([cards2midx+0.5, cardsfront+0.5*smallcardheight, h])
      negative_label("Battle Goals",size=8);
    translate([cards3midx+1.8, cardsfront+0.6*smallcardheight-2, h])
      negative_label("Monster AMD",size=7);
    translate([cards3midx, cardsfront+default_label_thickness*smallcardheight-0.5, h])
      negative_label("-1 Cards",size=7);
    translate([cards4x+eventcardwidth/2, cardsfront+0.6*eventcardheight, h])
      negative_label("Road Events");
  }

  smallstart = exteriorcardsep+2*(eventcardwidth+interiorcardsep+cardleeway);


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


  tokenshift = 0;

  numberz = caddyheight - (caddytopclearance + numberthickness);
  letterz = caddyheight - (caddytopclearance + letterthickness);

  color("yellow") translate([cards2midx-tokenshift,numbery+11, numberz])
    number_tokens(negative);

  color("yellow") translate([cards3midx+tokenshift,numbery+11.5, letterz])
    letter_tokens(negative);

  stacksep = 10;

  if (!negative) {

    color("green") translate([cards3x, sleevedcardsfront,baseheight])
      small_cards(smallthickness, sleeved=true);  // -1 cards

    color("green") translate([cards3x, sleevedcardsfront,baseheight+smallthickness+ stacksep])
      small_cards(smallthickness, sleeved=true);  // monster attack deck

  } else {
    wrapwidth = wrapwidthsmall;
    difference () {
      union () {
        translate([cards3x+wrapwidth,-epsilon,baseheight])
          frontcardcutout(smallcardwidth-2*wrapwidth);
        color("red") translate([cards3x, sleevedcardsfront,baseheight])
          small_cards_negated(sleeved = true);  // -1 plus monster AMD
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
    curse_or_bless_cards(0);
    curse_or_bless_cards(1);
    curse_or_bless_cards(2);
  }
}

setup_registration_leftx = cards2x-interiorcardsep/2;
setup_registration_rightx = cards4x+wrapwidthevents/2;
setup_registration_y = exteriorcardsep/2;


module lidtower(index) { // for upper caddy
  // TODO: add flares at top and bottom
  alignmentholetranslate(index,depth=cursecardheight-cursecardrearextra)
    translate([-blockwidth/2, -(cursecardthickness/2+coinsep), 0]) 
    difference () {
      cube([blockwidth, cursecardthickness + 2 * coinsep+epsilon, caddyheight + epsilon - cursecardrearextra]);
      translate([blockwidth/2,cursecardthickness/2 + coinsep,-epsilon])
        cylinder(h=caddyheight+3*epsilon-cursecardrearextra,r=alignmentholediameter/2);
  }
}
    


module upper_tray() {
  fradius = exteriorcardsep/2; // for fillets

    
  // registration towers in the back 

  lidtower(1); // TODO: lift these
  lidtower(2);

  // rear wings on the sides

  translate([-coinsep,tokenlength+coinlength,0])
    cube([coinsep, cursecardthickness+2*coinsep, caddyheight]);
  translate([fullwidth-2*coinsep,tokenlength+coinlength,0])
    cube([coinsep, cursecardthickness+2*coinsep, caddyheight]);


  // main item

  difference () {
    translate([-coinsep,0,0]) cube([fullwidth, tokenlength+coinlength+coinsep/3+epsilon, caddyheight]);
    upper_tray_contents(negative=true);
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

separator_leeway = 4; // 2 times space around separator
new_separator_thickness = 5;
separator_radius = 9.5;
module card_separator(width=eventcardwidth,
                      height=eventcardheight,
                      front=cardsfront,
                      wrap=wrapwidthevents,
                      showtext=true) {
  fillet = 5;
  smallfillet = 3;
  difference () {
    union () {
      cube_filleted_columns(width-separator_leeway,height-separator_leeway,new_separator_thickness,fillet);
      translate([wrap,-front-separator_leeway,0])
      cube_filleted_columns(width-separator_leeway-2*wrap,front+height-separator_leeway,new_separator_thickness,smallfillet);
    }
    radius = separator_radius;
    translate([(width-separator_leeway)/2-radius,-front-separator_leeway,-epsilon])
      union () {
        anti_fillet_se(r=smallfillet,h=caddyheight);
        translate([2*radius,0,0]) anti_fillet_sw(r=smallfillet,h=caddyheight);
    }

    translate([(width-separator_leeway)/2,2,-epsilon])
      union () {
        cylinder(r=radius,h=caddyheight);
        translate([-radius,-2*radius,0])
          cube([2*radius,2*radius,caddyheight]);

        if (showtext) {
          translate([0,height/2,new_separator_thickness-default_label_thickness])
          linear_extrude(default_label_thickness+2*epsilon)
            pirata("Active");
          translate([0,height/2,-epsilon])
          linear_extrude(default_label_thickness+epsilon)
            pirata("Inactive"); // TODO this is mirror writing!
        }
      }

  }

}


wingthickness = coinsep;
wingdelta = 0.15; // 0.6 is quite loose
                  // 0.3 is just a touch loose
                  // 0.15 has a tiny amount of play and is just about perfect

module token_cover_wing() { // top surface is in XY plane
  below(0)
  translate([0,0,4])
  rotate([0,90,0])
  cube_filleted_columns(8,tokenlength-8,wingthickness,3);
}

tonguewidth = tokenwidth - 2 * wingthickness - 2*wingdelta;

module token_cover_tongue(theta=40,length=5) { // top surface is in XY plane
               // ----.  theta is angle at top, length is length of top
               // |  /
               // | /
               // |/
  translate([0,length,0])
  rotate([-90,0,0])
  rotate([0,90,0])
  linear_extrude(height=tonguewidth)
  polygon([[0,0],[length,0],[0,length * tan(theta)]]);
}

module token_cover_wings (index,y=6,z=tokenheight) {
  delta = wingdelta;
  leftx = coinsep + index*(tokenwidth+coinsep);
  translate([leftx+delta,y,z+epsilon]) token_cover_wing();
  translate([leftx-delta+tokenwidth-wingthickness,y,z+epsilon]) token_cover_wing();

}

module token_cover () {
  thickness = coinheight - tokenheight;
  cube([fullwidth,tokenlength,thickness]);
  for (i=[0:1:7]) {
    token_cover_wings(i,z=0);
    translate([coinsep + i*(tokenwidth+coinsep) + (tokenwidth-tonguewidth)/2,0,epsilon])
      token_cover_tongue(theta=40);
  }
}

module token_cover_test() {
  rotate([180,0,0])
  left(2*coinsep+tokenwidth) token_cover();
}

overallcoverthickness = 2;

module overall_cover () {

  difference () {
    union () {
        translate([-coinsep,0,0]) cube([fullwidth,fulllength,overallcoverthickness]);
        // ceilings measured with caliper depth, so (to a degree) compressed
        cityeventceiling = 6;
        roadeventceiling = 10.4;
        numberceiling = 6.4;
        letterceiling = 7.0;
        battleceiling = 11.1;
        amdceiling = 8.3;

        rearcardceiling = 12.15;
        
        gap = 2; // between ceiling and filler

        leeway = 2; // difference in width/diameter


            translate([cards1x+cardleeway/2+leeway/2, cardsfront + leeway/2, gap-cityeventceiling])
              cube_filleted_columns(eventcardwidth-leeway,eventcardheight-leeway,
                                    cityeventceiling-gap+epsilon, separator_radius);

            translate([cards2x+cardleeway/2+leeway/2, cardsfront + leeway/2, gap-battleceiling])
              cube_filleted_columns(smallcardwidth-leeway,smallcardheight-leeway,
                                    battleceiling-gap+epsilon, separator_radius);

            translate([cards3x+cardleeway/2+leeway/2, sleevedcardsfront + leeway/2, gap-amdceiling])
              cube_filleted_columns(sleevedsmallwidth-leeway,sleevedsmallheight-leeway,
                                    amdceiling-gap+epsilon, separator_radius/2);

            translate([cards4x+cardleeway/2+leeway/2, cardsfront + leeway/2, gap-roadeventceiling])
              cube_filleted_columns(eventcardwidth-leeway,eventcardheight-leeway,
                                    roadeventceiling-gap+epsilon, separator_radius);

        reargap = 3;


        // numbers
        translate([cards2midx, numbery+11,gap-numberceiling])
          cylinder(r=numberradius-leeway/2,h=numberceiling-gap+epsilon);

        // letters
        translate([cards3midx, numbery+11.5,gap-letterceiling])
          cylinder(r=letterradius-leeway/2,h=letterceiling-gap+epsilon);


        color("blue")
        translate([0,0,-cursecardheight])
          union () {
            alignmenthole(1,width=alignmentholediameter-alignmentpegclearance,depth=pegheight+epsilon);
            alignmenthole(2,width=alignmentholediameter-alignmentpegclearance,depth=pegheight+epsilon);
            alignmentholetranslate(1,depth=pegheight+spikeheight)
              cylinder(d2=alignmentholediameter-alignmentpegclearance,d1=0.5,h=spikeheight+epsilon);
            alignmentholetranslate(2,depth=pegheight+spikeheight)
              cylinder(d2=alignmentholediameter-alignmentpegclearance,d1=0.5,h=spikeheight+epsilon);
          }



        translate([reargap,0,-rearcardceiling+1])
          union () {
            cursecardslottranslate(0)
              cube([cursecardslotwidth-2*reargap, cursecardthickness+coinsep, rearcardceiling-1+epsilon]);
            cursecardslottranslate(1)
              cube([cursecardslotwidth-2*reargap, cursecardthickness+coinsep, rearcardceiling-1+epsilon]);
            cursecardslottranslate(2)
              cube([cursecardslotwidth-2*reargap, cursecardthickness+coinsep, rearcardceiling-1+epsilon]);
        }
    }
    textthickness = 0.6;
    translate([fullwidth/2-coinsep,0.6*fulllength,overallcoverthickness-textthickness])
      linear_extrude(textthickness+epsilon)
      pirata("Gloomhaven",size=21);
    translate([fullwidth/2-coinsep,0.3*fulllength,overallcoverthickness-textthickness])
      linear_extrude(textthickness+epsilon)
      pirata("Setup & Play Supplies",size=11);

  }
}


module end_band() {
  bandlength = fulllength+1.5;
  indent = 3+1.5;
  thickness = 2;
  height=62.8;
  width = 13;
  curved_band(straight=height,curved=bandlength,height=width,thickness=thickness,indent=indent);
  //   // side band all the way across has to flex, so not a great plan
  //translate([(height-width/2)/2,-epsilon,0])
  //  cube([width/2,bandlength+2*epsilon,floor]);
  stop_thickness = 1;
  translate([height/2,0,stop_thickness/2])
    rotate([0,0,90])
    half_cylinder(r=height/5,h=stop_thickness);
  translate([height/2,bandlength,stop_thickness/2])
    rotate([0,0,-90])
    half_cylinder(r=height/5,h=stop_thickness);
}  
  // city events



module exploded_diagram(deltax=0,deltay=0,deltaz=0,contents=true,transparent=false) {
  colors = ["#b8b8ff", "#c8c8ff", "#dadaff", "#e8e8ff","#bbbbff"];
  dx = deltax;
  dy = deltay;
  dz = deltaz;

  alpha1 = transparent ? 0.8 : 1.0;
  alpha2 = transparent ? 0.7 : 1.0;
  alpha3 = transparent ? 0.5 : 1.0;

  translate([coinsep,0,0]) color(colors[0], alpha=alpha1)
    lower_tray();
  translate([dx,-2*dy,dz+tokenheight+floor]) color(colors[1],alpha=alpha3) token_cover();
  translate([2*dx+coinsep,-dy,2*dz+coinheight+floor]) color(colors[2], alpha=alpha2)
    upper_tray();
  if (contents) {
    translate([2*dx+coinsep,-dy,2*dz+coinheight+floor]) upper_tray_contents();
  }
  translate([3*dx+coinsep,0,4*dz+coinheight+floor+caddyheight]) color(colors[3], alpha=alpha3)
overall_cover();

  translate([-min(15*dz,20),0,0])
  translate([-1,-3/4,coinheight+floor+caddyheight+2.5]) rotate([0,90,0]) color(colors[4]) end_band();

  translate([min(15*dz,20),0,0])
  translate([fullwidth+1,-3/4,-3/4]) rotate([0,-90,0]) color(colors[4]) end_band();
}


//////////////////////////////////////////////////////////////////////////////////
//////
/////   tests

module overall_cover_test () {
  translate([0,0,overallcoverthickness])
  rotate([180,0,0])
  right(cards2x-interiorcardsep/2)
    left(cards2midx-5)
    behind(cardsfront+eventcardheight)
    overall_cover();
}


//lower_tray();
//translate([-coinsep,-4,tokenheight+4]) color("LightCyan") token_cover();

// token_cover_test();

// translate([0,0,coinheight-tokenheight]) rotate([180,0,0]) token_cover();

//  upper_tray();
//  //translate([-coinsep,0,tokenheight-coinheight-5]) color("LightCyan") 
//  translate([-coinsep,tokenheight-coinheight,0]) rotate([-90,0,0]) color("Pink")
//  token_cover();





//caddy();

//color("blue") translate([0,0,20]) lidtower(1);

//
//translate([0,0,2+coinheight]) upper_tray_contents();
//
//translate([0,-10-fulllength, 2+coinheight]) {
//  union () { 
//    upper_tray();
//  }
//}

//upper_tray();
    




module setup_test_pieces () {
  left(cards3x-interiorcardsep/2) 
  union () {

    test_thickness = 5;

    upper_tray();

    color("blue") translate([0,120,test_thickness-caddyheight]) above(caddyheight-test_thickness) upper_tray();

    color("red") translate([0,-120,0]) below(floor+test_thickness) upper_tray();
  }
}

module sleeve_test() {
  right(cards3x-interiorcardsep/2)
  left(cards4x-interiorcardsep/2+3) 
  union () {

    test_thickness = 5;

//    upper_tray();

    color("blue") translate([0,120,test_thickness-caddyheight]) above(caddyheight-test_thickness) upper_tray();

  }
}


//upper_tray();
//translate([0,fulllength,fulllength+caddyheight])
//color("Pink") rotate([-90,0,0]) overall_cover();
//
//
//translate([0,-30,0]) hollow_cylinder(r1=15,r2=17,h=30);

//translate([-13,0,0])
//rotate([0,90,0])
//translate([-63,0,0])
//overall_cover_test();


//color("yellow")
//translate([cards1x+separator_leeway/2, cardsfront+separator_leeway/2,floor+cityeventthickness/2])
//card_separator();
//translate([70,0,0]) card_separator();

//  //color("blue")
//  translate([30,-smallcardwidth,0])
//  rotate([0,0,-90])
//  card_separator(width=sleevedsmallwidth, height=sleevedsmallheight, front=sleevedcardsfront, wrap=wrapwidthsmall, showtext=false);

//end_band();

//sleeve_test();

//setup_test_pieces();



//color("white") token_cover_wing();



//color("red") anti_fillet_sw(r=20,h=60);

//translate([0,-30,0]) color("LightCyan") 
//token_cover_tongue(theta=25);

exploded_diagram(deltaz=0,deltay=0,contents=false);

//exploded_diagram(deltaz=5,deltay=5,contents=false);
