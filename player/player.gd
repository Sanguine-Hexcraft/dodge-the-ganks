extends Area2D

signal hit

## How fast the player will move (pixels/sec).
@export var speed := 400

## Size of the game window.
var screen_size: Vector2

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Finds the size of the game window when this node enters the scene tree.
	screen_size = get_viewport_rect().size
	hide()


func _process(delta: float) -> void:
	# Reading the axes rather than the four buttons keeps the on-screen stick
	# analog: a small nudge moves the player slowly, like a real gamepad.
	var velocity := Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed

	if velocity.length() > 0:
		_animated_sprite.play()
	else:
		_animated_sprite.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# check movment direction for sprite direction
	if velocity.x != 0:
		_animated_sprite.animation = "walk"
		_animated_sprite.flip_v = false
		_animated_sprite.flip_h = velocity.x < 0


func _on_body_entered(_body: Node2D) -> void:
	hide()  # Player disappears after being hit (ganked).
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	_collision_shape.set_deferred(&"disabled", true)


func start(start_position: Vector2) -> void:
	position = start_position
	show()
	_collision_shape.disabled = false
