extends HBoxContainer

var resource_label: Label
var strength_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 24)

	resource_label = Label.new()
	resource_label.add_theme_font_size_override("font_size", 18)
	add_child(resource_label)

	strength_label = Label.new()
	strength_label.add_theme_font_size_override("font_size", 18)
	add_child(strength_label)

	ResourceManager.resources_changed.connect(_on_resources_changed)
	ResourceManager.strength_changed.connect(_on_strength_changed)
	_on_resources_changed(ResourceManager.resources)
	_on_strength_changed(ResourceManager.total_strength)

func _on_resources_changed(resources: Dictionary) -> void:
	var parts: Array[String] = []
	for k in resources:
		parts.append("%s: %d" % [String(k).capitalize(), resources[k]])
	resource_label.text = "   ".join(parts)

func _on_strength_changed(total: int) -> void:
	strength_label.text = "Strength: %d" % total
