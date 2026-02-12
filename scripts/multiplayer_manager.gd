extends Node

var enet_peer = ENetMultiplayerPeer.new()


func create_LAN_server():
	const  MIN_PORT = 49152
	var port = MIN_PORT
	var status = -1
	while status != 0 and port < 55000:
		port += 1
		status = enet_peer.create_server(port, 2)
	multiplayer.multiplayer_peer = enet_peer
	$port.text = "port: " + str(port)
	multiplayer.peer_connected.connect(spawn_player)
	$main_menu.queue_free()
	add_child(preload("res://prefabs/main_level.tscn").instantiate())

func create_client():
	pass
	
func spawn_player(peer_id):
	var player = preload("res://prefabs/player.tscn").instantiate()
	player.position = Vector2(350, 200)
	player.set_multiplayer_authority(peer_id)
	player.name = str(peer_id)
	$players.add_child(player)
