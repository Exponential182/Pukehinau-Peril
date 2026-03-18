extends Node2D


func _on_reset_button_pressed():
	$player.position = Vector2(64, 512)
	await get_tree().create_timer(0.03).timeout
	$boxes/movable_box1.position = Vector2(1216, 128)
	$boxes/movable_box2.position = Vector2(1472, 832)
	$boxes/movable_box3.position = Vector2(832, 384)
	$boxes/movable_box4.position = Vector2(960, 704)
	
