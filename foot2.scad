// Simple 'foot' for placing a wooden dowel in, with a screw hole in the base to
// allow it to be solidly attached to the dowel with a wood screw.

$fn=256;
foot_height = 32; 
dowel_radius = 14;
foot_top_radius = dowel_radius + 3; 
foot_bottom_radius = dowel_radius + 7;
base_thickness = 8;
screw_head_top_radius = 2.9;
screw_head_bottom_radius = 1.1;

difference() {
  cylinder(foot_height, foot_bottom_radius, foot_top_radius, true);
  translate([0, 0, base_thickness]){
    cylinder(foot_height, dowel_radius, dowel_radius, true);
  }
  translate([0, 0, -(foot_height/2)+base_thickness/2 ]){
    // Radii are intentionally inverted! The screw is
    // "upside down" relative to the foot
    cylinder(base_thickness, screw_head_top_radius, screw_head_bottom_radius, true); 
  }
};