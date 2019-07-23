
module grid(space = 1.0, block = 0.1,x = 200, y = 200) { 
  rx = floor(x / (2*space)); 
  ry = floor(y / (2*space)); 

  for (x=[-rx:rx]) 
    for (y=[-ry:ry]) 
          translate([x*space,y*space,block/2]) 
            %cube(block,center=true); 
} 
