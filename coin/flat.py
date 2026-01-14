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
from mathutils import Vector, Euler, Matrix
import bmesh

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
        'samples': 512,          # resolution for relief map
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
        elif argv[i] == '--samples' and i + 1 < len(argv):
            args['samples'] = int(argv[i + 1])
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

def create_relief_from_projection(obj, coin_diameter, relief_depth, rotation):
    """Create bas-relief by projecting vertices along view direction and cutting off the back"""
    
    # Apply rotation to get desired view
    obj.rotation_euler = Euler((
        math.radians(rotation['x']),
        math.radians(rotation['y']),
        math.radians(rotation['z'])
    ), 'XYZ')
    
    # Apply all transformations
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    # Get mesh data
    mesh = obj.data
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.verts.ensure_lookup_table()
    
    # Calculate bounds in XY plane (front view)
    verts_world = [obj.matrix_world @ v.co for v in bm.verts]
    
    min_x = min(v.x for v in verts_world)
    max_x = max(v.x for v in verts_world)
    min_y = min(v.y for v in verts_world)
    max_y = max(v.y for v in verts_world)
    min_z = min(v.z for v in verts_world)
    max_z = max(v.z for v in verts_world)
    
    width = max_x - min_x
    height = max_y - min_y
    depth = max_z - min_z
    
    # Scale to fit coin diameter
    max_dimension = max(width, height)
    if max_dimension > 0:
        scale = (coin_diameter * 0.85) / max_dimension
        obj.scale = (scale, scale, scale)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    
    # Recalculate after scaling
    bm.free()
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.verts.ensure_lookup_table()
    verts_world = [obj.matrix_world @ v.co for v in bm.verts]
    
    min_z = min(v.z for v in verts_world)
    max_z = max(v.z for v in verts_world)
    depth = max_z - min_z
    
    # Project all vertices: compress Z depth to relief_depth
    if depth > 0:
        for i, v in enumerate(bm.verts):
            world_co = obj.matrix_world @ v.co
            # Normalize Z to 0-1 range, then scale to relief_depth
            normalized_z = (world_co.z - min_z) / depth
            new_z = normalized_z * relief_depth
            
            # Update vertex in local space
            local_co = obj.matrix_world.inverted() @ Vector((world_co.x, world_co.y, min_z + new_z))
            v.co = local_co
    
    # Update mesh
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    
    # Now cut off the back using a boolean with a plane
    # First, shift the relief so minimum Z is at 0
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=False)
    
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    min_z = min((obj.matrix_world @ v.co).z for v in bm.verts)
    bm.free()
    
    obj.location.z -= min_z
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
    
    # Create a cutting plane at Z=0 to slice off everything below
    bpy.ops.mesh.primitive_cube_add(size=coin_diameter * 2, location=(0, 0, -coin_diameter))
    cutter = bpy.context.active_object
    
    # Boolean difference to cut off the back
    bpy.context.view_layer.objects.active = obj
    modifier = obj.modifiers.new(name="Slice", type='BOOLEAN')
    modifier.operation = 'DIFFERENCE'
    modifier.object = cutter
    bpy.ops.object.modifier_apply(modifier="Slice")
    
    # Delete the cutter
    bpy.data.objects.remove(cutter)
    
    return obj

def create_coin_base(diameter, thickness=3.0):
    """Create cylindrical coin base"""
    bpy.ops.mesh.primitive_cylinder_add(
        radius=diameter / 2,
        depth=thickness,
        vertices=128,  # Smooth circle
        location=(0, 0, -thickness/2)  # Position so top surface is at Z=0
    )
    coin_base = bpy.context.active_object
    coin_base.name = "CoinBase"
    
    # Smooth the cylinder
    bpy.ops.object.shade_smooth()
    
    return coin_base

def combine_relief_with_base(base, relief):
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
        print("  --samples <int>        Relief map resolution (default: 512)")
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
    
    # Create bas-relief using projection method
    print("Creating bas-relief projection...")
    rotation = {
        'x': args['rotation_x'],
        'y': args['rotation_y'],
        'z': args['rotation_z']
    }
    create_relief_from_projection(relief_obj, args['coin_diameter'], args['relief_depth'], rotation)
    
    # Export as STL
    print(f"Exporting to {args['output']}...")
    bpy.ops.object.select_all(action='DESELECT')
    relief_obj.select_set(True)
    bpy.ops.wm.stl_export(filepath=args['output'], export_selected_objects=True)
    
    print("Done!")

if __name__ == "__main__":
    main()