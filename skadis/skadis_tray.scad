use <tray.scad>

// You'll need a tray.
//
// This will draw a tray 90x40x35mm
// The walls of the tray will be 2.5mm in thickness
// The hooks attached to the tray will be 55mm in height
// The tray will be printed with an open face (the true part)
// The tray will be printed with a honeycomb patterned base
//

length=90;      // x
height=35;      // z
depth=40;       // y
wall=2.5;
hooks=height+20;
open=true;
tray(length, depth, height, wall, hooks, open);
