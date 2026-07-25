extends Node

signal hand_changed
signal card_selected(card: CardData)
signal card_deselected

@export var hand_size := 5
@export var max_deck_size := 52

var master_deck: Array[CardData] = []
var deck: Array[CardData] = []
var hand: Array[CardData] = []
var selected_card: CardData = null

var tile_catalog

const TILE_SCENES: Dictionary = {
	"lumber_camp": preload("res://scenes/tiles/tile_lumber_camp.tscn"),
	"quarry": preload("res://scenes/tiles/tile_quarry.tscn"),
	"farm": preload("res://scenes/tiles/tile_farm.tscn"),
	"wall": preload("res://scenes/tiles/tile_wall.tscn"),
	"turret": preload("res://scenes/tiles/tile_turret.tscn"),
}

func _ready() -> void:
	tile_catalog = preload("res://data/tile_catalog.gd").new()
	master_deck = []
	for tile_id in tile_catalog.get_tile_ids():
		master_deck.append(_build_card(tile_catalog.get_tile(tile_id)))
	if master_deck.size() > max_deck_size:
		master_deck = master_deck.slice(0, max_deck_size)
	_reshuffle_deck()
	draw_to_full_hand()

func build_card(definition: Dictionary) -> CardData:
	var card := CardData.new()
	var tile_id := String(definition["id"])
	card.id = StringName(tile_id)
	card.display_name = String(definition["display_name"])
	card.description = String(definition["description"])
	card.card_type = String(definition["type"])
	card.tile_scene = TILE_SCENES.get(tile_id, preload("res://scenes/tiles/tile_core.tscn"))
	card.model_path = String(definition["model_path"])
	card.resource_cost = Dictionary(definition.get("resource_cost", {}))
	card.strength_value = int(definition["strength_value"])
	card.resource_yield = Dictionary(definition.get("resource_yield", {}))
	return card

func _build_card(definition: Dictionary) -> CardData:
	return build_card(definition)

func _reshuffle_deck() -> void:
	deck = master_deck.duplicate()
	deck.shuffle()

func get_remaining_deck_count() -> int:
	return deck.size()

func add_card_to_deck(card: CardData) -> bool:
	if master_deck.size() >= max_deck_size:
		return false
	master_deck.append(card)
	if deck.is_empty() and hand.is_empty():
		_reshuffle_deck()
	else:
		deck.append(card)
	return true

func draw_to_full_hand() -> void:
	while hand.size() < hand_size:
		if deck.is_empty():
			_reshuffle_deck()
		hand.append(deck.pop_front())
	hand_changed.emit()

func shuffle_hand_with_deck() -> void:
	# Combine current hand back into the deck, shuffle everything, and draw a new hand
	if hand.size() == 0:
		# nothing to shuffle
		return
	# Move hand cards back into deck
	for c in hand:
		deck.append(c)
	hand.clear()
	selected_card = null
	# Shuffle the combined deck
	deck.shuffle()
	# Refill hand
	draw_to_full_hand()

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
