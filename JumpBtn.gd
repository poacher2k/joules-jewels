extends Control

class_name JumpBtnJoystick

# If the joystick is receiving inputs.
var is_working := false

# The joystick output.
var output := Vector2.ZERO

# The color of the button when the joystick is in use.
export(Color) var _pressed_color := Color.gray

#VISIBILITY_ALWAYS = Always visible.
#VISIBILITY_TOUCHSCREEN_ONLY = Visible on touch screens only.
enum VisibilityMode {ALWAYS , TOUCHSCREEN_ONLY }

export(VisibilityMode) var visibility_mode := VisibilityMode.ALWAYS

onready var _background := $Handle
onready var _handle := $Handle
onready var _original_color : Color = _handle.self_modulate
onready var _original_position : Vector2 = _background.rect_position

signal touch_started

var _touch_index :int = -1

func _ready() -> void:
	if not OS.has_touchscreen_ui_hint() and visibility_mode == VisibilityMode.TOUCHSCREEN_ONLY:
		hide()

func _touch_started(event: InputEventScreenTouch) -> bool:
	return event.pressed and _touch_index == -1

func _touch_ended(event: InputEventScreenTouch) -> bool:
	return not event.pressed and _touch_index == event.index

func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return

	if event is InputEventScreenTouch:
		if _touch_started(event) and _is_inside_control_rect(event.position, self):
			emit_signal("touch_started")

		elif _touch_ended(event):
			_reset()

func _reset():
	_touch_index = -1
	is_working = false
	output = Vector2.ZERO
	_handle.self_modulate = _original_color
	_background.rect_position = _original_position

func _is_inside_control_rect(global_position: Vector2, control: Control) -> bool:
	var x: bool = global_position.x > control.rect_global_position.x and global_position.x < control.rect_global_position.x + (control.rect_size.x * control.rect_scale.x)
	var y: bool = global_position.y > control.rect_global_position.y and global_position.y < control.rect_global_position.y + (control.rect_size.y * control.rect_scale.y)
	return x and y

func _is_inside_control_circle(global_position: Vector2, control: Control) -> bool:
	var ray := control.rect_size.x * control.rect_scale.x / 2
	var center := control.rect_global_position + Vector2(ray, ray)
	var ray_position := global_position - center
	return ray_position.length_squared() < ray * ray

