// Dimensions from the diagram
window_width = 65;    // Width of the window in mm  measured 63
window_height = 18;   // Height of the window in mm
window_thickness = 2; // Thickness of the main piece
clip_depth = 8;       // Depth of the flexible clip
clip_width = window_height;       // Width of each flexible clip
hook_height = 4;      // Height of the hook portion
hook_radius = 2;      // Curved radius of the hook
stem_length = 3;      // Length of the vertical stem before the hook

module mailbox_visor_with_flexible_hooks() {
    // Create the main rectangular visor part
    visor(window_width, window_height, window_thickness);

    // Add flexible hooked clips on the sides
    add_flexible_hooks(window_width, window_height, clip_depth, clip_width, hook_radius, stem_length, hook_height);
}

// Function to create the rectangular visor
module visor(w, h, t) {
    cube([w+3, h+3, t], center = true);
}

// Function to add flexible hooks to both sides of the visor
module add_flexible_hooks(w, h, depth, clip_w, radius, stem_len, hook_h) {
    for (i = [-1, 1]) {
        // Create the flexible clips on the left and right sides
        translate([i * (w / 2 - 2), 0, -2])
            flexible_hook(clip_w, radius, stem_len, hook_h);
    }
}

// Module to create a single flexible clip with a curved hook
module flexible_hook(width, radius, stem_len, hook_h) {
    // Create the vertical flexible stem
      rotate([0, 0, 90])
    translate([0, 0, 0])
        cube([width, 2, stem_len+2], center = true);

    // Create the rounded hook using cylinder and translate to hook end
    translate([0, 0, -stem_len])
        rotate([90, 0, 0])
            cylinder(r=radius, h=width, center=true);

    // Add an extended hook base to finish the clip
        rotate([0, 0, 90])
    translate([0, 0, -stem_len - radius])
        cube([width, 2, hook_h], center = true);
}

// Call the module to render the model
mailbox_visor_with_flexible_hooks();