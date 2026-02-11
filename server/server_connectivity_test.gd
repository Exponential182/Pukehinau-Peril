extends Node2D

func _process():
	var red = 0
	var green = 0
	var blue = 0
	for i in range(8):
		if i in [4,5,6,7]:
			red = 255
		if i in [2,3,6,7]:
			green = 255
		if i in [1,3,5,7]:
			blue = 255
		$ColorRect.color = 
