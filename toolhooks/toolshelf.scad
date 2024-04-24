// Dimensions
compartments = 6;
units = 5;
inch = 25.4;
extra_length = 9; // mm
extra_width = 9;
block_length = units*inch+extra_length; // inches
block_width = 1*inch + extra_width; // inches
block_height = 2*inch; // inches
wallthick = 10;
hole_length = (block_length/compartments) - (wallthick/2) ; // inches
hole_width = (1 * inch)  + (extra_width / 3);
hole_depth = 1.75*inch;
hole_offset = 0.125*inch; // inches
fudge = 0.125*inch;

peg_size = 3.2;
peg_depth = 5;
backpeg_inset = 2 + (peg_size/2); // deal with centering
// Block
difference() {
    cube([block_width, block_length, block_height], center = false);
    
    // Holes
    for (i = [0:compartments-1]) {
        //translate([i * (block_width / 3) - block_width / 2 + hole_offset, -block_length / 2 + hole_offset, 0])
        translate([hole_offset,(((block_length-extra_length) / compartments)*i)+fudge, -0.25]) 
        
        cube([hole_width, hole_length, hole_depth], center = false);
    }
    
    pegx = backpeg_inset;
    pegy = extra_length/2;
    pegz = block_height-peg_depth;
    translate([pegx,pegy,pegz]) cube([peg_size, peg_size, 10], center = true);
    pegxlow = pegx + inch;
    translate([pegxlow,pegy,pegz]) cube([peg_size, peg_size, 10], center = true);
    pegywide = pegy + units * inch;
    translate([pegx,pegywide,pegz]) cube([peg_size, peg_size, 10], center = true);
    translate([pegxlow,pegywide,pegz]) cube([peg_size, peg_size, 10], center = true);
}