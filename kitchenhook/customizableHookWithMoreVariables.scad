base_thickness = 6;
base_height = 40;
base_width = 20;
hook_distance = 36;
fixing_hole = 0;      //[0:OFF, else:diameter]
// new parameters by mcmusic :
point_size = 2;       // the size of the hook tip
more_cutaway = 0.7;   // [0:originalDesign to 1:maximumCutaway]
base_convexity = 3.0; //0.001=flat; 3=original
// The sticky tape can be hidden in a cavity below the base.
// But this must eventually be printed with support - may be difficult to remove.
cavity = 0;           //[0:OFF, else: cavity_depth]
cavity_rim = 2;

Sfn = 30; //30 for testing, 90 for prints.

module Cavity() {
  if (cavity > 0)
  {
    color("red")
    translate([0, 0, -base_thickness / 2])
    {
      resize([base_width - 2 * cavity_rim, base_height - 2 * cavity_rim, cavity])
      cylinder(10, r = 10, center = true, $fn = Sfn);
    }
  }
}

module Base()
{
  //convexity, resting on top of the main base cylinder
  resize([base_width, base_height, base_convexity])sphere(r = 10, center = true, $fn = Sfn);
  //main cylinder of the base
  translate([0, 0, -base_thickness / 4])
  {
    resize([base_width, base_height, 0])cylinder(base_thickness / 2, r = 10, center = true, $fn = Sfn);
  }
}

module Hook()
{
  cutaway = 0.9 * more_cutaway * base_height / 2;

  difference() {
    //sphere above base
    resize([base_width, base_height, hook_distance])sphere(r = 10, center = true, $fn = Sfn);

    //cut away the -z half with a cube
    translate([0, 0, -hook_distance / 2])
    {
      cube([base_width + 1, base_height + 1, hook_distance], center = true);
    }

    //cut away the +y half with a cube
    translate([0, base_height / 2, hook_distance / 2])
    {
      cube([base_width + 1, base_height, hook_distance], center = true);
    }

    //cut away hook in -y direction inside
    translate([0, 0, -point_size])
    {
      rotate ([0, 90, 0])
      resize([hook_distance, base_height / 2 + cutaway, base_width])sphere (hook_distance, base_width, center = true, $fn = Sfn);
    }

    //cutaway hook in -x direction
    translate([-base_width / 2 - point_size, 0, hook_distance / 2])
    { resize([base_width, base_height + cutaway, hook_distance])sphere(r = 10, center = true, $fn = Sfn);
    }

    //cutaway hook in +x direction
    translate([base_width / 2 + point_size, 0, hook_distance / 2])
    { resize([base_width, base_height + cutaway, hook_distance])sphere(r = 10, center = true, $fn = Sfn);
    }
  }
}

module Hole()
{
  if (fixing_hole > 0)
  {
    translate([0, base_height / 5, 1.5])
    {
      cylinder(base_thickness * 2, d = fixing_hole, center = true, $fn = Sfn);
      cylinder(h = fixing_hole, d1 = fixing_hole, d2 = fixing_hole * 2, center = true, $fn = Sfn);
    }
  }
}

difference()
{
  Base();
  Hole();
  Cavity();
}
Hook();
