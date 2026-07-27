extends CanvasLayer

## Builds the HUD in code (stats bar top, hand bottom-center) so no
## hand-authored anchor math is needed in the scene file. Replace with
## real .tscn UI whenever you want to art-direct it in the editor.

func _ready() -> void:
	var stats: Control = load("res://ui/hud/stats_bar.gd").new()
	stats.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	stats.offset_top = 16
	stats.offset_left = 24
	stats.offset_right = -24
	add_child(stats)

	var developer_toggle := CheckBox.new()
	developer_toggle.text = "Developer Mode"
	developer_toggle.button_pressed = ResourceManager.developer_mode
	developer_toggle.toggled.connect(func(is_on: bool): ResourceManager.developer_mode = is_on)
	developer_toggle.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	developer_toggle.offset_left = 24
	developer_toggle.offset_top = 72
	add_child(developer_toggle)

	var recenter_button := Button.new()
	recenter_button.text = "🏠"
	recenter_button.custom_minimum_size = Vector2(60, 36)
	recenter_button.anchor_left = 0.5
	recenter_button.anchor_right = 0.5
	recenter_button.anchor_top = 0.0
	recenter_button.anchor_bottom = 0.0
	recenter_button.offset_left = -20
	recenter_button.offset_right = 20
	recenter_button.offset_top = 16
	recenter_button.offset_bottom = 52
	recenter_button.pressed.connect(_on_recenter_camera_pressed)
	add_child(recenter_button)

	var hand: Control = load("res://ui/hud/hand_ui.gd").new()
	hand.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hand.offset_left = 24
	hand.offset_right = -24
	hand.offset_top = 0
	hand.offset_bottom = 0
	hand.custom_minimum_size = Vector2(500, 100)
	add_child(hand)

func _on_recenter_camera_pressed() -> void:
	var camera_rig := get_parent().get_node_or_null("CameraRig")
	if camera_rig != null and camera_rig.has_method("reset_to_start"):
		camera_rig.call("reset_to_start")
