extends CanvasLayer

## Shows the on-screen stick, but only on devices that actually have a
## touchscreen -- a desktop itch.io player keeps a clean screen and the keys.

## Show the stick regardless, which is handy for testing on a desktop.
@export var force_visible := false

@onready var _joystick: Control = $Joystick


func _ready() -> void:
	set_active(false)


func set_active(active: bool) -> void:
	visible = active and (force_visible or DisplayServer.is_touchscreen_available())
	_joystick.set_active(visible)
