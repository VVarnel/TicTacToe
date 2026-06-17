extends Node

@onready var game = get_parent()


func random_free_cell() -> Vector2i:
	
	var free_cells = []
	
	for y in range(game.grid_data.size()):
		for x in range(game.grid_data[y].size()):
			if game.grid_data[y][x] == 0:
				free_cells.append(Vector2i(x, y))
				 
	return free_cells.pick_random()
	
func blocking_or_winning_move(sum_target: int) -> Vector2i:
	var winning_lines = [
		[Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)], #row0
		[Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)], #row1
		[Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)], #row2
		
		[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)], #col0
		[Vector2i(1,0), Vector2i(1,1), Vector2i(1,2)], #col1
		[Vector2i(2,0), Vector2i(2,1), Vector2i(2,2)], #col2
		
		[Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)], #diag1
		[Vector2i(2,0), Vector2i(1,1), Vector2i(0,2)]  #diag2
	]
	
	for line in winning_lines:
		var sum := 0
		var empty_cell := Vector2i(-1,-1)
		
		for cell in line:
			sum += game.grid_data[cell.y][cell.x]
			
			if game.grid_data[cell.y][cell.x] == 0:
				empty_cell = cell
		
		if sum == sum_target and empty_cell != Vector2i(-1,-1):
			return empty_cell
			
	return Vector2i(-1,-1)

func winning_cell() -> Vector2i:
	var cell := blocking_or_winning_move(-2)
	if cell != Vector2i(-1,-1):
		return cell
		
	return Vector2i(-1,-1)

func blocking_cell() -> Vector2i:
	var cell := blocking_or_winning_move(2)
	if cell != Vector2i(-1,-1):
		return cell
		
	return Vector2i(-1,-1)


func best_moves() -> Vector2i:
	
	if game.moves <= 1:
		if game.grid_data[1][1] == 0:
			return Vector2i(1, 1)
		else:
			return Vector2i(0, 0)
	
	var best_scores := INF
	var move := Vector2i(-1,-1)
	
	for y in range(3):
		for x in range (3):
			if game.grid_data[y][x] == 0:
				game.grid_data[y][x] = -1
				var score = minimax(false)
				game.grid_data[y][x] = 0
				
				if score < best_scores:
					best_scores = score
					move = Vector2i(x, y)
	return move
	
func minimax(is_ai_turn: bool) -> int:
	var result = evaluate_board()
	
	if result != 0:
		return result
	
	if is_board_full():
		return 0
	
	if is_ai_turn:
		var best_score := INF
		
		for y in range(3):
			for x in range(3):
				if game.grid_data[y][x] == 0:
					game.grid_data[y][x] = -1
					var score = minimax(false)
					game.grid_data[y][x] = 0
					best_score = min(score, best_score)
					
		return best_score
	else:
		var best_score := -INF
		
		for y in range(3):
			for x in range(3):
				if game.grid_data[y][x] == 0:
					game.grid_data[y][x] = 1
					var score = minimax(true)
					game.grid_data[y][x] = 0
					best_score = max(score, best_score)

		return best_score
		
func evaluate_board() -> int:
	var lines = [
		[Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)],
		[Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
		[Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)],

		[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)],
		[Vector2i(1,0), Vector2i(1,1), Vector2i(1,2)],
		[Vector2i(2,0), Vector2i(2,1), Vector2i(2,2)],

		[Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)],
		[Vector2i(2,0), Vector2i(1,1), Vector2i(0,2)]
	]

	for line in lines:
		var sum := 0

		for cell in line:
			sum += game.grid_data[cell.y][cell.x]

		if sum == -3:
			return -10 # AI wins

		if sum == 3:
			return 10 # player wins

	return 0
	
func is_board_full() -> bool:
	for y in range(3):
		for x in range(3):
			if game.grid_data[y][x] == 0:
				return false

	return true
