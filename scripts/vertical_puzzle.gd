extends Node2D
@onready var win_area = $win_area
@onready var progress_bar = $bar/ProgressBar
@onready var bar = $bar
@onready var offset = $bar/ProgressBar.position
@onready var combo_counter = $combo_counter
@onready var combo_text = $combo_counter/combo_count
@onready var combo_timer = $combo_timer
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
var combo = 0
var can_combo = true
var combo_multiplier = 1


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
		$bar.rotation_degrees = 0 + randf_range(-1, 1) * 0.5 * shake_strength * (shake_timer / shake_duration)
	else:
		offset = Vector2.ZERO
	win_area.position.y += speed * direction
	var area_position = win_area.position.y
	if min_height > area_position or max_height < area_position:
		direction *= -1
	if Input.is_action_just_pressed("smack") and can_combo:
		combo_multiplier = 1 + (0.1*combo)
		can_combo = false
		combo_timer.start(0.7)
		speed = 0
		var win_position = win_area.position.y
		in_range = false
		if min_win < win_position and win_position < max_win:
			in_range = true
		if in_range:
			combo += 1
			var progress_adition = combo_multiplier * (0.1 * progress_bar.value + 1) + 4
			print(progress_adition)
			progress_bar.value += progress_adition
			shake(0.5 * progress_bar.value * combo_multiplier, 1.0)
			if progress_bar.value >= 100:
				$win.show()
				await get_tree().create_timer(5).timeout
				get_tree().reload_current_scene()
		else:
			progress_bar.value *= 0.9
			combo = 0
		combo_text.text = "COMBO
		X" + str(combo)
		$speed_timer.start(0.5)


		
	
func shake(strength: float, duration: float):
	if combo > 2:
		rand_scale = (0.01*(progress_bar.value-50))
		shake_strength = strength
		shake_duration = duration
		shake_timer = duration
		original_offset = Vector2(1470,530) + offset


func _on_combo_timer_timeout() -> void:
	can_combo = true


func _on_speed_timer_timeout() -> void:
	speed = base_speed * combo_multiplier * 3
