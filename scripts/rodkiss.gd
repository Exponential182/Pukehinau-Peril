extends Area2D
var rodkiss_level = "rodkiss_1"
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$"../../UI/dialogue".current_dialogue = rodkiss_level
		$"../../UI/dialogue".change_text()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		$"../../UI/dialogue".current_dialogue = null
		$"../../UI/interact".hide()
