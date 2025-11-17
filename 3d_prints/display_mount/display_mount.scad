// Original LCD module is a large rectangular block
//
original_width  = 272.0;    // Ruler measurement
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
mount_hole_tab_2_from_right = 32.5;
mount_hole_tab_3_from_left  = 37.0;
mount_hole_tab_4_from_right = 32.5;

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
// These values are from the display datasheet, plus a little
// wiggle room. MIPI display is 3.4mm thick, wall needs to be taller.
//
mipi_display_width = 181.5 + 0.5;
mipi_display_depth =  38.2 + 0.5;
mipi_display_frame_height = 3.4 + 0.6;

// The frame walls need to be wide enough so they have the strength
// to hold the display in place. But the wider they are the more the
// gap between main display and side displays. 
// 
mipi_display_frame_width  = 0.75;

mipi_display_frame_outer_width = mipi_display_width + (mipi_display_frame_width*2);
mipi_display_frame_outer_depth = mipi_display_depth + (mipi_display_frame_width*2);

// The MIPI display has a ribbon, a connector and some kapton covered
// circuitry on its underside. There needs to be a hole for this. It's
// also where the display FTC connector heads off to the CM4.
//
mipi_display_circuitry_knockout_width = 50.0;

mipi_centre_point_x = original_width / 2;
mipi_centre_point_y = original_depth / 2;

// OLEDs are the 1.3" version
//
oled_display_width  = 35.4;
oled_display_depth  = 33.3;

// Walls are the same for now
//
oled_display_frame_height = mipi_display_frame_height;
oled_display_frame_width = mipi_display_frame_width;

oled_display_frame_outer_width = oled_display_width + (oled_display_frame_width*2);
oled_display_frame_outer_depth = oled_display_depth + (oled_display_frame_width*2);

$fn = 32;

difference()
{
  // Create a big block and tag on the little tabs for the 
  // mounting holes
  //
  union()
  {
    cube( [original_width, original_depth, original_height] );

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
    translate( [mipi_centre_point_x - (mipi_display_frame_outer_width/2),
                mipi_centre_point_y - (mipi_display_frame_outer_depth/2),
                original_height] )
    {
      difference()
      {
        cube( [mipi_display_frame_outer_width,
               mipi_display_frame_outer_depth,
               mipi_display_frame_height] );

        translate( [mipi_display_frame_width,
                    mipi_display_frame_width,
                    0] )
          cube( [mipi_display_width,
                mipi_display_depth,
                mipi_display_frame_height] );
      }
    }
  
    // Left side OLED frame. Inner side of the frame sits on top of the MIPI
    // screen's frame
    //
    translate( [mipi_centre_point_x - (mipi_display_frame_outer_width/2) - oled_display_frame_outer_width
                                                                         + oled_display_frame_width,
                mipi_centre_point_y - (oled_display_frame_outer_depth/2),
                original_height] )
    {
      difference()
      {
        cube( [oled_display_frame_outer_width,
               oled_display_frame_outer_depth,
               oled_display_frame_height] );

        translate( [oled_display_frame_width,
                    oled_display_frame_width,
                    0] )
          cube( [oled_display_width,
                 oled_display_depth,
                 oled_display_frame_height] );
      }
    }

    // Right side OLED frame. Inner side of the frame sits on top of the MIPI
    // screen's frame
    //
    translate( [mipi_centre_point_x + (mipi_display_frame_outer_width/2) - oled_display_frame_width,
                mipi_centre_point_y - (oled_display_frame_outer_depth/2),
                original_height] )
    {
      difference()
      {
        cube( [oled_display_frame_outer_width,
               oled_display_frame_outer_depth,
               oled_display_frame_height] );

        translate( [oled_display_frame_width,
                    oled_display_frame_width,
                    0] )
          cube( [oled_display_width,
                 oled_display_depth,
                 oled_display_frame_height] );
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
  translate( [mipi_centre_point_x + (mipi_display_width/2) - mipi_display_circuitry_knockout_width,
              mipi_centre_point_y - (mipi_display_depth/2),
              0] )
  {
    cube( [mipi_display_circuitry_knockout_width, mipi_display_depth, original_height] );
  }

  // Knock out gaps for OLED wires. I actually knock out a sort of large cross
  // made from two cubes, leaving posts in the corners
  //
  oled_post_width = 5.5;
  
  // Left side OLED wire knockout
  //
  union()
  {
    // Front to back knockout
    //
    translate( [mipi_centre_point_x - (mipi_display_frame_outer_width/2) - oled_display_frame_outer_width
                                                                         + (oled_display_frame_width*2)
                                                                         + oled_post_width,
                mipi_centre_point_y - (oled_display_depth/2),
                0] )
      cube( [oled_display_width - (oled_post_width*2),
             oled_display_depth,
             original_height] );

    // Left to right knockout
    //
    translate( [mipi_centre_point_x - (mipi_display_frame_outer_width/2) - oled_display_width,
                mipi_centre_point_y - (oled_display_depth/2) + oled_post_width,
                0] )
      cube( [oled_display_width,
             oled_display_depth - (oled_post_width*2),
             original_height] );
  }

  // Right side OLED wire knockout
  //
  union()
  {
    translate( [mipi_centre_point_x + (mipi_display_frame_outer_width/2) + oled_post_width,
                mipi_centre_point_y - (oled_display_depth/2),
                0] )
      cube( [oled_display_width - (oled_post_width*2),
             oled_display_depth,
             original_height] );

    translate( [mipi_centre_point_x + (mipi_display_frame_outer_width/2),
                mipi_centre_point_y - (oled_display_depth/2) + oled_post_width,
                0] )
      cube( [oled_display_width,
             oled_display_depth - (oled_post_width*2),
             original_height] );
  }
  
  // The inside of the original bezel has an intrusion on the very right
  // hand side. It just fouls on the edge of the mount. With everything
  // else pretty much perfect, the simplist solution is to trim the side
  // very slightly.
  //
  right_side_trim = 2.25;
  translate( [original_width-right_side_trim, 0, 0 ] )
    cube( [right_side_trim, original_depth, original_height] );
  
  // The mount won't quite fit on the bed of my printer. Nip the corners off.
  // 5mm is adequate to make it fit, but removing a bit more material makes for
  // a faster print.
  //
  nip_size = 5.0;
  translate( [0, 0, 0 ] )
    cube( [nip_size, nip_size, original_height] );
  translate( [0, original_depth-nip_size, 0 ] )
    cube( [nip_size, nip_size, original_height] );
  translate( [original_width-nip_size-right_side_trim, 0, 0 ] )
    cube( [nip_size, nip_size, original_height] );
  translate( [original_width-nip_size-right_side_trim, original_depth-nip_size, 0 ] )
    cube( [nip_size, nip_size, original_height] );
}


