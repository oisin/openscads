// Parametric ish tray for holding things.

use <boxhook.scad>

$fn = 24;  // uncomment for production

// set to true for production -- this prevents hex render which takes
// a couple minutes
use_hex_base = true;  

module hooks(length, depth, height) {
    // The hooks need to have 70mm between them to fit the board
    hook_separation = 70;
    hook_width = 4.25;

    first_hook_x = (length - hook_separation) / 2;
    second_hook_x = first_hook_x + hook_separation + hook_width;

    echo(first_hook_x);
    echo(second_hook_x);
    // 2.5 for the wall thickness here 
    translate([first_hook_x,depth+12.5,height]) rotate(a=[0, 90, 180]) boxhook(height);
    translate([second_hook_x,depth+12.5,height]) rotate(a=[0, 90, 180]) boxhook(height);
}

module hex(x,y, render=true)
{
    if (render) {
        difference()
        {
            translate([x,y,-height2/20]) 
                cylinder(r=(hex_radius+hex_border_width/20), h=height2/10, $fn=6);	
            translate([x,y,-height2/20]) 
                cylinder(r=(hex_radius-hex_border_width/20), h=height2/10, $fn=6);
        }
    }
}

module tray(x,y,z,wt,open_face=false) {
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
};

length = 90;
depth = 40;
height = 35;
wall_thickness = 2.5;


tray(length, depth, height, wall_thickness, true);

hooks(length, depth, height);


// first arg is vector that defines the bounding box, length, width, height
// second arg in the 'diameter' of the holes. In OpenScad, this refers to the corner-to-corner diameter, not flat-to-flat
// this diameter is 2/sqrt(3) times larger than flat to flat
// third arg is wall thickness.  This also is measured that the corners, not the flats. 

//hexgrid([length, depth, 2], 10, 5);


// Customizable hex pattern
// Created by Kjell Kernen
// Date 22.9.2014

/*[Pattern Parameters]*/
// of the pattern in mm:
width=90;       // [10:100]

// of the pattern in mm:
lenght=40;      // [10:100]

// of the pattern in tens of mm:
height2=5;       // [2:200]

// in tens of mm:
border_width=20;// [2:100]

// in mm:
hex_radius=5;   // [1:20]

// in tens of mm: 
hex_border_width=30; // [2:50]

/*[Hidden]*/

if (use_hex_base) {
    echo("using hexxxxx");
    xborder=(border_width/10<width)?width-border_width/10:0;
    yborder=(border_width/10<lenght)?lenght-border_width/10:0;

    x=sqrt(3/4*hex_radius*hex_radius);
    ystep=2*x;
    xstep=3*hex_radius/2;

    translate([width/2,lenght/2,0]){
        //Pattern
        intersection()
        {
            for (xi=[0:xstep:width])
                for(yi=[0:ystep:lenght])
                    hex(xi-width/2,((((xi/xstep)%2)==0)?0:ystep/2)+yi-lenght/2);
            translate([-width/2, -lenght/2, -height2/20]) 
                cube([width,lenght,height2/10]);
        }

        // Frame
        difference()
        {
            translate([-width/2, -lenght/2, -height2/20]) 
                cube([width,lenght,height2/10]);
            translate([-xborder/2, -yborder/2, -(height2/20+0.1)]) 
                cube([xborder,yborder,height2/10+0.2]); 
        }
    }
} else {
    echo("no hexxxxx");
    translate([0,0,0]) #cube([length, depth, wall_thickness]);
}
