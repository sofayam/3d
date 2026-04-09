lid_diameter = 40;
lid_thickness = 5;
bung_diameter = 20;
bung_height = 5;
slot_width = 5;
groove_depth = 3; // cuts into underside of lid, leaving 2mm solid on top

drain_hole_diameter = 6;
drain_hole_ring_radius = 17;
drain_hole_count = 6;

difference() {
    union() {
        cylinder(h = lid_thickness, d = lid_diameter, $fn = 64);
        translate([0, 0, -bung_height])
            cylinder(h = bung_height, d = bung_diameter, $fn = 64);
    }
    // Crossed grooves across full underside of lid + through bung
    translate([-slot_width/2, -lid_diameter/2, -bung_height])
        cube([slot_width, lid_diameter, bung_height + groove_depth]);
    translate([-lid_diameter/2, -slot_width/2, -bung_height])
        cube([lid_diameter, slot_width, bung_height + groove_depth]);

}