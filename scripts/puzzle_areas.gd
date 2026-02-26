extends Area2D


func _on_body_entered(body):
	body.can_start_puzzle = true
	body.current_puzzle = self.name

func _on_body_exited(body):
	body.can_start_puzzle = true
