extends Node
var show_credits = false
func matrix_copy_2d(matrix) -> Array:
	var copy = []
	for row in matrix:
		copy.append(row.duplicate())
	return copy
