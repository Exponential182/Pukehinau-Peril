extends Control

func _ready() -> void:
	if Global.game_complete:
		$credit_replay.show()
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/main_level.tscn")


func _on_credit_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/credit.tscn")
