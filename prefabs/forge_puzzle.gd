extends Node2D

@onready var key_map = $grid_handler/base_layer
@onready var grid_map = $grid_handler/grid_layer
var laser_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
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
