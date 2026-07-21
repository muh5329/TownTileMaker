extends Node

signal hand_changed
signal card_selected(card: CardData)
signal card_deselected

@export var hand_size := 5

var master_deck: Array[CardData] = []
var deck: Array[CardData] = []
var hand: Array[CardData] = []
var selected_card: CardData = null

const TILE_SCENES: Dictionary = {
	"lumber_camp": preload("res://scenes/tiles/tile_lumber_camp.tscn"),
	"quarry": preload("res://scenes/tiles/tile_quarry.tscn"),
	"farm": preload("res://scenes/tiles/tile_farm.tscn"),
	"wall": preload("res://scenes/tiles/tile_wall.tscn"),
	"turret": preload("res://scenes/tiles/tile_turret.tscn"),
}

const MODEL_PATHS: Dictionary = {
	"lumber_camp": "res://assets/building_lumbermill_blue.fbx",
	"quarry": "res://assets/building_mine_blue.fbx",
	"farm": "res://assets/building_windmill_blue.fbx",
	"wall": "res://assets/building_tower_base_blue.fbx",
	"turret": "res://assets/building_tower_catapult_blue.fbx",
}

const CARD_DEFINITIONS: Array[Dictionary] = [
	{
		"id": "lumber_camp",
		"display_name": "Lumber Camp",
		"description": "Produces wood every tick.",
		"card_type": "Resource",
		"resource_cost": {"stone": 5},
		"strength_value": 0,
		"resource_yield": {"wood": 3},
	},
	{
		"id": "quarry",
		"display_name": "Quarry",
		"description": "Produces stone every tick.",
		"card_type": "Resource",
		"resource_cost": {"wood": 5},
		"strength_value": 0,
		"resource_yield": {"stone": 2},
	},
	{
		"id": "farm",
		"display_name": "Farm",
		"description": "Produces food every tick.",
		"card_type": "Resource",
		"resource_cost": {"wood": 5, "stone": 3},
		"strength_value": 0,
		"resource_yield": {"food": 3},
	},
	{
		"id": "wall",
		"display_name": "Wall",
		"description": "Adds base Strength. No production.",
		"card_type": "Wall",
		"resource_cost": {"wood": 8, "stone": 8},
		"strength_value": 3,
		"resource_yield": {},
	},
	{
		"id": "turret",
		"display_name": "Turret",
		"description": "Strong Strength contribution. No production.",
		"card_type": "Turret",
		"resource_cost": {"wood": 10, "stone": 15, "food": 5},
		"strength_value": 6,
		"resource_yield": {},
	},
]

func _ready() -> void:
	master_deck = []
	for definition in CARD_DEFINITIONS:
		master_deck.append(_build_card(definition))
	_reshuffle_deck()
	draw_to_full_hand()

func _build_card(definition: Dictionary) -> CardData:
	var card := CardData.new()
	card.id = StringName(definition["id"])
	card.display_name = String(definition["display_name"])
	card.description = String(definition["description"])
	card.card_type = String(definition["card_type"])
	card.tile_scene = TILE_SCENES[String(definition["id"])]
	card.model_path = String(MODEL_PATHS[String(definition["id"])])
	card.resource_cost = Dictionary(definition["resource_cost"])
	card.strength_value = int(definition["strength_value"])
	card.resource_yield = Dictionary(definition["resource_yield"])
	return card

func _reshuffle_deck() -> void:
	deck = master_deck.duplicate()
	deck.shuffle()

func draw_to_full_hand() -> void:
	while hand.size() < hand_size:
		if deck.is_empty():
			_reshuffle_deck()
		hand.append(deck.pop_front())
	hand_changed.emit()

func select_card(card: CardData) -> void:
	if selected_card == card:
		deselect()
		return
	selected_card = card
	card_selected.emit(card)

func deselect() -> void:
	if selected_card == null:
		return
	selected_card = null
	card_deselected.emit()

func spend_selected_card() -> void:
	hand.erase(selected_card)
	selected_card = null
	card_deselected.emit()
	hand_changed.emit()
	draw_to_full_hand()
