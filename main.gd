extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene


var cross_win_count: int
var circle_win_count: int
var player: int
var winner: int
var moves: int
var temp_marker 
var player_panel_pos: Vector2i
var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
var row_sum: int
var col_sum: int
var diagonal1_sum: int
var diagonal2_sum: int
var score_label_Cross
var score_label_Circle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_size = $Board.texture.get_width()
	#divide board size by 3 to get size of individual cell
	cell_size = board_size / 3
	#get coordinates of small panel on right side window
	player_panel_pos = $PlayerPanel.get_position()
	score_label_Cross = $PlayerScores/MarginContainer/VBoxContainer/HBoxContainer_Cross/CrossScore
	score_label_Circle = $PlayerScores/MarginContainer/VBoxContainer/HBoxContainer_Circle/CircleScore
	new_game()
	update_player_score()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not is_left_click(event):
		return
		
	if not is_board_click(event.position):
		return
	
	var clicked_cell := get_grid_pos(event.position)
	
	if not is_cell_empty(clicked_cell):
		return
	
	play_turn(clicked_cell)
	
	
func is_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed

func is_board_click(mouse_pos: Vector2) -> bool:
	return mouse_pos.x < board_size
	
func get_grid_pos(mouse_pos: Vector2) -> Vector2i:
	return Vector2i(mouse_pos / cell_size)

func is_cell_empty(pos: Vector2i) -> bool:
	return grid_data[pos.y][pos.x] == 0
	
func play_turn(pos: Vector2i) -> void:
	place_move(pos)
	
	if game_end_check():
		return
	
	switch_player()
	update_turn_marker()
	
	if not GameSettings.ai_easy and not GameSettings.ai_normal and not GameSettings.ai_hard:
		return
		
	if GameSettings.ai_easy == true:
		place_move(get_node("AI").random_free_cell())
	
	elif GameSettings.ai_normal == true:
		if get_node("AI").winning_cell() != Vector2i(-1,-1):
			place_move(get_node("AI").winning_cell())
			
		elif get_node("AI").blocking_cell() != Vector2i(-1, -1):
			place_move(get_node("AI").blocking_cell())
			
		else:
			place_move(get_node("AI").random_free_cell())		
	
	elif GameSettings.ai_hard == true:
		place_move(get_node("AI").best_moves())
	
	if game_end_check():
		return
	
	switch_player()
	update_turn_marker()
	
func game_end_check() -> bool:
	var result := check_win()
	
	if result != 0:
		end_game(result)
		return true
	
	if moves == 9:
		end_tie()
		return true
	
	return false


func place_move(pos: Vector2i) -> void:
	moves += 1
	grid_data[pos.y][pos.x] = player
	create_marker(
		player,
		pos * cell_size + Vector2i(cell_size / 2, cell_size / 2)
	)

func end_game(result: int) -> void:
	get_tree().paused = true
	$GameOverMenu.show()
	
	if result == 1:
		circle_win_count += 1
		$GameOverMenu/PlayerIcon.texture = load("res://Assets/circle.png")
		$GameOverMenu/PlayerIcon.show()
	elif result == -1:
		cross_win_count += 1
		$GameOverMenu/PlayerIcon.texture = load("res://Assets/cross.png")

	$GameOverMenu/ResultLabel.text = "Wins!"
	update_player_score()
	

func end_tie() -> void:
	get_tree().paused = true
	$GameOverMenu.show()
	$GameOverMenu/ResultLabel.text = "It's a Tie"
	$GameOverMenu/PlayerIcon.texture = null
	$GameOverMenu/PlayerIcon.hide()

func switch_player() -> void:
	player *= -1

func update_turn_marker() -> void:
	if temp_marker:
		temp_marker.queue_free()
		
	create_marker(
		player,
		player_panel_pos + Vector2i(cell_size / 2, cell_size/ 2),
		true
	)

func new_game():
	$Confetti_CanvasLayer/Confetti_green_left.emitting = false
	$Confetti_CanvasLayer/Confetti_green_right.emitting = false
	$Confetti_CanvasLayer/Confetti_red_left.emitting = false
	$Confetti_CanvasLayer/Confetti_red_right.emitting = false
	#$GameOverMenu/PlayerIcon.texture = null
	#$GameOverMenu/PlayerIcon.hide()
	
	
	
	player = 1
	winner = 0
	moves = 0
	
	grid_data = [
		[0,0,0],
		[0,0,0],
		[0,0,0]
	]
	
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	
	#clear existing marker
	
	get_tree().call_group("Circles", "queue_free")
	get_tree().call_group("Crosses", "queue_free")
	
	#create a marker to show starting players turn
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false
	
	
func create_marker(player, position, temp = false):
	#create a marker node and add it as a child
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross



func check_win() -> int:
	#add up marker in each row, column and diagonal
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
		#check if ether player has all of the marker in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1
	return winner
		


func _on_game_over_menu_restart() -> void:
	new_game()
	$Confetti_CanvasLayer/Confetti_green_left.hide()
	$Confetti_CanvasLayer/Confetti_green_right.hide()
	$Confetti_CanvasLayer/Confetti_red_left.hide()
	$Confetti_CanvasLayer/Confetti_red_right.hide()

func _on_game_over_menu_visibility() -> void:
	if winner == 1:
		$Confetti_CanvasLayer/Confetti_green_left.emitting = true
		$Confetti_CanvasLayer/Confetti_green_right.emitting = true
		$Confetti_CanvasLayer/Confetti_green_left.show()
		$Confetti_CanvasLayer/Confetti_green_right.show()
		$Confetti_CanvasLayer/Confetti_green_left.restart()
		$Confetti_CanvasLayer/Confetti_green_right.restart()
	elif winner == -1:
		$Confetti_CanvasLayer/Confetti_red_left.show()
		$Confetti_CanvasLayer/Confetti_red_right.show()
		$Confetti_CanvasLayer/Confetti_red_left.restart()
		$Confetti_CanvasLayer/Confetti_red_right.restart()
		$Confetti_CanvasLayer/Confetti_red_left.emitting = true
		$Confetti_CanvasLayer/Confetti_red_right.emitting = true

func update_player_score():
	score_label_Circle.text = "%d" % circle_win_count
	score_label_Cross.text = "%d" % cross_win_count

func back_to_menu():
	get_tree().change_scene_to_file(
		'res://main_menu.tscn'
	)

func _on_back_to_menu_pressed() -> void:
	back_to_menu()
	
