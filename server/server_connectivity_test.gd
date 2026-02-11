extends Node2D

var free = true
signal colour_changed(colour)

#exports to be redfined
@export var test_colour: Color = Color()


func _ready():
	test_colour = $test.color


func _process(_delta):
	if free and multiplayer.is_server():
		free = false
		for i in range(8):
			var red = 0
			var green = 0
			var blue = 0
			if i in [4,5,6,7]:
				red = 1
			if i in [2,3,6,7]:
				green = 1
			if i in [1,3,5,7]:
				blue = 1
			test_colour = Color(red, green, blue, 1)
			colour_changed.emit(str(Color(red, green, blue, 1)))
			await get_tree().create_timer(1).timeout
		free = true
	elif not multiplayer.is_server():
		print(test_colour)
		$test.color = test_colour
