extends Area2D

var player_in_area := false

func _on_body_entered(body):
	if body.is_multiplayer_authority():
		player_in_area = true
		body.can_start_puzzle = true

func _on_body_exited(body):
	if body.is_multiplayer_authority():
		player_in_area = false
		body.can_start_puzzle = false
