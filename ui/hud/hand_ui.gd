extends Control
## Fanned Hearthstone-style hand + deck display.
## Cards are manually positioned/rotated (not laid out by a container) so they can
## overlap in an arc, and animate on hover/select/draw.

# --- Tunables -------------------------------------------------------------
@export var card_size := Vector2(160, 220)
@export var deck_size := Vector2(140, 220)
@export var max_fan_angle_deg := 26.0     # total spread across the whole hand
@export var max_card_spacing := 120.0     # spacing between card centers when hand is small
@export var arc_drop := 46.0              # how far outer cards drop below center (parabola)
@export var hover_lift := 46.0
@export var select_lift := 78.0
@export var hover_scale := 1.12
@export var select_scale := 1.16
@export var reflow_time := 0.22           # existing cards sliding to a new fan slot
@export var draw_time := 0.4              # new card flying in from the deck
@export var draw_stagger := 0.06          # delay between multiple cards drawn at once

var _card_nodes: Dictionary = {}     # CardData -> Button (current frame)
var _previous_hand: Array = []       # CardData list from before this refresh
var _deck_button: Button
var _deck_anchor_pos: Vector2

func _ready() -> void:
	CardManager.hand_changed.connect(_refresh)
	CardManager.card_selected.connect(func(_c): _refresh())
	CardManager.card_deselected.connect(_refresh)
	resized.connect(_refresh)
	_refresh()

func _refresh() -> void:
	# Snapshot where existing cards currently are, so ones that persist can
	# slide smoothly to their new fan position instead of popping.
	var old_positions: Dictionary = {}
	for card in _card_nodes:
		old_positions[card] = _card_nodes[card].position

	for child in get_children():
		child.queue_free()
	_card_nodes.clear()

	_deck_button = _build_deck_slot()
	add_child(_deck_button)
	_place_deck()
	_deck_anchor_pos = _deck_button.position + deck_size / 2.0 - card_size / 2.0

	var hand := CardManager.hand
	var total := hand.size()
	var draw_index := 0  # for staggering multiple simultaneous draws
	for i in total:
		var card: CardData = hand[i]
		var button := _build_card_slot(card)
		add_child(button)
		_card_nodes[card] = button

		var layout := _compute_layout(i, total)
		var is_selected := card == CardManager.selected_card
		button.pivot_offset = Vector2(card_size.x / 2.0, card_size.y)

		if card in old_positions:
			# Existing card: slide from its previous spot to the new fan slot.
			button.position = old_positions[card]
			button.rotation_degrees = 0.0
			button.scale = Vector2.ONE
			_settle(button, layout, is_selected, reflow_time, 0.0)
		else:
			# Newly drawn card: fly in from the deck.
			button.position = _deck_anchor_pos
			button.rotation_degrees = 0.0
			button.scale = Vector2(0.6, 0.6)
			button.modulate.a = 0.0
			_settle(button, layout, is_selected, draw_time, draw_index * draw_stagger)
			draw_index += 1

	_previous_hand = hand.duplicate()

# --- Layout -------------------------------------------------------------

func _place_deck() -> void:
	_deck_button.pivot_offset = deck_size / 2.0
	_deck_button.position = Vector2(40, size.y - deck_size.y - 20)

func _hand_origin_x() -> float:
	return 220.0 + (size.x - 220.0) / 2.0

func _compute_layout(index: int, total: int) -> Dictionary:
	var t := 0.0
	if total > 1:
		t = (float(index) - float(total - 1) / 2.0) / (float(total - 1) / 2.0)

	var spacing: float = min(max_card_spacing, (size.x - 260.0) / max(total, 1))
	var x_offset := t * spacing * (float(total - 1) / 2.0) if total > 1 else 0.0
	var y_offset := arc_drop * t * t
	var angle := t * (max_fan_angle_deg / 2.0)

	var base_pos := Vector2(
		_hand_origin_x() + x_offset - card_size.x / 2.0,
		size.y - card_size.y - 30.0 - (arc_drop - y_offset)
	)
	return {"pos": base_pos, "rot": angle}

# --- Building nodes ----------------------------------------------------------

func _build_deck_slot() -> Button:
	var button := _make_button(
		"Deck\n%s/52" % CardManager.get_remaining_deck_count(),
		deck_size,
		false
	)
	button.pressed.connect(_on_deck_pressed)
	return button

func _build_card_slot(card: CardData) -> Button:
	var is_selected := CardManager.selected_card == card
	var button := _make_button(
		"%s\n\n%s\nSTR %d" % [card.display_name, _format_cost(card.resource_cost), card.strength_value],
		card_size,
		is_selected
	)
	button.pressed.connect(func(): _on_card_pressed(card))
	button.mouse_entered.connect(func(): _on_card_hover(button, card, true))
	button.mouse_exited.connect(func(): _on_card_hover(button, card, false))
	return button

func _make_button(text: String, sz: Vector2, is_selected: bool) -> Button:
	var button := Button.new()
	button.flat = false
	button.toggle_mode = true
	button.button_pressed = is_selected
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size = sz
	button.size = sz
	button.text = text
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("normal", _make_style(is_selected))
	button.add_theme_stylebox_override("hover", _make_style(true))
	button.add_theme_stylebox_override("pressed", _make_style(true))
	button.add_theme_stylebox_override("focus", _make_style(is_selected))
	return button

func _make_style(is_selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.16, 0.21, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.border_color = Color(1, 0.85, 0.3) if is_selected else Color(1, 1, 1, 0.35)
	if is_selected:
		style.shadow_color = Color(1, 0.85, 0.3, 0.5)
		style.shadow_size = 10
	return style

func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for k in cost:
		parts.append("%s:%d" % [String(k), cost[k]])
	return ", ".join(parts)

# --- Animation ---------------------------------------------------------------

## Animates a button from its current transform to its resting fan layout,
## then stores that resting state as meta so hover/select can reference it.
func _settle(button: Button, layout: Dictionary, is_selected: bool, duration: float, delay: float) -> void:
	var rest_pos: Vector2 = layout["pos"]
	var rest_rot: float = layout["rot"]

	button.set_meta("base_pos", rest_pos)
	button.set_meta("base_rot", rest_rot)

	var final_pos := rest_pos - Vector2(0, select_lift) if is_selected else rest_pos
	var final_rot := 0.0 if is_selected else rest_rot
	var final_scale := select_scale if is_selected else 1.0
	button.z_index = 500 if is_selected else button.get_index()

	var tween := create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position", final_pos, duration)
	tween.tween_property(button, "rotation_degrees", final_rot, duration)
	tween.tween_property(button, "scale", Vector2(final_scale, final_scale), duration)
	tween.tween_property(button, "modulate:a", 1.0, min(duration, 0.2))

func _animate_to(button: Button, target_pos: Vector2, target_rot: float, target_scale: float, z: int) -> void:
	button.z_index = z
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position", target_pos, 0.18)
	tween.tween_property(button, "rotation_degrees", target_rot, 0.18)
	tween.tween_property(button, "scale", Vector2(target_scale, target_scale), 0.18)

func _on_card_hover(button: Button, card: CardData, entering: bool) -> void:
	if CardManager.selected_card == card:
		return  # selected card stays raised regardless of hover
	var base_pos: Vector2 = button.get_meta("base_pos")
	var base_rot: float = button.get_meta("base_rot")
	if entering:
		_animate_to(button, base_pos - Vector2(0, hover_lift), 0.0, hover_scale, 300)
	else:
		_animate_to(button, base_pos, base_rot, 1.0, button.get_index())

# --- Handlers ------------------------------------------------------------------

func _on_card_pressed(card: CardData) -> void:
	# CardManager.select_card() already toggles off if you pass the currently
	# selected card, so we don't need to special-case that here.
	CardManager.select_card(card)

func _on_deck_pressed() -> void:
	CardManager.shuffle_hand_with_deck()
