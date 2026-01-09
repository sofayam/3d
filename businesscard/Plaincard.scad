// --- USER SETTINGS ---
card_w = 85.6; // Standard CR80 width
card_h = 53.98; // Standard CR80 height
base_t = 1.0;   // Base thickness
text_h = 0.5;   // Height of the raised text
font_name = "Allerta Stencil";

// --- THE CARD BASE ---
color("SlateGray")
cube([card_w, card_h, base_t]);

// --- TEXT MODULE ---
module info_line(label, value, y_pos) {
    translate([5, y_pos, base_t])
        linear_extrude(text_h) {
            text(label, size=2.5, font=font_name);
            translate([20, 0, 0]) // Adjust the 20 to align values
                text(value, size=2.8, font=font_name);
        }
}

// --- DATA ENTRY ---
// Name Section
translate([5, 42, base_t])
    linear_extrude(text_h + 0.2) // Make name slightly taller for hierarchy
        text("Mark Andrew", size=6, font=font_name);

// Information Lines (Adjust Y-positions to fit more)
info_line("NIF:", "283634278", 32);
info_line("EMAIL:", "mark.andrew@gmail.com", 26);
info_line("TEL:", "+351 928 158 034", 20);
info_line("ADDR:", "Rua do Pinheiro Manso 17, ", 14);
info_line("", "8500-013 Alvor, Portugal", 8);

// Optional: A decorative border to help the eye frame the data
difference() {
    translate([1, 1, base_t]) 
        linear_extrude(text_h) 
            difference() {
                square([card_w-2, card_h-2]);
                translate([0.5, 0.5]) square([card_w-3, card_h-3]);
            }
}
