extends Node

## Authoritative record of what's placed where on the hex grid.

var placed_tiles: Dictionary = {}   # Vector2i -> Node3D (TileBase)

func is_occupied(cell: Vector2i) -> bool:
	return placed_tiles.has(cell)

## Returns every empty hex adjacent to at least one already-placed tile.
func get_valid_placement_cells() -> Array[Vector2i]:
	var valid := {}
	for cell in placed_tiles.keys():
		for n in HexMath.neighbors(cell):
			if not is_occupied(n):
				valid[n] = true
	var out: Array[Vector2i] = []
	for c in valid.keys():
		out.append(c)
	return out

func place_tile(cell: Vector2i, tile_node: Node3D) -> void:
	placed_tiles[cell] = tile_node
	tile_node.position = HexMath.axial_to_world(cell.x, cell.y)
	if "grid_cell" in tile_node:
		tile_node.grid_cell = cell
	ResourceManager.recalc_strength()
