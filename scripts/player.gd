extends CharacterBody2D

@onready var explosion = preload("res://prefabs/explosion.tscn")
@onready var camera = $player_camera
const SPEED = 300.0
@export var spawn_position := Vector2(350, 200)
var can_start_puzzle = false
var is_puzzling = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	position = spawn_position

func _ready():
	if not is_multiplayer_authority(): return
	$player_camera.enabled = true

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return

	if Input.is_action_just_pressed("interact"):
		if can_start_puzzle:
			var my_id := get_multiplayer_authority()
			var puzzle_manager = get_node("/root/game_manager/main_level/puzzlemanager")
			if multiplayer.is_server():
				puzzle_manager.request_puzzle_start(my_id)
			else:
				puzzle_manager.request_puzzle_start.rpc_id(1, my_id)
	if not is_puzzling:
		if Input.is_action_just_pressed("smack"):
			smack()

		var direction_horizontal := Input.get_axis("left", "right")
		velocity.x = direction_horizontal * SPEED if direction_horizontal else move_toward(velocity.x, 0, SPEED)

		var direction_vertical := Input.get_axis("up", "down")
		velocity.y = direction_vertical * SPEED if direction_vertical else move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func smack():
	camera.shake(20.0, 1.0)
	var spawned_explosion = explosion.instantiate()
	spawned_explosion.position = self.position
	spawned_explosion.emitting = true
	get_parent().add_child(spawned_explosion)
