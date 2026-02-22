extends Node2D


func vertical_puzzle_completed():
	set_puzzle_color.rpc(Color("blue"))
	set_puzzle_color(Color("blue"))

@rpc("any_peer", "call_remote")
func set_puzzle_color(color: Color):
	get_node("/root/game_manager/main_level/puzzle_areas/vert_puzzle").modulate = color
