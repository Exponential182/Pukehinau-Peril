extends Node2D


func _on_reset_button_pressed():
	$player.position = Vector2(64, 512)
	await get_tree().create_timer(0.03).timeout
	$boxes/movable_box1.position = Vector2(448, 704)
	$boxes/movable_box2.position = Vector2(448, 576)
	$boxes/movable_box3.position = Vector2(1088, 576)
	$boxes/movable_box4.position = Vector2(1344, 576)
	$boxes/movable_box5.position = Vector2(1344, 960)
