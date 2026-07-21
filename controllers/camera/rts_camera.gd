extends Node3D
class_name RTSCamera

## Classic RTS camera rig: WASD + edge-scroll pan, Q/E rotate, wheel zoom.
## No custom Input Map actions required — reads raw keys/wheel directly,
## so this works the instant you open the project.

@export var pan_speed := 12.0
@export var edge_pan_margin := 14.0
@export var edge_pan_enabled := true
@export var drag_pan_speed := 0.015
@export var rotate_speed_deg := 90.0
@export var zoom_speed := 2.0
@export var min_zoom := 6.0
@export var max_zoom := 30.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var drag_pan_active := false

func _process(delta: float) -> void:
	_handle_pan(delta)
	_handle_rotate(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			drag_pan_active = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom(-zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom(zoom_speed)
	elif event is InputEventMouseMotion and drag_pan_active:
		var drag_dir := Vector3(-event.relative.x, 0.0, -event.relative.y)
		translate(drag_dir.rotated(Vector3.UP, rotation.y) * drag_pan_speed)

func _zoom(amount: float) -> void:
	spring_arm.spring_length = clamp(spring_arm.spring_length + amount, min_zoom, max_zoom)

func _handle_pan(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): dir.z -= 1
	if Input.is_key_pressed(KEY_S): dir.z += 1
	if Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_D): dir.x += 1

	if edge_pan_enabled:
		var mouse := get_viewport().get_mouse_position()
		var vp := get_viewport().get_visible_rect().size
		if mouse.x <= edge_pan_margin: dir.x -= 1
		elif mouse.x >= vp.x - edge_pan_margin: dir.x += 1
		if mouse.y <= edge_pan_margin: dir.z -= 1
		elif mouse.y >= vp.y - edge_pan_margin: dir.z += 1

	if dir != Vector3.ZERO:
		translate(dir.normalized().rotated(Vector3.UP, rotation.y) * pan_speed * delta)

func _handle_rotate(delta: float) -> void:
	var input := 0.0
	if Input.is_key_pressed(KEY_Q): input -= 1
	if Input.is_key_pressed(KEY_E): input += 1
	if input != 0.0:
		rotate_y(deg_to_rad(rotate_speed_deg * delta * input))
