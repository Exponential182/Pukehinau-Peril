extends Control
signal server_request(server_type: String)

func _on_singleplayer_pressed():
	server_request.emit("none")

func _on_local_pressed():
	server_request.emit("LAN")

func _on_node_tunnel_pressed():
	server_request.emit("node_tunnel")
