
// Customizable hex pattern
// Created by Kjell Kernen
// Date 22.9.2014

module hex(x,y, hex_radius, hex_border_width, height,render=true)
{
    if (render) {
        difference()
        {
            translate([x,y,-height/20]) 
                cylinder(r=(hex_radius+hex_border_width/20), h=height/10, $fn=6);	
            translate([x,y,-height/20]) 
                cylinder(r=(hex_radius-hex_border_width/20), h=height/10, $fn=6);
        }
    }
}

// Hex mesh and border parameters:
//   width -- distance along the X axis, in mm, range 10-100
//   length -- distance along the Y axis, in mm, range 10-100
//   hex_radius -- radius of the hex, in mm, range 1-20
//   height -- distance along the Z axis, in 0.1 mm, range 2-200
//   border_width -- width of the solid border arond the hex pattern, in 0.1 mm, range 2-100
//   hex_border_width -- width of the border around each hex, in 0.1mm, range 2-50

module hexwall(width, length, height, border_width=20, hex_radius=5, hex_border_width=30) {
    xborder=(border_width/10<width)?width-border_width/10:0;
    yborder=(border_width/10<length)?length-border_width/10:0;

    x=sqrt(3/4*hex_radius*hex_radius);
    ystep=2*x;
    xstep=3*hex_radius/2;

    translate([width/2,length/2,0]){
        //Pattern
        intersection()
        {
            for (xi=[0:xstep:width])
                for(yi=[0:ystep:length])
                    hex(xi-width/2,((((xi/xstep)%2)==0)?0:ystep/2)+yi-length/2, hex_radius, hex_border_width, height);
            translate([-width/2, -length/2, -height/20]) 
                cube([width,length,height/10]);
        }

        // Frame
        difference()
        {
            translate([-width/2, -length/2, -height/20]) 
                cube([width,length,height/10]);
            translate([-xborder/2, -yborder/2, -(height/20+0.1)]) 
                cube([xborder,yborder,height/10+0.2]); 
        }
    }
}