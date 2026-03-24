extends Node
var game_complete = false
func matrix_copy_2d(matrix) -> Array:
	var copy = []
	for row in matrix:
		copy.append(row.duplicate())
	return copy
