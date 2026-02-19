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
		# Host is the triggering player, call directly
		client_show_puzzle()
	else:
		client_show_puzzle.rpc_id(player_id)

@rpc("authority", "call_remote")
func client_show_puzzle():
	var puzzle = puzzle_scene.instantiate()
	get_node("/root/game_manager/main_level/puzzles").add_child(puzzle)
	get_node("/root/game_manager/main_level/puzzle_areas/vert_puzzle").modulate = Color("red")
	puzzle.puzzle_completed.connect(_on_puzzle_completed)

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
