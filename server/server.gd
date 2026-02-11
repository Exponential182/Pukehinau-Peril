extends Node
var enet_peer = ENetMultiplayerPeer.new()
var viewport = get_viewport()

func _ready():
	$world.hide()
	viewport.render
	


func create_LAN_server():
	const  MIN_PORT = 49152
	var port = MIN_PORT
	var status = -1
	while status != 0 and port < 55000:
		port += 1
		status = enet_peer.create_server(port, 2)
	$port.text = "port: " + str(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(spawn_player)


func spawn_player(peer_id):
	var player_scene = preload("res://prefabs/player.tscn")
