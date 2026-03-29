extends Node2D

@onready var player = get_node("/root/main_level/player")
signal entered_door
var is_enterable = false
var is_unlocked = false

func _ready() -> void:
	entered_door.connect(get_node("/root/main_level/player").entered_door)
func _on_door_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if is_unlocked or is_enterable:
			entered_door.emit(self.name,self.position)
		else:
			$"../../../UI/dialogue".current_dialogue = "final_locked"


func _on_door_area_body_exited(body: Node2D) -> void:
	if body.name == "player":
		if is_unlocked or is_enterable:
			entered_door.emit(null,Vector2.ZERO)
		else:
			$"../../../UI/dialogue".current_dialogue = null

func magical_door_opening():
	$door_area/tile_map_layer.hide()
	await get_tree().create_timer(0.5).timeout
	$door_area/tile_map_layer.show()
	$door_area/tile_map_layer.z_index = 50
	await get_tree().create_timer(0.5).timeout
	$door_area/tile_map_layer.z_index = 0


func _on_key_area_entered(body):
	if body.name == "player" and is_enterable:
		$"../../../animation_player3".play("lock_fade")
		await get_tree().create_timer(1).timeout
		is_unlocked = true
