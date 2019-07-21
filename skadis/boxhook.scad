use <../Round-Anything/polyround.scad>;

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
      [0,0],[0,15],[35,15],[35,5],[30.5,5],[30.5,10],[5,10],[5,5],[10,5],[16,0]
  ];

  template3 = [
    [35,15],[length, 15],[length, 10], [35,10]
  ];

    linear_extrude(width) {
        round2d(2,1) { 
          polygon(template2);
          polygon(template3);
        }
        
    };
}

$fn=36; // remove for dev
boxhook(50);