extends Control

func _ready() -> void:
	$animation_player.play("new_animation")
	if Global.game_complete:
		$credit_replay.show()

func _on_start_button_pressed() -> void:
	$start_button.disabled = true
	$animation_player.play_backwards("new_animation")
	await $animation_player.animation_finished
	get_tree().change_scene_to_file("res://prefabs/main_level.tscn")


func _on_credit_replay_pressed() -> void:
	$credit_replay.disabled = true
	get_tree().change_scene_to_file("res://prefabs/credit.tscn")
