// Hook to be attached a part of a tray or other
// Skadis item for fixing it to the board 

use <../Round-Anything/polyround.scad>;

// length:  in mm, how long the hook is, minimum should be 40, divisible by 5
// width: in mm, how wide the hook is, adjust for compatibilty with slots in rings etc

module boxhook(length) {
  unit = 5;  // 0.5 mm is ths size of the smallest feature 
  width=4.25; // any narrower than this and it rattles in place

  template = [
      [0,3], [(length/unit),3], [(length/unit), 0], [(length/unit)-4, 0],
      [(length/unit)-2,1], [(length/unit)-1,1], [(length/unit)-1,2],
      [(length/unit)-6,2], [(length/unit)-6,1], [(length/unit)-7,1], [(length/unit)-7,2],
      [1,2], [0,3]
  ];


  template2 = [
      [0,0],[0,15],[35,15],[35,5],[30,5],[30,10],[5,10],[5,5],[10,5],[16,0]
  ];

  // need a third polygon here, one which puts in the lower piece that latches
  // on to the hole below in the peg board DOG

  template3 = [
    [35,15],[length, 15],[length, 10], [35,10]
  ];

    linear_extrude(width) {
        round2d(2,1) { 
          polygon(template2);
          polygon(template3);
        }
        
    };

    echo (template);

    translate([2 * unit, 3*unit, width * 0.125]) {
      labtag(width);
    }

}

module grid(space, size, x = 100, y = 100) { 
  Space = 1.0; 
  Size = 0.1; 

    RangeX = floor(ExtentX / (2*Space)); 
    RangeY = floor(ExtentX / (2*Space)); 

          for (x=[-RangeX:RangeX]) 
            for (y=[-RangeY:RangeY]) 
                  translate([x*Space,y*Space,Size/2]) 
                    %cube(Size,center=true); 
} 

module labtag(h) {
  rotate([90, 0, 270]) {
    linear_extrude(0.5) {
        text("47b", h - 1);
    }
  }
}

$fn=36; // remove for dev

// ShowPegGrid();

boxhook(50);