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
	multiplayer.peer_connected.connect(spawn_player)
	spawn_player(multiplayer.get_unique_id())
	$port.text = "port: " + str(port)
	$main_menu.queue_free()
	add_child(preload("res://prefabs/main_level.tscn").instantiate())

func create_client(port_unverified):
	if port_unverified.is_valid_int():
		var port = int(port_unverified)
		enet_peer.create_client("localhost", port)
		multiplayer.multiplayer_peer = enet_peer
		$main_menu.queue_free()
		add_child(preload("res://prefabs/main_level.tscn").instantiate())
	else:
		$main_menu/error_message.hide()
		await get_tree().create_timer(0.1).timeout
		$main_menu/error_message.show()

func spawn_player(peer_id):
	if !multiplayer.is_server(): return
	print("Player Spawned: " + str(peer_id))
	var player = preload("res://prefabs/player.tscn").instantiate()
	player.name = str(peer_id)
	$players.add_child(player)
