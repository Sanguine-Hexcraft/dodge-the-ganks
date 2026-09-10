extends RigidBody2D


func _ready() -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	# The sprite frames hold one animation per mob type (np, slark, marci).
	var mob_types := animated_sprite.sprite_frames.get_animation_names()
	animated_sprite.play(mob_types[randi() % mob_types.size()])


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
