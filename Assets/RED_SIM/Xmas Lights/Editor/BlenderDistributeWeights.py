import bpy

# TO USE ON ACTIVE MESH: Copy and paste the whole file into the blender Python Console

# ensure we are in edit mode
bpy.ops.object.mode_set(mode="EDIT")

# configurable parameters
src_group = "RootBone"
dst_group = "EndBone"
LIGHTS_PER_METER = 24
STRAND_LENGTH = 2
STRAND_CENTER = 0

obj = bpy.context.edit_object
src_group_index = obj.vertex_groups[src_group].index
dst_group_index = obj.vertex_groups[dst_group].index

mesh = obj.data

def compute_weight(pos):
    idx = floor((abs(pos[0])) * float(LIGHTS_PER_METER))
    wgt = (idx + 0.0 + float(LIGHTS_PER_METER * STRAND_CENTER / 2)) / float(LIGHTS_PER_METER * STRAND_LENGTH)

    # Uncomment either of these to test your weight painting:
    # return 0.5 if (idx % 2) == 0 else 0.9
    # return 0.1 if int(wgt * 77) % 2 == 0 else 0.9
    return wgt

# Saving vertex indices only, instead of vertex objects in this list
# Copy v.groups.group, do not reference v.groups (unstable)
sel_verts_ig = [[v.index, [g.group for g in v.groups], compute_weight(v.co)] for v in mesh.vertices if v.select]

# no more SEGFAULT in this line
bpy.ops.object.mode_set(mode="OBJECT")

print("Working")

for ig in sel_verts_ig:
    i = ig[0]
    w = ig[2]
    obj.vertex_groups[dst_group].add([i], w, 'REPLACE')
    obj.vertex_groups[src_group].add([i], 1.0 - w, 'REPLACE')

bpy.ops.object.mode_set(mode="WEIGHT_PAINT")
print("Finished")
#