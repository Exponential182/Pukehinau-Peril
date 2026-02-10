extends Node

var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func create_local_server():
	const  MIN_PORT = 49152
	var port = MIN_PORT
	var status = -1
	while status != 0 and port < 55000:
		port += 1
		status = peer.create_server(port, 2)
	multiplayer.multiplayer_peer = peer
	$port.text = "port: " + str(port)
	$port.show()
	$menu.hide()
	multiplayer.peer_connected.connect(create_local_server_client)

func create_local_server_client():
	pass

func _on_menu_server_request(server_type):
	if server_type == "LAN":
		create_local_server()
	if server_type == "node_tunnel":
		pass
		
