extends Node2D


func _ready():
	Globals.enet_peer.create_client("localhost", Globals.port)
	multiplayer.multiplayer_peer = Globals.enet_peer
