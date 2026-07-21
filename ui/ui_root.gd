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

	var hand: HBoxContainer = load("res://ui/hud/hand_ui.gd").new()
	hand.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hand.offset_left = 24
	hand.offset_right = -24
	hand.offset_top = -92
	hand.offset_bottom = -20
	hand.alignment = BoxContainer.ALIGNMENT_CENTER
	hand.custom_minimum_size = Vector2(600, 80)
	add_child(hand)
