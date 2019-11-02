// Make a little badge that says honk.

module holed_ellipse(width, height) {
    difference() {
        scale([1, height/width,0]) circle(r=width/2);
        hole(-8.5, 0.75);
        hole(8.5, 0.75);
    }
}

module hole(x, r) {
    translate([x,0,0]) circle(r);
}

$fn = 48;

top=1.5;
bottom=0.5;

linear_extrude(top) {
    difference() {
        holed_ellipse(20,10);
        #text("HONK", 4, halign="center", valign="center", font="American Typewriter:style=Regular");
    }
}

linear_extrude(bottom) {
    translate([0,0,-bottom]) holed_ellipse(20,10);
}