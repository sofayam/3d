#!/usr/bin/env python3
"""
Blender script to convert USDA file to bas-relief for coin printing.

Usage:
    blender --background --python coin_relief.py -- --input model.usda --output coin.stl

Arguments after '--' are passed to this script.
"""

import bpy
import sys
import math
from mathutils import Vector, Euler

def parse_args():
    """Parse command line arguments after '--'"""
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1:]
    else:
        argv = []
    
    # Simple argument parsing
    args = {
        'input': None,
        'output': 'coin_relief.stl',
        'coin_diameter': 40.0,  # mm
        'relief_depth': 2.0,     # mm
        'rotation_x': 0.0,       # degrees
        'rotation_y': 0.0,
        'rotation_z': 0.0,
    }
    
    i = 0
    while i < len(argv):
        if argv[i] == '--input' and i + 1 < len(argv):
            args['input'] = argv[i + 1]
            i += 2
        elif argv[i] == '--output' and i + 1 < len(argv):
            args['output'] = argv[i + 1]
            i += 2
        elif argv[i] == '--diameter' and i + 1 < len(argv):
            args['coin_diameter'] = float(argv[i + 1])
            i += 2
        elif argv[i] == '--depth' and i + 1 < len(argv):
            args['relief_depth'] = float(argv[i + 1])
            i += 2
        elif argv[i] == '--rotate-x' and i + 1 < len(argv):
            args['rotation_x'] = float(argv[i + 1])
            i += 2
        elif argv[i] == '--rotate-y' and i + 1 < len(argv):
            args['rotation_y'] = float(argv[i + 1])
            i += 2
        elif argv[i] == '--rotate-z' and i + 1 < len(argv):
            args['rotation_z'] = float(argv[i + 1])
            i += 2
        else:
            i += 1
    
    return args

def clear_scene():
    """Remove all objects from the scene"""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def import_usd(filepath):
    """Import USD/USDA file"""
    bpy.ops.wm.usd_import(filepath=filepath)
    return bpy.context.selected_objects

def create_bas_relief(obj, coin_diameter, relief_depth, rotation):
    """Convert object to bas-relief by projecting along Z axis"""
    
    # Apply rotation
    obj.rotation_euler = Euler((
        math.radians(rotation['x']),
        math.radians(rotation['y']),
        math.radians(rotation['z'])
    ), 'XYZ')
    bpy.context.view_layer.update()
    
    # Get object bounds
    bbox = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    min_z = min(v.z for v in bbox)
    max_z = max(v.z for v in bbox)
    z_range = max_z - min_z
    
    # Scale object to fit coin diameter (based on XY extents)
    max_xy = max(
        max(v.x for v in bbox) - min(v.x for v in bbox),
        max(v.y for v in bbox) - min(v.y for v in bbox)
    )
    
    if max_xy > 0:
        scale_factor = (coin_diameter * 0.8) / max_xy  # 80% of diameter for margin
        obj.scale = (scale_factor, scale_factor, scale_factor)
        bpy.context.view_layer.update()
    
    # Flatten to relief depth
    if z_range > 0:
        z_scale = relief_depth / z_range
        obj.scale.z *= z_scale
        bpy.context.view_layer.update()
    
    # Center the object
    bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
    obj.location = (0, 0, relief_depth / 2)
    
    return obj

def create_coin_base(diameter, thickness=3.0):
    """Create cylindrical coin base"""
    bpy.ops.mesh.primitive_cylinder_add(
        radius=diameter / 2,
        depth=thickness,
        location=(0, 0, 0)
    )
    coin_base = bpy.context.active_object
    coin_base.name = "CoinBase"
    
    # Smooth the cylinder
    bpy.ops.object.shade_smooth()
    
    return coin_base

def boolean_union(base, relief):
    """Combine relief with coin base using boolean union"""
    # Select base
    bpy.ops.object.select_all(action='DESELECT')
    base.select_set(True)
    bpy.context.view_layer.objects.active = base
    
    # Add boolean modifier
    modifier = base.modifiers.new(name="Boolean", type='BOOLEAN')
    modifier.operation = 'UNION'
    modifier.object = relief
    
    # Apply modifier
    bpy.ops.object.modifier_apply(modifier="Boolean")
    
    # Delete the relief object
    bpy.data.objects.remove(relief)
    
    return base

def main():
    args = parse_args()
    
    if not args['input']:
        print("Error: --input <file.usda> is required")
        print("\nUsage:")
        print("  blender --background --python coin_relief.py -- --input model.usda [options]")
        print("\nOptions:")
        print("  --output <file.stl>    Output file (default: coin_relief.stl)")
        print("  --diameter <mm>        Coin diameter (default: 40.0)")
        print("  --depth <mm>           Relief depth (default: 2.0)")
        print("  --rotate-x <degrees>   Rotation around X axis (default: 0)")
        print("  --rotate-y <degrees>   Rotation around Y axis (default: 0)")
        print("  --rotate-z <degrees>   Rotation around Z axis (default: 0)")
        sys.exit(1)
    
    print(f"Processing: {args['input']}")
    print(f"Coin diameter: {args['coin_diameter']}mm")
    print(f"Relief depth: {args['relief_depth']}mm")
    print(f"Rotation: X={args['rotation_x']}, Y={args['rotation_y']}, Z={args['rotation_z']}")
    
    # Clear default scene
    clear_scene()
    
    # Import USD file
    print("Importing USD file...")
    imported_objects = import_usd(args['input'])
    
    if not imported_objects:
        print("Error: No objects imported from USD file")
        sys.exit(1)
    
    # Join all imported objects (if more than one)
    bpy.ops.object.select_all(action='DESELECT')
    
    # Filter to only mesh objects
    mesh_objects = [obj for obj in imported_objects if obj.type == 'MESH']
    
    if not mesh_objects:
        print("Error: No mesh objects found in USD file")
        sys.exit(1)
    
    for obj in mesh_objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_objects[0]
    
    # Ensure we're in object mode
    if bpy.context.active_object and bpy.context.active_object.mode != 'OBJECT':
        bpy.ops.object.mode_set(mode='OBJECT')
    
    if len(mesh_objects) > 1:
        bpy.ops.object.join()
    
    relief_obj = bpy.context.active_object
    relief_obj.name = "Relief"
    
    # Create bas-relief
    print("Creating bas-relief...")
    rotation = {
        'x': args['rotation_x'],
        'y': args['rotation_y'],
        'z': args['rotation_z']
    }
    create_bas_relief(relief_obj, args['coin_diameter'], args['relief_depth'], rotation)
    
    # Create coin base
    print("Creating coin base...")
    coin_base = create_coin_base(args['coin_diameter'])
    
    # Combine relief with base
    print("Combining relief with coin base...")
    final_coin = boolean_union(coin_base, relief_obj)
    
    # Export as STL
    print(f"Exporting to {args['output']}...")
    bpy.ops.object.select_all(action='DESELECT')
    final_coin.select_set(True)
    bpy.ops.wm.stl_export(filepath=args['output'], export_selected_objects=True)
    
    print("Done!")

if __name__ == "__main__":
    main()