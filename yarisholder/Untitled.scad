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
        cube([object_width-5, object_depth-5, extension_height]);
}

// Final assembly
bottom_part();
extension();
top_part();