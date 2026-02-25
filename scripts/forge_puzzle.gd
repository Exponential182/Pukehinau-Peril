extends Node2D

@onready var layer_1_key_map = $grid_handler/stage_1/base_layer
@onready var layer_1_grid_map = $grid_handler/stage_1/grid_layer
@onready var layer_1_correct_key_cells = $grid_handler/stage_1/comparison_layer.get_used_cells()
@onready var layer_2_key_map = $grid_handler/stage_2/base_layer
@onready var layer_2_grid_map = $grid_handler/stage_2/grid_layer
@onready var layer_2_correct_key_cells = $grid_handler/stage_2/comparison_layer.get_used_cells()
@onready var layer_2_bounds = Vector2i.ZERO
var laser_on = false
var grid_state = []
var grid_states = {}


func _ready():
	for cell in layer_2_key_map.get_used_cells():
		layer_2_bounds.x = max(layer_2_bounds.x, cell.x)
		layer_2_bounds.y = max(layer_2_bounds.y, cell.y)
	var layer_2_width = layer_2_bounds.x
	var layer_2_height = layer_2_bounds.y
	var phase_2_grid = []
	print($grid_handler/stage_2/base_layer.get_used_cells())
	for i in range(layer_2_height+1):
		phase_2_grid.append(array_ones(layer_2_width+1))
	for pos in layer_2_key_map.get_used_cells():
		phase_2_grid[pos.y][pos.x] = 1
	for pos in layer_2_correct_key_cells:
		phase_2_grid[pos.y][pos.x] = 2
	grid_states[1] = phase_2_grid


func array_ones(length):
	var array_to_fill = []
	for i in range(length):
		array_to_fill.append(0)
	return array_to_fill


func dfs_tile_removal(grid, bounds) -> Array:
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
	if Input.is_action_just_pressed("left_click"):
		laser_on = true
	if Input.is_action_just_released("left_click"):
		laser_on = false
		var changes = dfs_tile_removal(grid_states[1], Vector2i(len(grid_states[1][0])-1, len(grid_states[1])-1))
		grid_states[1] = changes[0]
		print(changes[1])
		for coordinate in changes[1]:
			layer_2_key_map.set_cell(coordinate, -1)
			layer_2_grid_map.set_cell(coordinate, -1)
		print(grid_states[1])
	
	if laser_on:
		var absolute_input_pos = get_viewport().get_mouse_position()
		var base_layer_tile_pos = layer_2_key_map.local_to_map(layer_2_key_map.to_local(absolute_input_pos))
		var grid_layer_tile_pos = layer_2_grid_map.local_to_map(layer_2_grid_map.to_local(absolute_input_pos))
		if 0 <= base_layer_tile_pos.x and base_layer_tile_pos.x <= layer_2_bounds.x and 0 <= base_layer_tile_pos.y and base_layer_tile_pos.y <= layer_2_bounds.y:
			layer_2_key_map.set_cell(base_layer_tile_pos, -1)
			layer_2_grid_map.set_cell(grid_layer_tile_pos, -1)
			print(base_layer_tile_pos)
			grid_states[1][base_layer_tile_pos.y][base_layer_tile_pos.x] = 0
		


func _on_reset_button_pressed():
	$grid_handler.free()
	var key_grid = preload("res://prefabs/forge_key_grid.tscn").instantiate()
	key_grid.position = Vector2(200, 75)
	self.add_child(key_grid)
	layer_2_key_map = $grid_handler/stage_2/base_layer
	layer_2_grid_map = $grid_handler/stage_2/grid_layer
	
	
	
