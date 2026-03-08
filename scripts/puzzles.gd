extends Node2D
@onready var lights = $"../world/lights"
@onready var player = $"../player"
@onready var puzzles = {
	"vertical_puzzle" : [preload("res://prefabs/vertical_puzzle.tscn"), false, "brain"],
	"forge_puzzle" : [preload("res://prefabs/forge_puzzle.tscn"), false, "brawn"],
}

func _on_player_summon_puzzle(puzzle_name,player_state) -> void:
	if not puzzles[puzzle_name][1] and player_state == puzzles[puzzle_name][2]:
		var spawned_puzzle = puzzles[puzzle_name][0].instantiate()
		self.add_child(spawned_puzzle)
		spawned_puzzle.position = Vector2.ZERO
		lights.hide()
	else:
		print("hello")
		fix_player()


func vertical_puzzle_completed():
	$"../puzzle_areas/vertical_puzzle".modulate = Color("green")
	fix_player()
	puzzles["vertical_puzzle"][1] = true
func forge_puzzle_completed():
	$"../puzzle_areas/forge_puzzle".modulate = Color("green")
	fix_player()
	puzzles["forge_puzzle"][1] = true

func fix_player():
	player.is_puzzling = false
	player.camera.enabled = true
	$puzzle_camera.enabled = false
	lights.show()
