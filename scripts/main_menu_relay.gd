extends Control

signal create_client(port)
signal create_server

func _create_server_relay() -> void:
	create_server.emit()


func _create_client_relay() -> void:
	create_client.emit($port_input.text)
