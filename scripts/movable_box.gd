extends StaticBody2D

signal box_entered(box: Node)
signal box_exited(box: Node)


func _ready():
	var player = get_node("/root/main_level/player")
	box_entered.connect(player._box_entered)
	box_exited.connect(player._box_exited)


func _physics_process(_delta: float) -> void:
	move_and_collide(Vector2.ZERO)


func _on_body_entered(body):
	if body.name == "player":
		box_entered.emit(self)


func _on_body_exited(body):
	if body.name == "player":
		box_exited.emit(self)
