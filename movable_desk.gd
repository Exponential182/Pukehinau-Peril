extends StaticBody2D

signal desk_entered(desk: Node)
signal desk_exited(desk: Node)


func _on_body_entered(body):
	if body.name == "player":
		emit_signal("desk_entered", self)


func _on_body_exited(body):
	if body.name == "player":
		emit_signal("desk_exited", self)
