extends Resource
class_name CardData

@export var id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var card_type: String = "Resource"   # "Resource", "Wall", "Turret", "Housing", "Special"
@export var tile_scene: PackedScene
@export var model_path: String = ""
@export var resource_cost: Dictionary = {}   # {"wood": 10, "stone": 5}
@export var strength_value: int = 0
@export var resource_yield: Dictionary = {}  # generated per production tick once placed
@export var type: String
