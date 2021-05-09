// Plan: construct a parameterised holder for paints that can hang on an IKEA Skadis
// pegboard parameters should be n, m which are the number of paint bottles that the 
// holder should contain e.g. (6, 1) will be a single line of paint bottles with six 
// bottles in it.
//


side=30;

module holder(x,y,z) {
    translate([x,y,z]){
        difference() {
            cube([side,side,3], true);
            cylinder(5, 13, 13, true);
        }
    }
}

module holders(n,m=1) {
    for (x=[0:n-1]) {
        holder(x*side,0,0);
        for (y=[0:m-1]) {
            holder(x*side, y*side, 0);
        }
    }
}

use <tray.scad>

// You'll need a tray.
//
// This will draw a tray 90x40x35mm
// The walls of the tray will be 2.5mm in thickness
// The hooks attached to the tray will be 55mm in height
// The tray will be printed with an open face (the true part)
// The tray will be printed with a honeycomb patterned base
//

holders_length = 6;
holders_depth = 1;

length = holders_length * 30.5;      // x
height=35;      // z
depth= holders_depth * 33;       // y
wall=3;
hooks=height+20;
open=true;
tray(length, depth, height, wall, hooks, open, false);

translate([side/2 + wall,side/2 + wall,height-wall/2])  #holders(holders_length, holders_depth);