extends CharacterBody2D

@onready var explosion = preload("res://prefabs/explosion.tscn")
@onready var camera = $player_camera
@onready var puzzle_camera = $"../puzzles/puzzle_camera"
@onready var animation = $player_sprite
@onready var puzzles = get_node("/root/main_level/puzzles")
var speed = 300.0
@export var spawn_position := Vector2(350, 200)
var can_start_puzzle = false
var is_puzzling = false
var current_puzzle = null
var can_swap = true
var state = "brain"
var zoomed = false
var current_door = null

var door_positions = {
	"door1" : Vector2(2800,400),
	"returndoor1" : Vector2(980,400)
	
}
signal summon_puzzle
func _ready():
	puzzle_camera.enabled = false
	camera.enabled = true
	animation.play("brain")

func _physics_process(_delta: float) -> void:
	if current_door != null:
		if Input.is_action_just_pressed("ZOOM"):
			if not zoomed:
				$animation_player.stop()
				$animation_player.play("camera_zoom")
				zoomed = true
				await get_tree().create_timer(0.75).timeout
				self.position = door_positions[current_door]
				await get_tree().create_timer(0.75).timeout
				zoomed = false
	if Input.is_action_just_pressed("interact") and not is_puzzling:
		if can_start_puzzle and current_puzzle != null:
			can_start_puzzle = false
			is_puzzling = true
			puzzle_camera.enabled = true
			camera.enabled = false
			summon_puzzle.emit(str(current_puzzle), str(state))

	if not is_puzzling and not zoomed:
		if Input.is_action_just_pressed("smack") and can_swap:
			can_swap = false
			$swap_timer.start(1.2)
			if state == "brain":
				state = "brawn"
				speed = 500.0
				animation.play("brawn_idle")
				animation.flip_v = false
			elif state == "brawn":
				state = "brain"
				animation.play("brain_idle")
				speed = 300.0
				animation.flip_v = true
			smack()

		var direction_horizontal := Input.get_axis("left", "right")
		velocity.x = direction_horizontal * speed if direction_horizontal else move_toward(velocity.x, 0, speed)

		var direction_vertical := Input.get_axis("up", "down")
		velocity.y = direction_vertical * speed if direction_vertical else move_toward(velocity.y, 0, speed)
	else:
		self.velocity.y = move_toward(velocity.y, 0, speed)
		self.velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func entered_door(door):
	current_door = door
	if door:
		$"../UI/open_door".show()
	else:
		$"../UI/open_door".hide()

func smack():
	camera.shake(20.0, 1.0)
	var spawned_explosion = explosion.instantiate()
	spawned_explosion.position = self.position
	spawned_explosion.emitting = true
	get_parent().add_child(spawned_explosion)


func _on_swap_timer_timeout() -> void:
	can_swap = true
