use <../Round-Anything/polyround.scad>;

module boxhook(length,blip=true) {
  unit = 5;  // 0.5 mm is ths size of the smallest feature 
  width= 4.25; // optimal width for Skadis in mm

    linear_extrude(width) {
        round2d(2,1) { 
          if (length >= 50) {
            // if the hook is to be long, then put a blip on it like so that it slots
            // in well and solidly to the board
            polygon([[0,0],[0,15],[40,15],[40,5],[35.5,5],[35.5,10],[5,10],[5,5],[10,5],[16,0]]);
            polygon([[40,15],[length, 15],[length, 10], [40,10]]);
          } else {    
            // if the hook it to be less than 50mm in length then no need for a blip
            polygon([[0,0],[0,15],[length,15],[length,10],[5,10],[5,5],[10,5],[16,0]]);
          }
        }
    };
}

// DEV TESTING
// $fn=36; // remove for dev
// boxhook(47);