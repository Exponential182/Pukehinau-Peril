extends Control

signal create_server
signal create_client(port)

func _on_host_button_pressed():
	create_server.emit()

func _on_join_button_pressed():
	create_client.emit(int($port_input.text))
