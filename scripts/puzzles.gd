extends Node2D
@onready var lights = $"../world/lights"
@onready var player = $"../player"
@onready var puzzles = {
	"vertical_puzzle" : [preload("res://prefabs/vertical_puzzle.tscn"), false, "brain"],
	"forge_puzzle" : [preload("res://prefabs/forge_puzzle.tscn"), false, "brawn"],
	"number_puzzle" : [preload("res://prefabs/number_puzzle.tscn"),false,"brain"]
}

func _on_player_summon_puzzle(puzzle_name,player_state) -> void:
	if not puzzles[puzzle_name][1] and player_state == puzzles[puzzle_name][2]:
		var spawned_puzzle = puzzles[puzzle_name][0].instantiate()
		self.add_child(spawned_puzzle)
		spawned_puzzle.position = Vector2.ZERO
		lights.hide()
		player.velocity = Vector2.ZERO
		$"../UI/interact".hide()
		$"../animation_player".play("enter_puzzle")
	else:
		fix_player()

func number_puzzle_completed(ending):
	$"../puzzle_areas/number_puzzle".modulate = Color("green")
	fix_player()
	$"../puzzle_areas/number_puzzle/area".disabled = true
	puzzles["number_puzzle"][1] = true
	$"../dialogue_areas/rodkiss".rodkiss_level = "rodkiss_" +str(ending)
func vertical_puzzle_completed():
	$"../puzzle_areas/vertical_puzzle".modulate = Color("green")
	fix_player()
	$"../animation_player".play("lights")
	$"../puzzle_areas/vertical_puzzle/area".disabled = true
	puzzles["vertical_puzzle"][1] = true
	$"../dialogue_areas/wrong_player".position.y += 1000
	$"../dialogue_areas/stop_exploring/collision_polygon_2d".disabled = true
	$"../animation_player2".play("exit_puzzle")
func forge_puzzle_completed():
	$"../world/doors/door2".is_enterable = true
	$"../world/doors/door2/sprite_2d".hide()
	$"../puzzle_areas/forge_puzzle".modulate = Color("green")
	fix_player()
	puzzles["forge_puzzle"][1] = true
	$"../puzzle_areas/forge_puzzle/area".disabled = true
	$"../dialogue_areas/alt_wrong_player".position.y += 1000
	$"../animation_player".play("exit_puzzle")
func fix_player():
	player.is_puzzling = false
	player.camera.enabled = true
	$puzzle_camera.enabled = false
	player.can_start_puzzle = true
	lights.show()
