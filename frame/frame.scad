framelength = 100;



hide = 5;
nickdepth = 5;
base = 5;
nickfront = 2;
nick = 2;
nickback = 2;

frontdepth = 6;

backdepth = nickfront+nick+nickback;

depth=frontdepth+backdepth;
height=hide+nickdepth+base;


fulllength = framelength + (2 * hide); 
// 45 degree angle of cut means we can just use the hide depth as the length offset.



// From one end to the other so that the diagonal cut gives us the right length



difference() {
    cube([depth,height,fulllength], center=false);
    translate([frontdepth,nickdepth+base,0]) cube([backdepth,hide,fulllength], center=false);
    translate([frontdepth+nickfront,base,0]) cube([nick,nickdepth,fulllength], center=false);
 
    diagcut1();
    diagcut2();
  
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


