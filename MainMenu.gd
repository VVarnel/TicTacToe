extends Control

@export var sprite_spawn_scenes: Array[PackedScene]

func Scene_change_to_game():
	get_tree().change_scene_to_file(
		'res://main.tscn'
	)
	
func exit_game():
	get_tree().quit()

func _on_play_vs_friends_pressed() -> void:
	GameSettings.ai_easy = false
	GameSettings.ai_normal = false
	GameSettings.ai_hard = false
	Scene_change_to_game()
	
func _on_exit_pressed() -> void:
	exit_game()

func _on_play_vs_bots_pressed() -> void:
	$ColorRect/CenterContainer/VBoxContainer/Play_vs_bots/VBoxContainer.visible = \
	!$ColorRect/CenterContainer/VBoxContainer/Play_vs_bots/VBoxContainer.visible

	

func _on_easy_pressed() -> void:
	GameSettings.ai_easy = true
	GameSettings.ai_normal = false
	GameSettings.ai_hard = false
	Scene_change_to_game()

func _on_normal_pressed() -> void:
	GameSettings.ai_easy = false
	GameSettings.ai_normal = true
	GameSettings.ai_hard = false
	Scene_change_to_game()

func _on_hard_pressed() -> void:
	GameSettings.ai_easy = false
	GameSettings.ai_normal = false
	GameSettings.ai_hard = true
	Scene_change_to_game()
	
	
	
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
