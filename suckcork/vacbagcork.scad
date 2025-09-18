// Parameters
x = 14;      // bottom radius
y = 3;       // taper increment (top radius = x + y)
z = 24;      // height
b = 4.6;       // bore radius

$fn = 100;   // smoothness

difference() {
    // Outer cork body
    cylinder(h = z, r1 = x, r2 = x + y);

    // Bore (straight cylinder)
    translate([0, 0, -1])  // extend slightly below
        cylinder(h = z + 2, r = b);
}