extends Node2D

@onready var puzzles = {
	"vertical_puzzle" : preload("res://prefabs/vertical_puzzle.tscn"),
	"forge_puzzle" : preload("res://prefabs/forge_puzzle.tscn")
}

func _on_player_summon_puzzle(puzzle_name) -> void:
	print(puzzle_name)
	var spawned_puzzle = puzzles[puzzle_name].instantiate()
	self.add_child(spawned_puzzle)
	spawned_puzzle.position = self.position
	

func forge_puzzle_completed():
	$"../puzzle_areas/forge_puzzle".modulate = Color("red")
	$"../player".is_puzzling = false
