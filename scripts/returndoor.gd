extends Node2D

@onready var player = get_node("/root/main_level/player")
signal entered_door
func _ready() -> void:
	entered_door.connect(get_node("/root/main_level/player").entered_door)
func _on_door_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		entered_door.emit(self.name,self.position)
		body.enter_door()


func _on_door_area_body_exited(body: Node2D) -> void:
	if body.name == "player":
		entered_door.emit(null,Vector2.ZERO)

func magical_door_opening():
	pass
