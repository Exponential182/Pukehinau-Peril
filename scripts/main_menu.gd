extends Control


func _on_host_button_pressed():
	get_tree().change_scene_to_file("res://server/server.tscn")


func _on_join_button_pressed():
	Globals.port = int($port_input.text)
	get_tree().change_scene_to_file("res://prefabs/client.tscn")
