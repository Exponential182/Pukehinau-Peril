extends Node

func _ready():
	const MIN_PORT := 49152
	var port := MIN_PORT
	var status := -1
	print("finding port")
	while status != 0 and port < 55000:
		port += 1
		status = Globals.enet_peer.create_server(port, 2)
	print("port_found")
	Globals.port = port
	multiplayer.multiplayer_peer = Globals.enet_peer
	$port.text = "port: " + str(Globals.port)
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(peer_id):
	var player_scene := preload("res://prefabs/player.tscn")
	var player := player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(multiplayer.get_unique_id())
	player.position = Vector2(350, 200)
	$no_render/players.add_child(player)


func _on_world_colour_changed(colour):
	$colour.text = colour
