$fn=64;

difference() {
  linear_extrude(4) {
    translate([-35,0,0]) {
      square([70,40],40);
    }
  }
  cylinder(4, 34, 34);
}

translate([60,0,0]) {
  difference() {
    linear_extrude(4) {
      translate([-14,0,0]) {
        square([28,40],19);
      }
    }
    cylinder(4, 13, 13);
  }
}