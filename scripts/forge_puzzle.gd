extends Node2D

signal puzzle_completed

var input_lock = false
var stage_count = 4
var start_grid_states = {}
var live_grid_states = {}
var stage_parent = null
var target_cells = null
var key_map = null
var grid_map = null
var bounds = null
var stage_scale = 0
var current_stage = null
@onready var fadeout_particle = preload("res://prefabs/forge_tile_fade.tscn")
@onready var pop_particle = preload("res://prefabs/forge_tile_pop.tscn")
@onready var forge_grid = preload("res://prefabs/forge_key_grid.tscn")
@onready var pop_sound = preload("res://prefabs/forge_pop_sound.tscn")


func stage_select(stage):
	$tutorial.hide()
	if stage == 1:
		stage_parent = $grid_handler/stage_1
		target_cells = $grid_handler/stage_1/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_1/grid_layer
		key_map = $grid_handler/stage_1/base_layer
		bounds = Vector2i(24, 14)
		current_stage = 1
		stage_scale = 4
		$tutorial.show()
	
	if stage == 2:
		stage_parent = $grid_handler/stage_2
		target_cells = $grid_handler/stage_2/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_2/grid_layer
		key_map = $grid_handler/stage_2/base_layer
		bounds = Vector2i(22, 14)
		current_stage = 2
		stage_scale = 4
	
	if stage == 3:
		stage_parent = $grid_handler/stage_3
		target_cells = $grid_handler/stage_3/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_3/grid_layer
		key_map = $grid_handler/stage_3/base_layer
		bounds = Vector2i(17, 15)
		current_stage = 3
		stage_scale = 4
	
	if stage == 4:
		stage_parent = $grid_handler/stage_4
		target_cells = $grid_handler/stage_4/comparison_layer.get_used_cells()
		grid_map = $grid_handler/stage_4/grid_layer
		key_map = $grid_handler/stage_4/base_layer
		bounds = Vector2i(22, 14)
		current_stage = 4
		stage_scale = 4
	
	target_cells.sort()


func create_grid(stage_id):
	var grid = []
	
	stage_select(stage_id)
	for i in range(bounds.y + 1):
		grid.append(array_zeros(bounds.x+1))
	for pos in key_map.get_used_cells():
		grid[pos.y][pos.x] = 1 # A tile exists
	for pos in target_cells: 
		grid[pos.y][pos.x] = 2 # A tile which needs to be save exists.
	start_grid_states[stage_id] = Global.matrix_copy_2d(grid)
	live_grid_states[stage_id] = Global.matrix_copy_2d(grid)


func array_zeros(length):
	var array_to_fill = []
	for i in range(length):
		array_to_fill.append(0)
	return array_to_fill


func spawn_fadeout_particle(pos: Vector2, particle_scale: int):
	var spawned_particle = fadeout_particle.instantiate()
	spawned_particle.position = pos
	spawned_particle.process_material.scale = Vector2(particle_scale, particle_scale)
	spawned_particle.emitting = true
	self.add_child(spawned_particle)

func spawn_pop_particle(pos: Vector2):
	var spawned_particle = pop_particle.instantiate()
	spawned_particle.position = pos
	spawned_particle.emitting = true
	self.add_child(spawned_particle)


func stage_reset(stage):
	$grid_handler.queue_free()
	await $grid_handler.tree_exited
	var new_grid = forge_grid.instantiate()
	self.add_child(new_grid)
	stage_select(stage)
	for i in range(1, stage_count+1):
		live_grid_states[i] = Global.matrix_copy_2d(start_grid_states[i])
		get_node("grid_handler/stage_"+str(i)).hide()
		if i <= current_stage:
			get_node("stage_"+str(i)+"_button").disabled = false
	get_node("grid_handler/stage_"+str(current_stage)).show()


func dfs_tile_removal(grid) -> Array:
	var visited = []
	var height = len(grid)
	var width = len(grid[0])
	var directions = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]
	for i in range(height):
		visited.append(array_zeros(width))
	var changes = []
	for row_index in range(height):
		for tile_index in range(width): 
			if visited[row_index][tile_index] == 0 and grid[row_index][tile_index] != 0:
				var stack = []
				var diff = []
				var found_two = false
				var start_pos = row_index * width + tile_index
				stack.append(start_pos)
				visited[row_index][tile_index] = 1
				while stack:
					var key = stack.pop_back()
					var x = key % width
					var y = key / width
					diff.append(key)
					if grid[y][x] != 0:
						for delta in directions:
							var nx = x + delta.x
							var ny = y + delta.y
							if 0 <= ny and ny < height and 0 <= nx and nx < width:
								if visited[ny][nx] == 0:
									if grid[ny][nx] != 0:
										if grid[ny][nx] == 2:
											found_two = true	
										visited[ny][nx] = 1
										stack.append(ny*width + nx)
					
				if not found_two:
					for key in diff:
						grid[key/width][key%width] = 0
						changes.append(Vector2i(key%width, key/width))
	return [grid, changes]


func _ready():
	puzzle_completed.connect(get_parent().forge_puzzle_completed)
	spawn_fadeout_particle(Vector2(-1000, -1000), 1)
	spawn_pop_particle(Vector2(-1000, -1000))
	
	
	for i in range(1, 6):
		create_grid(i)
	
	stage_select(1)


func _process(_delta):
	if Input.is_action_pressed("left_click") and not input_lock:
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
				spawn_pop_particle(key_map.map_to_local(base_layer_tile_pos)*stage_scale)
				spawn_fadeout_particle(key_map.map_to_local(base_layer_tile_pos)*stage_scale, stage_scale)
				add_child(pop_sound.instantiate())
				var changes = dfs_tile_removal(live_grid_states[current_stage])
				live_grid_states[current_stage] = changes[0]
				for coordinate in changes[1]:
					spawn_fadeout_particle(key_map.map_to_local(coordinate)*stage_scale, stage_scale)
					key_map.set_cell(coordinate, -1)	
					grid_map.set_cell(coordinate, -1)
				
				var sorted_key_map = key_map.get_used_cells()
				sorted_key_map.sort()
				if sorted_key_map == target_cells:
					input_lock = true
					await get_tree().create_timer(0.5).timeout
					input_lock = false
					if current_stage == 1:
						stage_select(2)
						$stage_2_button.disabled = false
						$grid_handler/stage_1.hide()
						$grid_handler/stage_2.show()
						$tutorial.hide()
					elif current_stage == 2:
						stage_select(3)
						$stage_3_button.disabled = false
						$grid_handler/stage_2.hide()
						$grid_handler/stage_3.show()
					elif current_stage == 3:
						stage_select(4)
						$stage_4_button.disabled = false
						$grid_handler/stage_3.hide()
						$grid_handler/stage_4.show()
					elif current_stage == 4:
						puzzle_completed.emit()
						$win_indicator.show()
						self.queue_free()


func _stage_1_reset():
	stage_reset(1)


func _stage_2_reset():
	stage_reset(2)


func _stage_3_reset():
	stage_reset(3)


func _stage_4_reset():
	stage_reset(4)
