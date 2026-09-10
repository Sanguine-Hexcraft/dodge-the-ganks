extends Node

@export var mob_scene: PackedScene

var _score := 0


func game_over() -> void:
	$MobTimer.stop()
	$ScoreTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	$TouchControls.set_active(false)


func new_game() -> void:
	$Music.play()

	_score = 0

	$Player.start($StartPosition.position)

	$StartTimer.start()

	$HUD.update_score(_score)
	$HUD.show_message("Get Ready!")

	get_tree().call_group(&"mobs", &"queue_free")

	$TouchControls.set_active(true)


func _on_score_timer_timeout() -> void:
	_score += 1
	$HUD.update_score(_score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob := mob_scene.instantiate()

	# Choose a random location on Path2D
	var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction := mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity.
	mob.linear_velocity = Vector2(randf_range(150.0, 250.0), 0).rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
