$fn=64;


module cross(height, w) {
    linear_extrude(height)
        square([w, 4], center = true);


    linear_extrude(height)
        square([4, w], center = true);
}

module plunge(w) {
    linear_extrude(w/2) 
        circle(d=w);
}

l = 60;
w = 16;

cross(l, w-4);
translate([0, 0, -w/2]) plunge(w);

translate([0,0,l])
    linear_extrude(5) 
        scale([2.5, 1]) 
            circle(d=20);

