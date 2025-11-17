// Z88 Bezel replacement
//
//
// Inside the bezel there are no walls for the display (so we can 
// have a larger display), and no walls for the battery.
// Screw posts are there, though.
// Display cutout is larger.
//



use <../display_mount_two_side_displays/display_mount_two_side_displays.scad>

// Case lip so we can subtract it from the bezel,to make the mounting recess

case_x = 293;
case_y = 94+2*2.5;
case_z = 10;
case_th = 20;
case_r = 6;

lower_z = 5;
lower_r = 6;

ridge = 2.5;

upper_x = case_x - 2*ridge;;
upper_y = case_y - 2*ridge;
upper_z = 4;
upper_r = 6;

//-----------------------------------------------------------
// Display Cutout
//
// This is sized based on the display viewable areas, and the 
// active areas. the active area has to be visible, and as much
// area around the active area is shown, avoiding the module case.

// Bar type display 
display_bar_active_x = 170.88;
display_bar_active_y = 33.6;
display_bar_visual_x = 171.88;
display_bar_visual_y = 34.6;
display_bar_case_x = 181.47;

// Side displays
//display_side_active_x = 35.06;
//display_side_active_y = 46.75;
//display_side_visual_x = 36.66;
//display_side_visual_y = 48.35;

// Not rotated
display_side_active_y = 35.06;
display_side_active_x = 46.75;
display_side_visual_y = 36.66;
display_side_visual_x = 48.35;

// Case dimension plus tolerance and gap
display_side_case_x = 50.9+0.2 +0.5;
display_side_case_y = 45.8+0.2 +0.5;
display_side_case_z = 2.25+0.15+0.5;

// 6 inch bar display and side displays
dcut_bar_x = (display_bar_active_x+display_bar_visual_x)/2;
dcut_bar_y = (display_bar_active_y+display_bar_visual_y)/2;

dcut_side_x = (display_side_active_x+display_side_visual_x)/2;
dcut_side_y = (display_side_active_y+display_side_visual_y)/2;

dcut_x = dcut_bar_x+2*dcut_side_x + 14;
dcut_y = dcut_bar_y;

// Width of cutout is bar display case size plus two sides minus the width of the ase on the left and the right.
//dcut_x = display_bar_case_x + display_side_case_x * 2 - 4.15;

echo("Display cutout=", dcut_x, " x ", dcut_y);

// Original display cutout
//dcut_x = 249;
//dcut_y = 29;

// The display cutout has to match the display
// mounting posts.
dcut_y_shift = 24+29/2;

// Various cuboids, building up to a half cuboid with rounded
// edges in two axes to match original bezel shape.

module rounded_cuboid(x, y, z, rd)
{
  scale([1, 1, 0.5])
  translate([-x/2, -y/2, 0])
  minkowski()
    {  
    cube([x-rd-rd, y-rd-rd, z], center=true);
    translate([x/2, y/2, 0])
      cylinder(h=z, r=rd, $fn=100, center=true);
    }
}

// Cuboid with rounded corners on top edge

module top_rounded_cuboid(x, y, z, rd)
{
  scale([1, 1, 0.5])
  translate([-x/2, -y/2-rd/2, 0])

  difference()
    {
    minkowski()
      {  
      // radii added by minkowski
      // We add a radius so we can chop that off later
      cube([x-rd-rd, y-rd-rd+rd, z], center=true);
        
      translate([x/2, y/2, 0])
        cylinder(h=z, r=rd, $fn=100, center=true);
      }
      
    translate([x/2, 0, 0])
    cube([x+2, rd+0.05, z*2.1], center=true);
  }
}

module bottom_rounded_cuboid(x, y, z, rd)
{
    rotate([0, 0, 180])
  top_rounded_cuboid(x, y, z, rd);
}

if(0)
{
translate([0, -100, -50])
top_rounded_cuboid(40, 20, 10, 5);

translate([0, -100, -40])
rounded_cuboid(40, 20, 10, 5);

translate([0, -100, -30])
bottom_rounded_cuboid(40, 20, 10, 5);
}

module half_rounded_cuboid(x, y, z, rd)
{
  difference()
    {
    rounded_cuboid(x, y, 2*z, rd);
    translate([0, -y/2+y/4-.1, 0])
      cube([x+10, y/2, 2*z+2], center=true);
    }
}

// A rectangular 'gasket' shape, cut in half
module hrc_strip(x, y, z, th, rd)
{
  difference()
    {
    half_rounded_cuboid(x, y, z, rd);
    half_rounded_cuboid(x-2*th, y-2*th+0.1, z+0.1, rd);
    }
}

// A rectangular 'gasket' shape,
module rc_strip(x, y, z, th, rd)
{
  difference()
    {
    rounded_cuboid(x, y, z, rd);
    rounded_cuboid(x-2*th, y-2*th+0.1, z+0.1, rd);
    }
}

// The case is the z88 shape that the bezel fits into. This is
//subtracted from the bezel to give us the edge around the bezel edge

lip = 1;
module case()
{
  difference()
    {
    rc_strip(case_x, case_y, case_z, case_th, case_r);
    translate([0, 0, case_z/2-lip/2])
      rc_strip(case_x, case_y, lip, lip, case_r-1);
    }
}

module double_rounded_cuboid(x, y, z, rd)
{
  // Minkowski adds z dimensions of components
  scale([1, 1, 2*z/(2*rd+z)])
  translate([-x/2, -y/2, 0])
  minkowski()
    {  
    cube([x-rd-rd, y-rd-rd, z], center=true);
    translate([x/2, y/2, 0])
      sphere(r=rd, $fn=100);
    }
}

bev_r = 2;

module double_bevel_cuboid(x, y, z, rd)
{
  // Minkowski adds z dimensions of components
  scale([1, 1, 2*z/(2*rd+z)])
  translate([-x/2, -y/2, 0])
  minkowski()
    {  
    cube([x-rd-rd, y-rd-rd, z], center=true);
    translate([x/2, y/2, 0])
      cylinder(r1=rd, r2=rd-bev_r, h= z, $fn=100);
    }
}

module half_double_rounded_cuboid(x, y, z, rd)
{
  translate([0, 0, -z/4])
  difference()
    {
    double_rounded_cuboid(x, y, z, rd);
    translate([0, 0, -z/2])
      cube([x+10, y+10, z+0.5], center=true);
    }
}

module half_double_bevel_cuboid(x, y, z, rd)
{
  translate([0, 0, -z/4])
  difference()
    {
    double_bevel_cuboid(x, y, z, rd);
    translate([0, 0, -z/2])
      cube([x+10, y+10, z+0.5], center=true);
    }
}

sh_th = 2;

module hdrc_shell(x, y, z, rd)
{
  difference()
    {
    half_double_rounded_cuboid(x, y, z, rd);
    translate([0, 0, -sh_th])
    half_double_rounded_cuboid(x-4*sh_th, y-4*sh_th, z, rd);
    }
}

// Bevelled version
module hdbc_shell(x, y, z, rd)
{
  difference()
    {
    half_double_bevel_cuboid(x, y, z, rd);
    translate([0, 0, -sh_th])
    half_double_bevel_cuboid(x-4*sh_th, y-4*sh_th, z, rd);
    }
}

// Lower rounded cuboid
// We cut away a lot of this material, it is a frame, really

// The lower, front facing part of this is cut away, where the keyboard
// mounts under the bezel. 

lower_len_after_cutaway = 92;
cutaway_y = case_y - lower_len_after_cutaway;

frame_width = 10;
wall_x = 22;
wall_y = 1.5;

module lower()
{
  difference()
    {
      hdbc_shell(case_x, case_y, lower_z, lower_r);
      translate([0, 0, -case_z/2])
        case();
      
      // Cut away material (cost reduction)
      cube([case_x-frame_width*2, case_y-frame_width*2, lower_z*2], center=true);
        
      // Cut away for keyboard
      // Use cube some arbitrary size bigger where it doesn't matter
      translate([0, -case_y/2+cutaway_y/2-0.05, 0])
        cube([case_x*1.2, cutaway_y, case_z*1.2], center=true);
    }
}

module upper()
{
    half_double_rounded_cuboid(upper_x, upper_y, upper_z, upper_r);
  //hdrc_shell(upper_x, upper_y, upper_z, upper_r);
}

////////////////////////////////////////////////////////
//
// Cheat panel
//

cheat_th = 1.3;

module cheat(x, y)
{
  bottom_rounded_cuboid(x, y, cheat_th, 3);
}

////////////////////////////////////////////////////////
//
// Screw posts
//

screwp_h = 13;

module screw_post()
{
  translate([0, 0, 0])
  difference()
    {
    cylinder(d=7, h=screwp_h,      $fn=100, center=true);
    cylinder(d=3, h=screwp_h+ 0.1, $fn=100, center=true);
    }

  // Posts should protrude 8mm below bezel, this is a gauge for that
  //translate([0,0,-4])
  //cylinder(d=8, h=6, $fn=100, center=true);

}

////////////////////////////////////////////////////////
//
// Displays
//
// Subtracted from the bezel to give recesses 
// where displays will be mounted
//
// Active area raised up for alignment debug
//

// Overall size
display_mipi_x = 181.47 + 0.5+0.2;
display_mipi_y = 38.2   + 0.5+0.2;
display_mipi_z = 3.45   + 0.5+0.15;

// Active area size
display_mipi_aa_x   = 170.88;
display_mipi_aa_xo  = -7.2+display_mipi_x/2-display_mipi_aa_x/2;   // Measured, diagram in datasheet doesn't have this
display_mipi_aa_y   = 33.6;
display_mipi_aa_yo  = 0;

// Overall size
display_side_x = 50.9 + 0.5  + 0.2;
display_side_y = 45.8 + 0.5  + 0.2;
display_side_z = 2.25 + 0.15 + 0.15;

// Actiave area size
display_side_aa_x   = 46.75;
display_side_aa_xo  = 0;
display_side_aa_y   = 35.06;
display_side_aa_yo  = 8.29;//+display_side_x/2-display_side_aa_x/2;

// Top border size
display_side_yb = display_side_y-display_side_aa_y-display_side_aa_yo;

// Distance to move display to align centres of Y active areas
display_side_aa_yx = display_side_y/2 - display_side_yb - display_side_aa_y/2;

debug_z = 20;
align_debug = 0;
align_debug_o = -5;    

echo( "display_side_yb=",display_side_yb, "   display_side_aa_yx=", display_side_aa_yx);

module displays()
{

  translate([0, 0,align_debug_o])
  cube([display_mipi_x, display_mipi_y, display_mipi_z], center=true);

if(1)
{
  translate([display_mipi_x/2+display_side_x/2, -display_side_aa_yx, align_debug_o+display_mipi_z/2-display_side_z/2])
    cube([display_side_x, display_side_y, display_side_case_z], center=true);

  translate([-display_mipi_x/2-display_side_x/2, -display_side_aa_yx, align_debug_o+display_mipi_z/2-display_side_z/2])
    cube([display_side_x, display_side_y, display_side_z], center=true);
}
    
if(align_debug)
  {
  translate([display_mipi_aa_xo, -display_mipi_aa_yo, align_debug_o+debug_z/2+display_mipi_z/2])
  cube([display_mipi_aa_x, display_mipi_aa_y, debug_z], center=true);

if(1)
{
  translate([display_mipi_x/2+display_side_case_x/2, -display_side_aa_yx, align_debug_o+debug_z/2+display_mipi_z/2])
    cube([display_side_aa_x, display_side_aa_y, debug_z], center=true);

  translate([-display_mipi_x/2-display_side_case_x/2, -display_side_aa_yx, align_debug_o+debug_z/2+display_mipi_z/2])
    cube([display_side_case_x, display_side_aa_y, debug_z], center=true);
}
  }

}

////////////////////////////////////////////////////////
//
// Display cutout with front bevel

module dcut_b(x, y, z)
{
  top_rounded_cuboid(x, y, z, 3);
    
  translate([0, -y/2-case_z/2+10/2, case_z/2+10/2])
  rotate([60, 0, 0])
  cube([x, 10, 10], center=true);
 
}

////////////////////////////////////////////////////////


// The bezel fundamental presence

module bezel_pre()
{
  translate([0, 0, lower_z/2+upper_z/2-0.6])
    upper();
  lower();
    
  translate([case_x/2-9, case_y/2-9, 0])
    screw_post();

  translate([-case_x/2+9, case_y/2-9, 0])
    screw_post();

  translate([-case_x/2+130, case_y/2-9, 0])
    screw_post();


  translate([-case_x/2+64, case_y/2-70, 0])
    screw_post();

  translate([case_x/2-64, case_y/2-70, 0])
    screw_post();

}

// Remove this from bezel
module bezel_rem()
{
  // Display cutout, bar display and side displays in one cutout.
  translate([0, case_y/2-37.5, 0])
    dcut_b(dcut_x, dcut_y, case_z * 4);

if(0)
{  
  // Side displays
  translate([dcut_x/2+dcut_side_x/2+3, case_y/2-24-29/2, 0])
    cube([dcut_side_x, dcut_side_y, case_z * 4], center=true);

  translate([-dcut_x/2-dcut_side_x/2-3, case_y/2-24-29/2, 0])
    cube([dcut_side_x, dcut_side_y, case_z * 4], center=true);
}
if(1)
{
  translate([0, -dcut_y/2, sh_th+case_z/2-cheat_th/2+0.05])
    cheat(dcut_x, 18);
} 
}

module bezel()
{
  difference()
    {
        bezel_pre();
        bezel_rem();
    }
}

module all()
{
bezel();

//translate([-136, -6.3-10.5, -0.7])
//display_mount();
}

difference()
{
//bezel();
all();
//translate([-136, -6.3-10.5, -1])
//%display_mount();
  translate([1.5, 12, 7.6])
  %displays();
    
if(0)
{
translate([-136, -6.3-10.5, -1])
display_mount();
}
if(0)
{
translate([0, 44.25, -5])
cube([10.5, 10.5, 50], center=true);
}
if(0)
{
translate([-150, 0, -40])
cube([300, 200, 80]);
}
}

// A cuboid used for measuring size of model, as a check
// Part of case lower is removed to give a flush edge
if ( 0 )
{
translate([0, 0, -20])
  cube([293, 94+2*2.5, 5], center=true);
}