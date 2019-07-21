module labtag(h) {
  rotate([90, 0, 270]) {
    linear_extrude(0.5) {
        text("47b", h - 1);
    }
  }
}