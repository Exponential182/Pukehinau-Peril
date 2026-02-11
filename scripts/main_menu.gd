extends Control
signal server_request(server_type: String)


func _on_host_button_pressed() -> void:
	get_tree().change_scene_to_file("res://server/server.tscn")
