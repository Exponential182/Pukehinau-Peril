extends CharacterBody2D

@onready var explosion = preload("res://prefabs/explosion.tscn")
const SPEED = 300.0


func _physics_process(_delta: float) -> void:
	var direction_horizontal := Input.get_axis("left", "right")
	if direction_horizontal:
		velocity.x = direction_horizontal * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var direction_vertical := Input.get_axis("up", "down")
	if direction_vertical:
		velocity.y = direction_vertical * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
