extends Node2D

@onready var key_map = $grid_handler/base_layer
@onready var grid_map = $grid_handler/grid_layer
@onready var correct_key_cells = $comparison_layer.get_used_cells()
var laser_on = false


func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		laser_on = true
	if Input.is_action_just_released("left_click"):
		laser_on = false
	
	if laser_on:
		var absolute_input_pos = get_viewport().get_mouse_position()
		var base_layer_tile_pos = key_map.local_to_map(key_map.to_local(absolute_input_pos))
		var grid_layer_tile_pos = grid_map.local_to_map(grid_map.to_local(absolute_input_pos))
		key_map.set_cell(base_layer_tile_pos, -1)
		grid_map.set_cell(grid_layer_tile_pos, -1)


func _on_reset_button_pressed():
	$grid_handler.free()
	var key_grid = preload("res://prefabs/forge_key_grid.tscn").instantiate()
	key_grid.position = Vector2(200, 75)
	self.add_child(key_grid)
	key_map = $grid_handler/base_layer
	grid_map = $grid_handler/grid_layer
	
	
	
