extends Node3D
class_name TileBase

## Shared contract every placed hex tile follows. HexGridManager and
## ResourceManager only care about strength_value / resource_yield / grid_cell,
## so any tile type — no matter how it looks — plugs into the same systems.

@export var strength_value: int = 0
@export var resource_yield: Dictionary = {}
@export var tile_color: Color = Color(0.6, 0.6, 0.6)

var grid_cell: Vector2i

func _ready() -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = HexMeshBuilder.build(HexMath.HEX_SIZE * 0.95, 0.3)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tile_color
	mesh_instance.material_override = mat
	add_child(mesh_instance)
