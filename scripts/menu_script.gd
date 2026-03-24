extends Control
func _ready() -> void:
	if Global.show_credits:
		$credits2.show()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/main_level.tscn")


func _on_credits_2_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/credit.tscn")
