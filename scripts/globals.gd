extends Node
var game_complete = false
var game_time = 0
var game_active = false


func matrix_copy_2d(matrix) -> Array:
	var copy = []
	for row in matrix:
		copy.append(row.duplicate())
	return copy

func _physics_process(delta):
	if game_active:
		game_time += delta

func time_string():
	var minutes = int(floor(game_time / 60))
	var seconds = snapped(game_time - minutes*60, 0.001)
	if game_time >= 60:
		if seconds < 10:
			return str(minutes)+":0"+str(seconds)
		else:
			return str(minutes)+":"+str(seconds)
	else:
		return str(seconds)
