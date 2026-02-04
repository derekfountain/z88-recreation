# Small bezel piece to cover the top part of the 1.3" side screen
 
$fn=64;

width        = 34.5;
depth        = 5.0;
thickness    = 1.0;

peg_height   = 2.5;
peg_diameter = 2.6;
peg_radius   = peg_diameter/2;

peg_top_offset  = 0.9;
peg_side_offset = 1.2;

cube([width, depth, thickness]);

translate([peg_side_offset+peg_radius, depth-peg_top_offset-peg_radius, thickness])
  cylinder( h=peg_height, d=peg_diameter );
translate([width-peg_side_offset-peg_radius, depth-peg_top_offset-peg_radius, thickness])
  cylinder( h=peg_height, d=peg_diameter );  