extends HBoxContainer

## Dynamically rebuilds card buttons from CardManager.hand. No separate
## CardButton scene needed for the starter — swap this for a proper
## PackedScene-per-card once you're ready to art it up.

func _ready() -> void:
	add_theme_constant_override("separation", 12)
	CardManager.hand_changed.connect(_refresh)
	CardManager.card_selected.connect(func(_c): _refresh())
	CardManager.card_deselected.connect(_refresh)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	for card in CardManager.hand:
		add_child(_build_card_button(card))

func _build_card_button(card: CardData) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(130, 70)
	btn.text = "%s\n%s\nSTR %d" % [card.display_name, _format_cost(card.resource_cost), card.strength_value]
	btn.toggle_mode = true
	btn.button_pressed = (CardManager.selected_card == card)
	btn.pressed.connect(func(): CardManager.select_card(card))
	return btn

func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for k in cost:
		parts.append("%s:%d" % [String(k), cost[k]])
	return ", ".join(parts)
