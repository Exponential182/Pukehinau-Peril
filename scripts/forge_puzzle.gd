extends Node2D

signal puzzle_completed

var start_grid_states = {}
var live_grid_states = {}
var target_cells = null
var key_map = null
var grid_map = null
var bounds = null
var current_stage = null

func _ready():
	var stage_1_grid = []
	var stage_2_grid = []
	
	puzzle_completed.connect(get_parent().forge_puzzle_completed)
	
	
	# Compose Grid for Stage 1
	stage_select(1)
	for i in range(bounds.y + 1):
		stage_1_grid.append(array_zeros(bounds.x+1))
	for pos in key_map.get_used_cells():
		stage_1_grid[pos.y][pos.x] = 1
	for pos in target_cells:
		stage_1_grid[pos.y][pos.x] = 2
	start_grid_states[1] = stage_1_grid
	live_grid_states[1] = Global.matrix_copy_2d(stage_1_grid)
	
	stage_select(2)
	for i in range(bounds.y + 1):
		stage_2_grid.append(array_zeros(bounds.x+1))
	for pos in key_map.get_used_cells():
		stage_2_grid[pos.y][pos.x] = 1
	for pos in target_cells:
		stage_2_grid[pos.y][pos.x] = 2
	start_grid_states[2] = stage_2_grid
	live_grid_states[2] = Global.matrix_copy_2d(stage_2_grid)
	
	stage_select(1)


func stage_select(stage):
	if stage == 1:
		target_cells = $grid_handler/stage_1/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_1/grid_layer
		key_map = $grid_handler/stage_1/base_layer
		bounds = Vector2i(35,21)
		current_stage = 1
	
	if stage == 2:
		target_cells = $grid_handler/stage_2/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_2/grid_layer
		key_map = $grid_handler/stage_2/base_layer
		bounds = Vector2i(24,14)
		current_stage = 2
	
	target_cells.sort()


func array_zeros(length):
	var array_to_fill = []
	for i in range(length):
		array_to_fill.append(0)
	return array_to_fill


func dfs_tile_removal(grid) -> Array:
	var coords_visited = {}
	var changes = []
	for row_index in range(len(grid)):
		for tile_index in range(len(grid[0])): 
			if Vector2i(tile_index, row_index) not in coords_visited.keys() and grid[row_index][tile_index] != 0:
				var stack = []
				var diff = []
				var found_two = false
				var start_pos = Vector2i(tile_index, row_index)
				stack.append(start_pos)
				coords_visited[start_pos] = 1
				while stack:
					var pos = stack.pop_back()
					diff.append(pos)
					if grid[pos.y][pos.x] != 0:
						for delta in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]:
							var new_pos = Vector2i(pos.x + delta.x, pos.y + delta.y)
							if new_pos not in coords_visited.keys():
								if 0 <= new_pos.y and new_pos.y <= bounds.y and 0 <= new_pos.x and new_pos.x <= bounds.x:
									if grid[new_pos.y][new_pos.x] != 0:
										if grid[new_pos.y][new_pos.x] == 2:
											found_two = true
										coords_visited[new_pos] = 1
										stack.append(new_pos)
					
				if not found_two:
					for coordinate in diff:
						grid[coordinate.y][coordinate.x] = 0
						changes.append(coordinate)
	return [grid, changes]


func _process(_delta):
	if Input.is_action_pressed("left_click"):
		var absolute_input_pos = get_viewport().get_mouse_position()
		var base_layer_tile_pos = key_map.local_to_map(key_map.to_local(absolute_input_pos))
		var grid_layer_tile_pos = grid_map.local_to_map(grid_map.to_local(absolute_input_pos))
		var original_grid_value = null
		if 0 <= base_layer_tile_pos.x and base_layer_tile_pos.x <= bounds.x and 0 <= base_layer_tile_pos.y and base_layer_tile_pos.y <= bounds.y:
			original_grid_value = live_grid_states[current_stage][base_layer_tile_pos.y][base_layer_tile_pos.x]
			key_map.set_cell(base_layer_tile_pos, -1)
			grid_map.set_cell(grid_layer_tile_pos, -1)
			live_grid_states[current_stage][base_layer_tile_pos.y][base_layer_tile_pos.x] = 0
		
			if original_grid_value != live_grid_states[current_stage][base_layer_tile_pos.y][base_layer_tile_pos.x]:
				var changes = dfs_tile_removal(live_grid_states[current_stage])
				live_grid_states[current_stage] = changes[0]
				for coordinate in changes[1]:
					key_map.set_cell(coordinate, -1)
					grid_map.set_cell(coordinate, -1)
				
				var sorted_key_map = key_map.get_used_cells()
				sorted_key_map.sort()
				if sorted_key_map == target_cells:
					if current_stage == 1:
						stage_select(2)
						$checkpoint_button.show()
						$checkpoint_button.disabled = false
						$grid_handler/stage_1.hide()
						$grid_handler/stage_2.show()
					elif current_stage == 2:
						$win_indicator.show()
						await get_tree().create_timer(2).timeout
						puzzle_completed.emit()
						self.queue_free()

func _on_reset_button_pressed():
	$grid_handler.free()
	var keys = preload("res://prefabs/forge_key_grid.tscn").instantiate()
	self.add_child(keys)
	stage_select(1)
	$checkpoint_button.hide()
	$checkpoint_button.disabled = true
	live_grid_states[1] = Global.matrix_copy_2d(start_grid_states[1])
	live_grid_states[2] = Global.matrix_copy_2d(start_grid_states[2])


func _on_checkpoint_button_pressed() -> void:
	$grid_handler.free()
	var keys = preload("res://prefabs/forge_key_grid.tscn").instantiate()
	self.add_child(keys)
	stage_select(2)
	$grid_handler/stage_1.hide()
	$grid_handler/stage_2.show()
	$checkpoint_button.show()
	$checkpoint_button.disabled = false
	live_grid_states[1] = Global.matrix_copy_2d(start_grid_states[1])
	live_grid_states[2] = Global.matrix_copy_2d(start_grid_states[2])
	
	
