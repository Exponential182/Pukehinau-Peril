extends Node
var puzzle_active := false
@onready var puzzle_scene = preload("res://prefabs/puzzle.tscn")

@rpc("any_peer", "call_remote")
func request_puzzle_start(player_id: int):
	if not multiplayer.is_server():
		return
	if puzzle_active:
		return
	puzzle_active = true
	var player = get_node_or_null("/root/game_manager/players/" + str(player_id))
	if player:
		player.is_puzzling = true
	if player_id == multiplayer.get_unique_id():
		client_show_puzzle()
		client_lock_movement()
	else:
		client_show_puzzle.rpc_id(player_id)
		client_lock_movement.rpc_id(player_id)

@rpc("authority", "call_remote")
func client_show_puzzle():
	var puzzle = puzzle_scene.instantiate()
	get_node("/root/game_manager/main_level/puzzles").add_child(puzzle)
	puzzle.puzzle_completed.connect(_on_puzzle_completed)

@rpc("authority", "call_remote")
func client_lock_movement():
	var my_id := multiplayer.get_unique_id()
	var player = get_node_or_null("/root/game_manager/players/" + str(my_id))
	if player:
		player.is_puzzling = true

@rpc("authority", "call_remote")
func client_unlock_movement():
	var my_id := multiplayer.get_unique_id()
	var player = get_node_or_null("/root/game_manager/players/" + str(my_id))
	if player:
		player.is_puzzling = false

func _on_puzzle_completed():
	var my_id := multiplayer.get_unique_id()
	if multiplayer.is_server():
		notify_puzzle_done(my_id)
	else:
		notify_puzzle_done.rpc_id(1, my_id)

@rpc("any_peer", "call_remote")
func notify_puzzle_done(player_id: int):
	if not multiplayer.is_server():
		return
	puzzle_active = false
	var player = get_node_or_null("/root/game_manager/players/" + str(player_id))
	if player:
		player.is_puzzling = false
	if player_id == multiplayer.get_unique_id():
		client_unlock_movement()
	else:
		client_unlock_movement.rpc_id(player_id)
	set_puzzle_color.rpc(Color("red"))
	set_puzzle_color(Color("red"))

@rpc("authority", "call_remote")
func set_puzzle_color(color: Color):
	get_node("/root/game_manager/main_level/puzzle_areas/vert_puzzle").modulate = color
