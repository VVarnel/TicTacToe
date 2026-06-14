extends Control

@export var sprite_spawn_scenes: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_vs_friends():
	get_tree().change_scene_to_file(
		'res://main.tscn'
	)
func exit_game():
	get_tree().quit()

func _on_play_vs_friends_pressed() -> void:
	play_vs_friends()
	
func _on_exit_pressed() -> void:
	exit_game()

#################################################
#Sprite Spawner
#################################################

func random_sprite_spawn():

	var scene = sprite_spawn_scenes.pick_random()
	var sprite = scene.instantiate()

	var spawn_follow = $SpriteSpawnPath/SpritePathFollow
	spawn_follow.progress_ratio = randf()

	sprite.global_position = spawn_follow.global_position

	sprite.rotation = randf_range(0, TAU)

	sprite.gravity_scale = randf_range(0.7, 2.0)
	sprite.linear_velocity = Vector2(
		randf_range(-50, 50),
		randf_range(0, 80)
	)

	add_child(sprite)

func _on_spawn_timer_timeout() -> void:
	random_sprite_spawn()
