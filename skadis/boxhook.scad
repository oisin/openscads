// Hook to be attached a part of a tray or other
// Skadis item for fixing it to the board 

use <../Round-Anything/polyround.scad>;

// length:  in mm, how long the hook is, minimum should be 40, divisible by 5
// width: in mm, how wide the hook is, adjust for compatibilty with slots in rings etc

module boxhook(length=50) {
  unit = 5;
  width=4.5; // any narrower than this and it rattles in place

  template = [
      [3,0], [3, (length/unit)], [0, (length/unit)], [0, (length/unit)-4],
      [1,(length/unit)-2], [1,(length/unit)-1], [2,(length/unit)-1],
      [2,(length/unit)-6], [1,(length/unit)-6], [1,(length/unit)-7], [2,(length/unit)-7],
      [2,1], [3,0]
  ];

  $fn=36; // remove for dev

  rotate([90,0,270]) {
    linear_extrude(width) {
        round2d(2,1) 
        polygon(template * unit);
    };

    echo (template);

    translate([2 * unit, 3*unit, width * 0.125]) {
      rotate([90, 0, 270]) {
        linear_extrude(0.5) {
            text("47b", width - 1);
        }
      }
    }
  }
}

boxhook(50);