extends Node

signal resources_changed(resources: Dictionary)
signal strength_changed(total: int)

var resources: Dictionary = {"wood": 20, "stone": 15, "food": 10}
var total_strength: int = 0

@export var tick_interval := 3.0
var _tick_accum := 0.0

func _process(delta: float) -> void:
	_tick_accum += delta
	if _tick_accum >= tick_interval:
		_tick_accum -= tick_interval
		_run_production_tick()

func can_afford(cost: Dictionary) -> bool:
	for k in cost:
		if resources.get(k, 0) < cost[k]:
			return false
	return true

func spend(cost: Dictionary) -> void:
	for k in cost:
		resources[k] = resources.get(k, 0) - cost[k]
	resources_changed.emit(resources)

func add(yield_dict: Dictionary) -> void:
	for k in yield_dict:
		resources[k] = resources.get(k, 0) + yield_dict[k]
	resources_changed.emit(resources)

func recalc_strength() -> void:
	var total := 0
	for tile in HexGridManager.placed_tiles.values():
		if "strength_value" in tile:
			total += tile.strength_value
	total_strength = total
	strength_changed.emit(total_strength)

func _run_production_tick() -> void:
	var totals := {}
	for tile in HexGridManager.placed_tiles.values():
		if "resource_yield" in tile:
			for k in tile.resource_yield:
				totals[k] = totals.get(k, 0) + tile.resource_yield[k]
	if totals.size() > 0:
		add(totals)
