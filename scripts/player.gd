extends CharacterBody2D

const PUZZLE_BOUNDS = Rect2(Vector2(1956, 256), Vector2(1408, 768))
const BOX_HALF_SIZE = Vector2(64, 64)

@onready var explosion = preload("res://prefabs/explosion.tscn")
@onready var camera = $player_camera
@onready var puzzle_camera = $"../puzzles/puzzle_camera"
@onready var animation = $player_sprite
@onready var puzzles = get_node("/root/main_level/puzzles")
var speed = 500.0
var base_speed = 500.0
var pushing_speed = 300.0
@export var spawn_position := Vector2(350, 200)
var can_start_puzzle = false
var is_puzzling = false
var current_puzzle = null
var can_swap = true
var state = "brawn"
var zoomed = false
var texting = false
var move_texting = false
var current_door = null
var current_door_position = Vector2(0,0)

@export var is_box_puzzle_active = false
var is_pushing_box = false
var pushed_box = null
var last_box = null
var box_puzzle_position = Vector2(1700.0, 0)

var door_positions = {
	"door1" : Vector2(1472,-300),
	"door2" : Vector2(2784,-300),
	"returndoor1" : Vector2(1472,335),
	
}
var door_limits = {
	"door1" : Vector4(510,2430,0,-1220),
	"door2" :Vector4(1824,3744,0,-1728),
	"returndoor1" : Vector4(0,4224,1088,0),
	"returndoor2" : Vector4(0,4224,1088,0),
}
signal summon_puzzle
func _ready():
	puzzle_camera.enabled = false
	camera.enabled = true
	animation.play("brawn_idle")
	$"../world/black".show()
	$"../world/black1".show()
	$"../world/black2".show()
	$"../world/black3".show()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not is_puzzling and not texting:
		if current_door != null:
			enter_door()
		elif can_start_puzzle and current_puzzle != null:
			can_start_puzzle = false
			is_puzzling = true
			puzzle_camera.enabled = true
			camera.enabled = false
			summon_puzzle.emit(str(current_puzzle), str(state))

	if not is_puzzling and not zoomed and can_swap and move_texting:
		if Input.is_action_just_pressed("smack") and can_swap:
			can_swap = false
			velocity = Vector2.ZERO
			$swap_timer.start(1.2)
			animation.offset.x = 1
			if state == "brain":
				state = "brawn"
				base_speed = 500.0
				pushing_speed = 300.0
				if speed == 300.0:
					speed = base_speed
				else:
					speed = pushing_speed
				animation.play("brain_change")
				$"../dialogue_areas/wrong_player/collision_shape_2d".disabled = false
				$"../dialogue_areas/alt_wrong_player/collision_shape_2d".disabled = true
				$"../dialogue_areas/wrong_player2/collision_shape_2d".disabled = false
			elif state == "brawn":
				state = "brain"
				animation.play("brawn_change")
				$"../dialogue_areas/wrong_player/collision_shape_2d".disabled = true
				$"../dialogue_areas/alt_wrong_player/collision_shape_2d".disabled = false
				$"../dialogue_areas/wrong_player2/collision_shape_2d".disabled = true
				speed = 300.0
			smack()
		var direction_horizontal = null
		if Input.is_action_pressed("left") and can_swap and not Input.is_action_pressed("right"):
			velocity.x = speed * -1
			direction_horizontal = "left"
			animation.offset.x = 0
		elif Input.is_action_pressed("right") and can_swap and not Input.is_action_pressed("left"):
			velocity.x = speed * 1
			direction_horizontal = "right"
			animation.offset.x = 0
		else:
			self.velocity.x = move_toward(velocity.x, 0, speed)
		var direction_vertical = null
		if Input.is_action_pressed("up") and can_swap and not Input.is_action_pressed("down"):
			velocity.y = speed * -1
			direction_vertical = "up"
			animation.offset.x = 0
		elif Input.is_action_pressed("down") and can_swap and not Input.is_action_pressed("up"):
			velocity.y = speed * 1
			direction_vertical = "down"
			animation.offset.x = 1
		else:
			self.velocity.y = move_toward(velocity.y, 0, speed)
		if can_swap:
			if direction_horizontal:
				animation.play(str(state) + "_left")
				if direction_horizontal == "right":
					animation.flip_h = true
				else:
					animation.flip_h = false
			elif direction_vertical:
				animation.play(str(state) + "_" + str(direction_vertical))
			if velocity.length() < 0.1:
				animation.play(str(state)+ "_idle")
	
	if last_box:
		$"../UI/interact".show()
	else:
		$"../UI/interact".hide()
	if is_box_puzzle_active:
		box_puzzle_interaction(delta)
		$"../puzzles/box_puzzle/reset_button".show()
		$"../puzzles/box_puzzle/reset_button".disabled = false
	else:
		$"../puzzles/box_puzzle/reset_button".hide()
		$"../puzzles/box_puzzle/reset_button".disabled = true
	move_and_slide()

func entered_door(door,door_position):
	current_door = door
	current_door_position = door_position
	if door:
		$"../UI/interact".show()
	else:
		$"../UI/interact".hide()

func enter_door():
	if not zoomed:
		self.velocity = Vector2.ZERO
		$animation_player.stop()
		var show_black = false
		if str(current_door)[0] == "r":
			$animation_player.play("camera_unzoom")
			animation.play(str(state) + "_down")
			show_black = true
		else:
			$animation_player.play("camera_zoom")
			animation.play(str(state) + "_up")
			$"../world/black3".hide()
			if str(current_door)[4] == "1":
				$"../world/black1".show()
				$"../world/black2".hide()
			else:
				$"../world/black2".show()
				$"../world/black1".hide()
		zoomed = true
		$"../world/doors".find_child(str(current_door)).magical_door_opening()
		await get_tree().create_timer(0.75).timeout
		if current_door == "door2":
			$"../world/lights/main_light".energy = 0.55
		self.position = door_positions[current_door]
		var camera_bounds = door_limits[current_door]
		$player_camera.limit_left = camera_bounds.x
		$player_camera.limit_top = camera_bounds.w
		$player_camera.limit_right = camera_bounds.y
		$player_camera.limit_bottom = camera_bounds.z
		await get_tree().create_timer(0.75).timeout
		zoomed = false
		if show_black:
			$"../world/black3".show()

func smack():
	await get_tree().create_timer(0.8).timeout
	camera.shake(20.0, 1.0)
	var spawned_explosion = explosion.instantiate()
	if state == "brawn":
		spawned_explosion.texture = preload("res://assets/image.png")
	else:
		spawned_explosion.texture = preload("res://assets/Brain_icon.png")
	spawned_explosion.position = self.position
	spawned_explosion.emitting = true
	get_parent().add_child(spawned_explosion)


func _on_swap_timer_timeout() -> void:
	can_swap = true
	animation.play(str(state)+"_idle")


func _box_entered(box):
	last_box = box


func _box_exited():
	if !pushed_box:
		last_box = null

func box_puzzle_interaction(delta):
	if Input.is_action_just_pressed("interact") and last_box:
		is_pushing_box = not is_pushing_box
		if is_pushing_box:
			pushed_box = last_box
			speed = pushing_speed
			pushed_box.modulate = Color("green")
		else:
			pushed_box.modulate = Color("#ffff62")
			pushed_box = null
			speed = base_speed
	
	if pushed_box:
		var player_to_box : Vector2 = (pushed_box.position + box_puzzle_position - self.position)
		if player_to_box.length() >= 145.0:
			speed = base_speed
			pushed_box.modulate = Color("white")
			pushed_box = null
			is_pushing_box = false
		else:
			player_to_box = player_to_box.normalized()
			var input_vector = Input.get_vector("left", "right", "up", "down")
			var angle = abs(acos(player_to_box.dot(input_vector)))
			if (angle >= PI*0.8 or angle <= PI*0.2) and state == "brawn":
				var new_pos = pushed_box.global_position + input_vector * speed * delta
				
				new_pos.x = clamp(new_pos.x, PUZZLE_BOUNDS.position.x + BOX_HALF_SIZE.x, PUZZLE_BOUNDS.end.x - BOX_HALF_SIZE.x)
				new_pos.y = clamp(new_pos.y, PUZZLE_BOUNDS.position.y + BOX_HALF_SIZE.y, PUZZLE_BOUNDS.end.y - BOX_HALF_SIZE.y)
				
				pushed_box.global_position = new_pos

func box_puzzle_started(body):
	if body.name == "player":
		$player_hitbox.shape.size = Vector2(92, 120)
		$player_hitbox.position = Vector2(2, 2)
		is_box_puzzle_active = true


func box_puzzle_ended(body):
	if body.name == "player":
		$player_hitbox.shape.size = Vector2(92, 148)
		$player_hitbox.position = Vector2(2, -9)
		is_box_puzzle_active = false
