extends Node3D
class_name PlacementController

## Owns the "ghost highlight" ring shown when a card is selected, hover
## feedback, and click-to-place. Raycasts against a math ground plane
## (not physics) so no collision shapes are needed on the tiles/markers.

@export var camera_path: NodePath
@export var ground_plane_y: float = 0.0
@export var tile_container_path: NodePath

var camera: Camera3D
var tile_container: Node3D
var marker_pool: Dictionary = {}   # Vector2i -> MeshInstance3D
var hovered_cell := Vector2i(999999, 999999)

const VALID_COLOR := Color(0.2, 0.9, 1.0, 0.5)
const HOVER_COLOR := Color(0.3, 1.0, 0.4, 0.85)

func _ready() -> void:
	camera = get_node(camera_path)
	tile_container = get_node(tile_container_path)
	CardManager.card_selected.connect(_on_card_selected)
	CardManager.card_deselected.connect(_clear_highlights)

func _on_card_selected(_card: CardData) -> void:
	_clear_highlights()
	for cell in HexGridManager.get_valid_placement_cells():
		var marker := _make_marker()
		add_child(marker)
		var pos := HexMath.axial_to_world(cell.x, cell.y)
		marker.position = Vector3(pos.x, 0.02, pos.z)
		marker_pool[cell] = marker

func _make_marker() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = HexMeshBuilder.build(HexMath.HEX_SIZE * 0.9, 0.05)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = VALID_COLOR
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mi.material_override = mat
	return mi

func _unhandled_input(event: InputEvent) -> void:
	if CardManager.selected_card == null:
		return
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			CardManager.deselect()

func _update_hover(mouse_pos: Vector2) -> void:
	var cell := _raycast_to_cell(mouse_pos)
	if cell == hovered_cell:
		return
	if marker_pool.has(hovered_cell):
		_set_marker_color(marker_pool[hovered_cell], VALID_COLOR)
	hovered_cell = cell
	if marker_pool.has(hovered_cell):
		_set_marker_color(marker_pool[hovered_cell], HOVER_COLOR)

func _try_place() -> void:
	if not marker_pool.has(hovered_cell):
		return
	var card := CardManager.selected_card
	if card == null or not ResourceManager.can_afford(card.resource_cost):
		return
	var tile := card.tile_scene.instantiate()
	if tile is TileBase:
		(tile as TileBase).model_path = card.model_path
		tile.scale = Vector3.ONE
	tile_container.add_child(tile)
	HexGridManager.place_tile(hovered_cell, tile)
	ResourceManager.spend(card.resource_cost)
	CardManager.spend_selected_card()
	_clear_highlights()

func _raycast_to_cell(mouse_pos: Vector2) -> Vector2i:
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	if absf(dir.y) < 0.0001:
		return Vector2i(999999, 999999)
	var t := (ground_plane_y - from.y) / dir.y
	if t < 0.0:
		return Vector2i(999999, 999999)
	var hit := from + dir * t
	return HexMath.world_to_axial(hit)

func _set_marker_color(marker: MeshInstance3D, color: Color) -> void:
	var mat := marker.material_override as StandardMaterial3D
	mat.albedo_color = color

func _clear_highlights() -> void:
	for m in marker_pool.values():
		m.queue_free()
	marker_pool.clear()
	hovered_cell = Vector2i(999999, 999999)
