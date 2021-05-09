module face(y,z=8.0) {
    ratio = 0.71875;
    x = y * ratio;

    linear_extrude(z) {
        difference() {
            // Blank
            polygon([[0,0], [x,0], [x,y], [0,y]]);

            // Eye (large)
            polygon([[12,44],[29,44],[29,85],[12,85]]);

            // Eye (small)
            polygon([[53,44],[65,44],[65,85],[53,85]]);

            // Mouth
            polygon([[0,100],[34,100],[34,111],[0,111]]);
        }
    }
}

face(128.0);