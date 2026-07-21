extends Node3D
class_name TileBase

## Shared contract every placed hex tile follows. HexGridManager and
## ResourceManager only care about strength_value / resource_yield / grid_cell,
## so any tile type — no matter how it looks — plugs into the same systems.

@export var strength_value: int = 0
@export var resource_yield: Dictionary = {}
@export var tile_color: Color = Color(0.6, 0.6, 0.6)
@export var model_path: String = ""
@export var model_scale: Vector3 = Vector3.ONE

var grid_cell: Vector2i

func _ready() -> void:
	if not model_path.is_empty():
		_load_model(model_path)
		return

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = HexMeshBuilder.build(HexMath.HEX_SIZE * 0.95, 0.3)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tile_color
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func _load_model(path: String) -> void:
	var loaded_resource := load(path)
	if loaded_resource is PackedScene:
		var model := (loaded_resource as PackedScene).instantiate()
		if model is Node3D:
			(model as Node3D).scale = model_scale
			add_child(model)
		return

	if loaded_resource is Mesh:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = loaded_resource as Mesh
		mesh_instance.scale = model_scale
		add_child(mesh_instance)
