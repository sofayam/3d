// --- User Parameters ---
message = "STENCIL";
font_size = 20;
stencil_thickness = 1.6; // 8 layers at 0.2mm - very rigid
bridge_fatness = 1.8;    // Thick enough for 4-5 nozzle passes
margin = 10;             // Extra plastic around the text
font_name = "Liberation Sans:style=Bold";

// --- The Assembly ---
difference() {
    // 1. The Physical Plate
    stencil_plate();

    // 2. The Text Cutouts
    translate([margin, margin + (font_size/2), 0])
        stencil_text(message);
}

// --- Modules ---
module stencil_plate() {
    plate_width = (len(message) * font_size * 0.7) + (margin * 2);
    plate_height = font_size + (margin * 2);
    
    cube([plate_width, plate_height, stencil_thickness]);
}

module stencil_text(txt) {
    for (i = [0 : len(txt) - 1]) {
        translate([i * font_size * 0.7 + (font_size/2), 0, 0]) {
            char = txt[i];
            difference() {
                // The Letter Hole
                linear_extrude(height = stencil_thickness + 2)
                    text(char, size = font_size, font = font_name, halign = "center");

                // The Reinforcing Bridges (We "add" material back into the hole)
                if (search(char, "AMUVWYH") != [])  bridge_geometry(0); 
                if (search(char, "BDOPQR0689") != []) bridge_geometry(90);
                if (search(char, "ODQ0") != []) bridge_geometry(0);
            }
        }
    }
}

module bridge_geometry(angle) {
    rotate([0, 0, angle])
        cube([bridge_fatness, font_size * 2, stencil_thickness * 3], center = true);
}
