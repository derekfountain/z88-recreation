// Original LCD module is a large rectangular block
//
original_width  = 270.0;    // Ruler measurement
original_depth  = 55.8;     // Front to back
original_height = 1.7;      // How tall the new mount is (not the old module)

// There are 4 mounting holes which project out from
// the rectangle. The posts they drop onto need a slight
// tab
//
//     1                        2
//
//     3                        4
//
mount_hole_tab_1_from_left  = 37.0;
mount_hole_tab_2_from_right = 30.5;
mount_hole_tab_3_from_left  = 37.0;
mount_hole_tab_4_from_right = 30.5;

mount_hole_tab_depth = 5.0;
mount_hole_tab_width = 10.0;

mount_hole_hole_centre_1_3 = mount_hole_tab_1_from_left + (mount_hole_tab_width/2);
mount_hole_hole_centre_2_4 = mount_hole_tab_2_from_right + (mount_hole_tab_width/2);
mount_hole_hole_diameter   = 3.0;
mount_hole_hole_inset      = 2.0 + (mount_hole_hole_diameter/2);   // To hole centre

// A framing wall is created around the MIPI display to hold
// it in place. 
//
// The height of the wall needs to be taller than the display
// is thick. When the bezel clamps down on it, the belzel will
// clamp the wall, not the display itself.
//
// MIPI display is 3.4mm thick, wall needs to be taller.
//
mipi_display_width = 181.5 + 0.5;
mipi_display_depth =  38.2 + 0.5;
mipi_display_frame_height = 3.4 + 0.6;

// The frame walls need to be wide enough so they have the strength
// to hold the display in place. But the wider they are the more the
// gap between main display and side displays. 
// 
mipi_display_frame_width  = 1.5;

mipi_display_frame_outer_width = mipi_display_width + (mipi_display_frame_width*2);
mipi_display_frame_outer_depth = mipi_display_depth + (mipi_display_frame_width*2);

// The MIPI display has a ribbon, a connector and some kapton covered
// circuitry on its underside. There needs to be a hole for this. It's
// also where the display FTC connector heads off to the CM4.
//
mipi_display_circuitry_knockout_width = 50.0;

centre_point_x = original_width / 2+1;
centre_point_y = original_depth / 2;

// Side displays (TFT)
//
frame_width = 1.5;

side_display_width = 50.9 + 0.5;
side_display_depth = 45.8 + 0.5;
side_display_frame_height = 3.4 + 0.6;

side_display_frame_outer_width = side_display_width+2*frame_width;
side_display_frame_outer_depth = side_display_depth+2*frame_width;
side_display_shift= (side_display_frame_outer_depth - mipi_display_frame_outer_depth)/2;

new_base_plate_width = side_display_width*2 + mipi_display_width + frame_width * 2;

$fn = 32;


// Side display, with ribbon cable. display is mounted 'upside down' as if it isn't
// the ribbon cable slot cuts a lower tab off.

side_cable_width = 41;   // DF: AM had this at 40, right side slot was a fraction too narrow
side_cable_depth= 3;
side_cable_height = 20; // Arbitrary

module side_display()
{
  cube( [side_display_width, side_display_depth, side_display_frame_height] );
}
module side_display_cable()
{
  translate([side_display_width/2, side_display_depth+side_cable_depth/2-frame_width/2, 0])
  cube( [side_cable_width, side_cable_depth, side_cable_height], center=true );
}

module display_mount()
{
difference()
{
  // Create a big block and tag on the little tabs for the 
  // mounting holes
  //
  union()
  {
//    cube( [original_width, original_depth, original_height] );
    translate( [-(new_base_plate_width-original_width)/2+2, 0,0])
    cube( [new_base_plate_width, original_depth, original_height] );

    // Sticky out tab, top left
    //
    translate( [mount_hole_tab_1_from_left,
                original_depth,
                0] )
    {
      cube( [mount_hole_tab_width,
             mount_hole_tab_depth,
             original_height] );
    }

    // Sticky out tab, top right
    //
    translate( [original_width - mount_hole_tab_2_from_right - mount_hole_tab_width,
                original_depth,
                0] )
    {
      cube( [mount_hole_tab_width,
             mount_hole_tab_depth,
             original_height] );
    }

    // Sticky out tab, bottom left
    //
    translate( [mount_hole_tab_3_from_left,
                -mount_hole_tab_depth,
                0] )
    {
      cube( [mount_hole_tab_width,
            mount_hole_tab_depth,
            original_height] );
    }

    // Sticky out tab, bottom right
    //
    translate( [original_width - mount_hole_tab_4_from_right - mount_hole_tab_width,,
                -mount_hole_tab_depth,
                0] )
    {
      cube( [mount_hole_tab_width,
            mount_hole_tab_depth,
            original_height] );
    }
    
    // Now place a frame on top for the MIPI display to sit in
    // The seating area is a fraction of a mm larger than the display.
    // It can't rattle, or be too snug. Dimensions come from the
    // datasheet, plus a bit where needed.
    //
    // DF: The top and bottom rails of the MIPI display frame are
    // slightly too wide. They obscure the left side small display.
    // So push them over a couple of mm and make them a couple of mm
    // less wide.
    //
    translate( [centre_point_x - (mipi_display_frame_outer_width/2) + 2.00,
                centre_point_y - (mipi_display_frame_outer_depth/2),
                original_height] )
    {
      difference()
      {
        cube( [mipi_display_frame_outer_width-frame_width - 2.00,
               mipi_display_frame_outer_depth,
               mipi_display_frame_height] );

        translate( [0,
                    mipi_display_frame_width,
                    0] )
          cube( [mipi_display_frame_outer_width,
                mipi_display_depth,
                mipi_display_frame_height] );
      }
    }
 
   
    // LH Side display needs to be lifted up by 1mm
   translate( [centre_point_x - (mipi_display_frame_outer_width/2)-side_display_width,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift, original_height])
    
      cube([ side_display_width, side_display_depth, 1]);

   // Wall around the LH side display
    
   translate( [centre_point_x - (mipi_display_frame_outer_width/2)-side_display_width,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift-frame_width,
                original_height] )
    {
      difference()
      {
        cube( [side_display_frame_outer_width-frame_width,
               side_display_frame_outer_depth,
               side_display_frame_height] );

        translate( [frame_width,
                    frame_width,
                    0] )
          side_display();
          //cube( [side_display_width,
            //    side_display_depth,
              //  side_display_frame_height] );
      }
    }
   
    
  
      // RH Side display needs to be lifted up by 1mm
   translate( [centre_point_x + (mipi_display_frame_outer_width/2)+0,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift, original_height])
    
      cube([ side_display_width, side_display_depth, 1]);

   // Wall around the LH side display
    
   translate( [centre_point_x + (mipi_display_frame_outer_width/2)+0,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift-frame_width,
                original_height] )
    {
      difference()
      {
        // DF: the outer (right side) wall here comes out at 3.0mm.
        // I don't know why, but that's too wide. So trim it.
        cube( [side_display_frame_outer_width-frame_width-1.5,
               side_display_frame_outer_depth,
               side_display_frame_height] );

        translate( [-frame_width,
                    frame_width,
                    0] )

          side_display();
      }
    }
   
    }
  // Top left mounting post hole
  //
  translate( [mount_hole_hole_centre_1_3,
              original_depth + mount_hole_tab_depth - mount_hole_hole_inset,
              0] )
  {
    cylinder( h=original_height, d=mount_hole_hole_diameter, center=false );
  }

  // Top right mounting post hole
  //
  translate( [original_width - mount_hole_hole_centre_2_4,
              original_depth + mount_hole_tab_depth - mount_hole_hole_inset,
              0] )
  {
    cylinder( h=original_height, d=mount_hole_hole_diameter, center=false );
  }

  // Bottom left mounting post hole
  //
  translate( [mount_hole_hole_centre_1_3,
              -mount_hole_tab_depth + mount_hole_hole_inset,
              0] )
  {
    cylinder( h=original_height, d=mount_hole_hole_diameter, center=false );
  }

  // Bottom right mounting post hole
  //
  translate( [original_width - mount_hole_hole_centre_2_4,
              -mount_hole_tab_depth + mount_hole_hole_inset,
              0] )
  {
    cylinder( h=original_height, d=mount_hole_hole_diameter, center=false );
  }
  
  // Knock out the area behind the right side of the display
  // where the FTC connector and circuitry is
  //
  translate( [centre_point_x + (mipi_display_width/2) - mipi_display_circuitry_knockout_width,
              centre_point_y - (mipi_display_depth/2),
              0] )
  {
    cube( [mipi_display_circuitry_knockout_width, mipi_display_depth, original_height] );
  }

// RH cable exit slot  
    translate( [centre_point_x + (mipi_display_frame_outer_width/2)-frame_width + 0.5,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift-frame_width/2+1,
                original_height] )
    {
          // DF: The cutout for the right side display ribbon is about
          // 1mm too far left. I can't see why. I just moved it slightly
          // in the translate and made the slot wider in the module.
          side_display_cable();
    }
   
// LH cable exit slot  
    translate( [centre_point_x - (mipi_display_frame_outer_width/2)-side_display_width+frame_width,
                centre_point_y - (side_display_frame_outer_depth/2) + side_display_shift-frame_width/2+1,
                original_height] )
    {
          side_display_cable();
    }

}


}

display_mount();
