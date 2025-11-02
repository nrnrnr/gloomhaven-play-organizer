edition = 1;

include <play-caddy.scad>

translate([70,0,0]) card_separator();
translate([140,0,0]) card_separator();

card_separator(width=sleevedsmallwidth, height=sleevedsmallheight, front=sleevedcardsfront, wrap=wrapwidthsmall, toptext="Monster\nDeck", bottomtext="-1\nPenalty");
