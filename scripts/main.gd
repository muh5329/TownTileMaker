extends Node3D

const CoreTileScene := preload("res://scenes/tiles/tile_core.tscn")

func _ready() -> void:
	var core := CoreTileScene.instantiate()
	$TileContainer.add_child(core)
	HexGridManager.place_tile(Vector2i.ZERO, core)
