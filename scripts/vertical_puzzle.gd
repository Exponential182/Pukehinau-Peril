extends Node2D
@onready var win_area = $win_area
@onready var progress_bar = $bar/ProgressBar
@onready var bar = $bar
@onready var offset = $bar/ProgressBar.position
var in_range = false
var speed = 10
var direction = 1
var min_height = 0
var max_height = 1080
var min_win = 450
var max_win = 630
var base_speed = 10
var shake_strength = 0.0
var shake_duration = 0.0
var shake_timer = 0.0
var rand_scale = 0.1
var original_offset = Vector2(1470,530)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# speed = spee


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		$bar.scale =  Vector2(1,1) + Vector2(rand_scale,rand_scale
		) * shake_strength/35 * (shake_timer / shake_duration)
		$bar.rotation_degrees = 0 + randf_range(-1, 1) * shake_strength * (shake_timer / shake_duration)
	else:
		offset = Vector2.ZERO
	win_area.position.y += speed * direction
	var area_position = win_area.position.y
	if min_height > area_position or max_height < area_position:
		direction *= -1
	if Input.is_action_just_pressed("smack"):
		speed = 0
		var win_position = win_area.position.y
		in_range = false
		if min_win < win_position and win_position < max_win:
			in_range = true
		if in_range:
			progress_bar.value = (progress_bar.value * 1.1) + 1
			shake(0.5 * progress_bar.value, 1.0)
		else:
			progress_bar.value *= 0.9
		await get_tree().create_timer(0.5).timeout
		speed = base_speed + (base_speed*progress_bar.value/100)
	
func shake(strength: float, duration: float):
	if progress_bar.value > 50:
		rand_scale = (0.01*(progress_bar.value-50))
		shake_strength = strength
		shake_duration = duration
		shake_timer = duration
		original_offset = Vector2(1470,530) + offset
