// Standalone Skadis hook for hanging items

use <../Round-Anything-1.0.0/polyround.scad>;

template = [
    [0,3], [0,6], [3,6], [3,1], [7,1], [7,3], [8,3],
    [8,1], [7,0], [3,0], [2,1], [2,5], [1,5], [1,4],
    [0,3]
];

scale = 5;
height = 5;

$fn=36; // remove for dev

linear_extrude(height) {
    round2d(2,2) polygon(template * scale);
};

translate([4 * scale, 1, height]) {
  linear_extrude(0.5) {
      text("47b", scale - 2);
  }
}
