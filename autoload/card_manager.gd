extends Node

signal hand_changed
signal card_selected(card: CardData)
signal card_deselected

@export var hand_size := 5

var master_deck: Array[CardData] = []
var deck: Array[CardData] = []
var hand: Array[CardData] = []
var selected_card: CardData = null

func _ready() -> void:
	master_deck = [
		preload("res://data/cards/card_lumber_camp.tres"),
		preload("res://data/cards/card_quarry.tres"),
		preload("res://data/cards/card_farm.tres"),
		preload("res://data/cards/card_wall.tres"),
		preload("res://data/cards/card_turret.tres"),
	]
	_reshuffle_deck()
	draw_to_full_hand()

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
