extends CharacterBody2D

@onready var explosion = preload("res://prefabs/explosion.tscn")
@onready var camera = $player_camera
const SPEED = 300.0

@export var spawn_position := Vector2(350, 200)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
	position = spawn_position

func _ready():
	if not is_multiplayer_authority(): return
	
	$player_camera.enabled = true

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("smack"):
		smack()

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

func smack():
	camera.shake(20.0,1.0)
	var spawned_explosion = explosion.instantiate()
	spawned_explosion.position = self.position
	spawned_explosion.emitting = true
	get_parent().add_child(spawned_explosion)
	
