extends StaticBody2D

signal box_entered(box: Node)
signal box_exited()


func _on_body_entered(body):
	if body.name == "player":
		emit_signal("box_entered", self)


func _on_body_exited(body):
	if body.name == "player":
		emit_signal("box_exited")
