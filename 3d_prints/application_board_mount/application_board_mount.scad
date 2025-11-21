frame_width      = 3.0;
shelf_height     = 1.6;

front_left_foot_width  = 10.0;
front_left_foot_depth  = 21.3;
front_left_foot_height = 4.8+shelf_height;
translate( [0, 0, 0] )
{
  difference()
  {
    cube( [front_left_foot_width, front_left_foot_depth, front_left_foot_height],
          false );

    shelf_offset = 13.0;
    translate( [frame_width, shelf_offset,
                front_left_foot_height-shelf_height] )
      cube( [front_left_foot_width-frame_width,
             front_left_foot_depth-shelf_offset,
             shelf_height], false );
  }
}

front_right_foot_width  = 4.45;
front_right_foot_depth  = 15.5;  // Assumes 15 way D-SUB is in place
front_right_foot_height = 4.8+shelf_height;
translate( [11, 0, 0] )
{
  difference()
  {
    cube( [front_right_foot_width, front_right_foot_depth, front_right_foot_height],
          false );

    shelf_offset = 8.0;
    translate( [0, shelf_offset, front_right_foot_height-shelf_height] )
      cube( [front_right_foot_width-frame_width/2, front_right_foot_depth-shelf_offset,
             shelf_height], false );
  }
}

rear_left_foot_width  = 15.0;
rear_left_foot_depth  = 13.5;
rear_left_foot_height = 4.8+shelf_height;
translate( [16, 0, 0] )
{
  difference()
  {
    cube( [rear_left_foot_width, rear_left_foot_depth, rear_left_foot_height],
          false );

    $fn=32;
    translate( [5.5, 16.0, 0] )
      cylinder(rear_left_foot_height, 4.5, 4.5 );

    shelf_offset = 7.25;
    translate( [frame_width, 0, rear_left_foot_height-shelf_height] )
      cube( [rear_left_foot_width-frame_width,
             rear_left_foot_depth-shelf_offset,
             shelf_height], false );
  }
}

rear_right_foot_width  = 15.0;
rear_right_foot_depth  = 13.0;
rear_right_foot_height = 4.8+shelf_height;
translate( [32, 0, 0] )
{
  difference()
  {
    cube( [rear_right_foot_width, rear_right_foot_depth, rear_right_foot_height],
          false );

    $fn=32;
    translate( [rear_right_foot_width-5.5, 16.0, 0] )
      cylinder(rear_left_foot_height, 4.5, 4.5 );

    shelf_offset = 6.0;
    translate( [0, 0, rear_right_foot_height-shelf_height] )
      cube( [rear_right_foot_width-7.0,
             rear_right_foot_depth-shelf_offset,
             shelf_height], false );
  }
}
