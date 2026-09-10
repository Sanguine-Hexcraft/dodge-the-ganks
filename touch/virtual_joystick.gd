extends Control

## An analog stick drawn straight onto the screen for touch (and mouse) players.
## It feeds the same move_* actions the keyboard uses, so the gameplay code
## doesn't need to know where the input came from.

# Pointer ids: touch events bring their own finger index, the mouse gets this.
const MOUSE_POINTER := -2
const NO_POINTER := -1

@export var knob_radius := 38.0

## How far off centre a drag has to be before it counts as input at all.
@export_range(0.0, 1.0) var deadzone := 0.15

## Extra slack around the base so a slightly-off thumb still grabs the stick.
@export var grab_padding := 24.0

var _pointer := NO_POINTER
var _output := Vector2.ZERO


func _ready() -> void:
	# The stick hit-tests itself in _input, so keep it out of the GUI's way.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_active(false)


## Toggled by the parent overlay. Activation is explicit rather than driven by
## visibility_changed, because a CanvasLayer hiding does not notify its
## CanvasItem children -- the stick would keep eating input while invisible.
func set_active(active: bool) -> void:
	visible = active
	set_process_input(active)

	if not active:
		# Never leave an action stuck down because the stick went away mid-drag.
		_pointer = NO_POINTER
		_set_output(Vector2.ZERO)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_handle_press(touch.index, touch.position, touch.pressed)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_handle_drag(drag.index, drag.position)
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			_handle_press(MOUSE_POINTER, button.position, button.pressed)
	elif event is InputEventMouseMotion:
		_handle_drag(MOUSE_POINTER, (event as InputEventMouseMotion).position)


func _draw() -> void:
	var centre := size / 2.0
	var base_radius := _base_radius()

	draw_circle(centre, base_radius, Color(0, 0, 0, 0.18))
	draw_arc(centre, base_radius, 0, TAU, 48, Color(1, 1, 1, 0.35), 3.0, true)

	var knob := centre + _output * (base_radius - knob_radius)
	var knob_alpha := 0.45 if _pointer != NO_POINTER else 0.22
	draw_circle(knob, knob_radius, Color(1, 1, 1, knob_alpha))
	draw_arc(knob, knob_radius, 0, TAU, 32, Color(1, 1, 1, 0.55), 2.0, true)


func _base_radius() -> float:
	return minf(size.x, size.y) / 2.0


func _handle_press(pointer: int, pointer_position: Vector2, pressed: bool) -> void:
	if pressed:
		# Ignore a second finger, and the mouse event the engine synthesises
		# from the touch that is already driving the stick.
		if _pointer != NO_POINTER or not _in_grab_range(pointer_position):
			return

		_pointer = pointer
		_update_output(pointer_position)
	elif _pointer == pointer:
		_pointer = NO_POINTER
		_set_output(Vector2.ZERO)
	else:
		return

	get_viewport().set_input_as_handled()


func _handle_drag(pointer: int, pointer_position: Vector2) -> void:
	if _pointer != pointer:
		return

	_update_output(pointer_position)
	get_viewport().set_input_as_handled()


func _in_grab_range(pointer_position: Vector2) -> bool:
	var reach := _base_radius() + grab_padding
	return pointer_position.distance_squared_to(get_global_rect().get_center()) <= reach * reach


func _update_output(pointer_position: Vector2) -> void:
	var offset := (pointer_position - get_global_rect().get_center()) / _base_radius()
	_set_output(Vector2.ZERO if offset.length() < deadzone else offset.limit_length(1.0))


func _set_output(output: Vector2) -> void:
	if output.is_equal_approx(_output):
		return

	var previous := _output
	_output = output

	# Only touch the actions this stick actually drives, so someone using the
	# keyboard at the same time doesn't get their held keys released.
	_update_action(&"move_right", output.x, previous.x)
	_update_action(&"move_left", -output.x, -previous.x)
	_update_action(&"move_down", output.y, previous.y)
	_update_action(&"move_up", -output.y, -previous.y)

	queue_redraw()


func _update_action(action: StringName, strength: float, previous_strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	elif previous_strength > 0.0:
		Input.action_release(action)
