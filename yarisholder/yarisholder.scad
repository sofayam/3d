//import("mobhold_155mm.stl");

// insert is 155

// orig slot width is 155
// desired width is 167
// insert is desired - orig / 2

// first cut at 40

// next cut at 178 + insert



module orig() {
    
    

translate([149,0,0]) {

import("mobhold_155mm.stl");

};

}


module beginning() {
    intersection() {
        orig();
        cube(40,20,30)
    }
}
// orig();

// Claude Hints 
// Parameters
object_height = 50;
object_width = 30;
object_depth = 20;
cut_height = 30;
extension_height = 10;

// Original object
module original_object() {
    cube([object_width, object_depth, object_height]);
}

// Bottom part
module bottom_part() {
    intersection() {
        original_object();
        translate([0, 0, -0.1])
            cube([object_width, object_depth, cut_height + 0.1]);
    }
}

// Top part
module top_part() {
    translate([0, 0, cut_height + extension_height])
        difference() {
            original_object();
            translate([0, 0, -object_height])
                cube([object_width, object_depth, cut_height]);
        }
}

// Extension
module extension() {
    translate([0, 0, cut_height])
        cube([object_width, object_depth, extension_height]);
}

// Final assembly
//bottom_part();
//extension();
//top_part();



