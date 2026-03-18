extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$"../../UI/dialogue".current_dialogue = "shortened_intro"
		$"../../UI/dialogue".change_text()
