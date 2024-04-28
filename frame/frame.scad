length = 150;

frontdepth = 6;

hide = 5;
nickdepth = 5;
base = 5;
nickfront = 2;
nick = 2;
nickback = 2;
backdepth = nickfront+nick+nickback;

depth=frontdepth+backdepth;
height=hide+nickspace+base;


difference() {
    cube([depth,height,length], center=false);
    translate([frontdepth,nickdepth+base,0]) cube([backdepth,hide,length], center=false);
    translate([frontdepth+nickfront,base,0]) cube([nick,nickdepth,length], center=false);


}