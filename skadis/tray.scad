// Parametric ish tray for holding things.

use <boxhook.scad>
use <hex.scad>

module hooks(length, depth, height, wt) {
    // The hooks need to have 75mm between them to fit the board
    hook_separation = 75;
    hook_width = 4.25;

    first_hook_x = (length - hook_separation) / 2;
    second_hook_x = first_hook_x + hook_separation + hook_width;

    translate([first_hook_x,depth+10+wt,height]) rotate(a=[0, 90, 180]) boxhook(height);
    translate([second_hook_x,depth+10+wt,height]) rotate(a=[0, 90, 180]) boxhook(height);
}

module tray(x,y,z,wt,hl,open_face=false) {
    difference() {
        // basic cuboid shape
        cube([x, y, z]);

        // cut out the space from the basic cuboid shape
        // to make the tray
        translate([wt,wt,0]) { 
            cube([x - wt * 2, y - wt * 2, z]);
        }
        
        if (open_face) {
            difference() {
                translate([0, 0, z / 4]) {                
                    // cut out part of the front face to reduce material
                    cube([x, y - wt, z / 1.5]);
                };

                // rigidity supports are useful to keep the shape if 
                // content is a little weighty
                translate([0,0,0]) cube([wt, wt, z]);
                translate([x-wt, 0, 0]) cube([wt, wt, z]);
            }
        };
    }

    hooks(x, y, hl, wt);
    hexwall(x, z, 5);
};
