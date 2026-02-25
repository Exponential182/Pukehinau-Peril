extends CharacterBody2D

@onready var explosion = preload("res://prefabs/explosion.tscn")
@onready var camera = $player_camera
@onready var puzzles = get_node("/root/main_level/puzzles")
const SPEED = 300.0
@export var spawn_position := Vector2(350, 200)
var can_start_puzzle = false
var is_puzzling = false
var current_puzzle = null

signal summon_puzzle
func _ready():
	pass

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not is_puzzling:
		if can_start_puzzle and current_puzzle != null:
			can_start_puzzle = false
			is_puzzling = true
			summon_puzzle.emit(str(current_puzzle))

	if not is_puzzling:
		if Input.is_action_just_pressed("smack"):
			smack()

		var direction_horizontal := Input.get_axis("left", "right")
		velocity.x = direction_horizontal * SPEED if direction_horizontal else move_toward(velocity.x, 0, SPEED)

		var direction_vertical := Input.get_axis("up", "down")
		velocity.y = direction_vertical * SPEED if direction_vertical else move_toward(velocity.y, 0, SPEED)
	else:
		self.velocity.y = move_toward(velocity.y, 0, SPEED)
		self.velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func smack():
	camera.shake(20.0, 1.0)
	var spawned_explosion = explosion.instantiate()
	spawned_explosion.position = self.position
	spawned_explosion.emitting = true
	get_parent().add_child(spawned_explosion)
