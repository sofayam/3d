// TBD parameterize this

// sizes 148 x 210 // Original
makeframe = 1;
makecornerslot = 2;
makecornerglue = 3;

make = makecornerglue;

framelength = 210;

hide = 5;
nickdepth = 5;
base = 5;
nickfront = 2;
nick = 2;
nickback = 2;
slit = 10;
slitwidth = 2;

frontdepth = 6;

cornersize= 25;

backdepth = nickfront+nick+nickback;

depth=frontdepth+backdepth;
height=hide+nickdepth+base;
extra = nickdepth+base;


fulllength = framelength + (2 * extra); 
// 45 degree angle of cut means we can just use the hide depth as the length offset.



// From one end to the other so that the diagonal cut gives us the right length

module frame() {
difference() {
    cube([depth,height,fulllength], center=false);
    // overlap at edge of picture
    translate([frontdepth,nickdepth+base,0]) cube([backdepth,hide,fulllength], center=false);
    // nick for fastening back of picture
    translate([frontdepth+nickfront,base,0]) cube([nick,nickdepth,fulllength], center=false);
 
    // fastening slits
    translate([frontdepth+nickfront,0,0]) cube([slitwidth,slit,slit]);
    translate([frontdepth+nickfront,0,fulllength-slit]) cube([slitwidth,slit,slit]);
    
        // fastening slits
    translate([nickfront,0,0]) cube([slitwidth,slit,slit]);
    translate([nickfront,0,fulllength-slit]) cube([slitwidth,slit,slit]);
    
    // diagonal cuts
    diagcut1();
    diagcut2();
  
   }
}
  
module diagcut1() {
translate([0,0,height])
rotate([0,90,0])
linear_extrude(depth)
polygon ([[height,height],[height,0],[0,height]]);
}



module diagcut2() {
translate([0,0,fulllength])
rotate([0,90,0])
linear_extrude(depth)
polygon ([[0,0],[height,height],[0,height]]);
}

module cornerslot() {
   // Needed for wood fibre
   // fudge = 0.6;
   // Normal 
   fudge = 0.05;
   union() {
   difference() {
        cube([15,15,10]);
        translate([3,3,0]) cube([15,15,15]);
   }
   translate ([2,2,1]) cube([slit, slit, slitwidth-fudge]);
   translate ([2,2,7]) cube([slit, slit, slitwidth-fudge]);
    
}
}

module cornerglue() {
    
    difference() { cube([cornersize,cornersize,depth]);
    translate([5,5,0]) cube([cornersize,cornersize,depth]);
}
}

if (make == makeframe)
   frame();
else if (make == makecornerglue)
   cornerglue();
else if (make == makecornerslot)
   cornerslot();




