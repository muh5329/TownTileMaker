extends Control

var catalog
var content_container: ScrollContainer
var category_root: VBoxContainer
var current_cards: Array[CardData] = []

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(980, 620)
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	var panel := PanelContainer.new()
	panel.size = Vector2(980, 620)
	panel.custom_minimum_size = Vector2(980, 620)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(panel)

	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(wrapper)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	wrapper.add_child(header)

	var title := Label.new()
	title.text = "Card Shop"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func(): visible = false)
	close_btn.custom_minimum_size = Vector2(84, 0)
	header.add_child(close_btn)

	var hint := Label.new()
	hint.text = "Buy cards with your resources. Developer mode enables all cards."
	hint.modulate = Color(1, 1, 1, 0.8)
	wrapper.add_child(hint)

	content_container = ScrollContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.follow_focus = true
	content_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_container.add_theme_stylebox_override("panel", _make_scroll_panel_style())
	content_container.add_theme_constant_override("scrollbar_spacing", 8)
	content_container.add_theme_stylebox_override("scrollbar_background", _make_scrollbar_bg_style())
	content_container.add_theme_stylebox_override("scrollbar_focus", _make_scrollbar_handle_style())
	content_container.add_theme_stylebox_override("scrollbar_grabber", _make_scrollbar_handle_style())
	content_container.add_theme_stylebox_override("scrollbar_grabber_highlight", _make_scrollbar_handle_style())
	content_container.add_theme_stylebox_override("scrollbar_grabber_pressed", _make_scrollbar_handle_style())
	wrapper.add_child(content_container)

	category_root = VBoxContainer.new()
	category_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	category_root.add_theme_constant_override("separation", 16)
	content_container.add_child(category_root)

	catalog = preload("res://data/tile_catalog.gd").new()
	_refresh_shop()

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.14, 0.96)
	style.border_color = Color(0.8, 0.82, 0.9, 0.2)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 18
	return style

func _make_scroll_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.72)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	return style

func _make_scrollbar_bg_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18, 0.5)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style

func _make_scrollbar_handle_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.45, 0.58, 0.76, 0.85)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style

func _refresh_shop() -> void:
	for child in category_root.get_children():
		child.queue_free()

	var categories: Dictionary = {}
	for entry in catalog.get_all_tiles():
		var cat := String(entry.get("category", "misc"))
		if not categories.has(cat):
			categories[cat] = []
		categories[cat].append(entry)

	var keys: Array = categories.keys()
	keys.sort()

	for cat_name in keys:
		var section := VBoxContainer.new()
		section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		section.add_theme_constant_override("separation", 8)
		category_root.add_child(section)

		var section_title := Label.new()
		section_title.text = String(cat_name).capitalize()
		section_title.add_theme_font_size_override("font_size", 18)
		section.add_child(section_title)

		var cards_grid := GridContainer.new()
		cards_grid.columns = 3
		cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_grid.add_theme_constant_override("h_separation", 12)
		cards_grid.add_theme_constant_override("v_separation", 12)
		section.add_child(cards_grid)

		for entry in categories[cat_name]:
			cards_grid.add_child(_build_card_entry(entry))

func _build_card_entry(entry: Dictionary) -> Control:
	var card := CardManager.build_card(entry)
	current_cards.append(card)

	var card_panel := PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(280, 320)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_panel.add_child(wrapper)

	var name_label := Label.new()
	name_label.text = String(entry.get("display_name", card.display_name))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 15)
	wrapper.add_child(name_label)

	var preview_container := Control.new()
	preview_container.custom_minimum_size = Vector2(220, 160)
	preview_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	wrapper.add_child(preview_container)

	var preview := _make_model_preview(entry)
	if preview != null:
		preview_container.add_child(preview)
	else:
		var fallback := ColorRect.new()
		fallback.color = entry.get("card_background_color", Color(0.2, 0.2, 0.2))
		fallback.size = Vector2(220, 160)
		preview_container.add_child(fallback)

	var desc_label := Label.new()
	desc_label.text = String(entry.get("description", ""))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.custom_minimum_size = Vector2(0, 48)
	wrapper.add_child(desc_label)

	var bottom_row := HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	wrapper.add_child(bottom_row)

	var cost_label := Label.new()
	var cost_text := _format_cost(entry.get("resource_cost", {}))
	cost_label.text = cost_text if cost_text != "" else "Free"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_row.add_child(cost_label)

	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.pressed.connect(func(): _on_buy_pressed(card, buy_btn))
	buy_btn.custom_minimum_size = Vector2(70, 0)
	bottom_row.add_child(buy_btn)

	if not ResourceManager.developer_mode and not ResourceManager.can_afford(Dictionary(entry.get("resource_cost", {}))):
		buy_btn.disabled = true
		buy_btn.text = "Cant Afford"

	return card_panel

func _format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "Free"
	var parts: Array[String] = []
	for key in cost:
		parts.append("%s:%d" % [String(key), int(cost[key])])
	return ", ".join(parts)

func _make_model_preview(entry: Dictionary) -> Control:
	var path := String(entry.get("model_path", ""))
	if path.is_empty():
		return null

	var viewport := SubViewport.new()
	viewport.size = Vector2(220, 160)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.transparent_bg = true
	viewport.disable_3d = false
	viewport.use_hdr_2d = false

	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.2, 2.4)
	camera.rotation_degrees = Vector3(-20, 180, 0)
	camera.fov = 35
	viewport.add_child(camera)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	viewport.add_child(light)

	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env.ambient_light_color = Color(1, 1, 1, 1)
	env.ambient_light_energy = 0.9
	environment.environment = env
	viewport.add_child(environment)

	var model := _load_model(path)
	if model == null:
		viewport.free()
		return null
	viewport.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = entry.get("model_rotation", Vector3.ZERO)
	model.scale = entry.get("model_scale", Vector3.ONE)

	var container := Control.new()
	container.custom_minimum_size = Vector2(220, 160)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var texture_rect := TextureRect.new()
	texture_rect.texture = viewport.get_texture()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_rect.custom_minimum_size = Vector2(220, 160)
	container.add_child(texture_rect)

	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	return container

func _load_model(path: String) -> Node3D:
	var resource = load(path)
	if resource == null:
		return null
	if resource is PackedScene:
		var packed_scene := resource as PackedScene
		var scene = packed_scene.instantiate()
		if scene is Node3D:
			return scene as Node3D
	return null

func _on_buy_pressed(card: CardData, btn: Button) -> void:
	var cost := Dictionary(card.resource_cost)
	if not ResourceManager.developer_mode and not ResourceManager.can_afford(cost):
		return
	if not CardManager.add_card_to_deck(card):
		btn.text = "Full"
		btn.disabled = true
		return
	if not ResourceManager.developer_mode:
		ResourceManager.spend(cost)
	btn.text = "Bought"
	btn.disabled = true
