// Parameters
key_slot_width = 7; // Width of the key slot
key_slot_depth = 3; // Depth of the key slot
gripper_width = 25; // Width of the gripper
gripper_height = 30; // Height of the gripper
gripper_depth = 15; // Depth of the gripper

// Gripper
module gripper() {
    difference() {
        cube([gripper_width, gripper_depth, gripper_height], center = true);
        translate([0, 0, -gripper_height/2])
            cube([gripper_width - 2, gripper_depth - 2, gripper_height + 2], center = true);
    }
}

// Key slot
module key_slot() {
    difference() {
        cube([key_slot_width, gripper_depth, key_slot_depth], center = true);
        translate([0, 0, -key_slot_depth/2])
            cube([key_slot_width, gripper_depth - 2, key_slot_depth + 2], center = true);
    }
}

// Assembly
module key_gripper() {
    union() {
        gripper();
        translate([0, 0, -gripper_height/2 - key_slot_depth/2])
            key_slot();
    }
}

key_gripper();

