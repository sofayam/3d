


// configurable values

tubediam=26;
tubethickness=3;
tubelength=50;

cupdiam=64;
cupthickness=8;
cuplength=26;

// derived values
tubeouterradius=tubediam/2;
tubeinnerradius=tubeouterradius-(tubethickness/2);
cupouterradius=cupdiam/2;
cupinnerradius=cupouterradius-(cupthickness/2);

// the tube
difference() {
cylinder(h=tubelength,r=tubeouterradius);
translate([0,0,-1]) cylinder(h=tubelength+2, r=tubeinnerradius);
}

// the cup
rotate([90,0,0])
translate([0,tubelength+cupouterradius-2,-tubeouterradius]) {
    
difference() {
    cylinder(h=cuplength, r=cupouterradius);
    translate([0,0,-3]) cylinder(h=cuplength+5, r= cupinnerradius);
    translate([-cupdiam/2,0,0])
    cube(cupdiam);
}

}

