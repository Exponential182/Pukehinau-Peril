extends Node3D
func _physics_process(delta: float) -> void:
	$scrolltext.position.y += delta
	if $scrolltext.position.y > 50:
		$animation_player.play("fade")
		await $animation_player.animation_finished
		get_tree().change_scene_to_file("res://prefabs/main_menu.tscn")
