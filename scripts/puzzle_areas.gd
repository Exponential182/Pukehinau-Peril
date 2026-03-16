extends Area2D


func _on_body_entered(body):
	if body.name == "player":
		body.can_start_puzzle = true
		body.current_puzzle = self.name
		$"../../UI/puzzle".show()

func _on_body_exited(body):
	if body.name == "player":
		body.can_start_puzzle = false
		$"../../UI/puzzle".hide()
