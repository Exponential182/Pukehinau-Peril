extends Node2D
@onready var win_area = $canvas_layer/win_area
@onready var progress_bar = $canvas_layer/bar/ProgressBar
@onready var bar = $canvas_layer/bar
@onready var offset = $canvas_layer/bar/ProgressBar.position
@onready var combo_counter = $canvas_layer/combo_counter
@onready var combo_text = $canvas_layer/combo_counter/combo_count
@onready var combo_timer = $canvas_layer/combo_timer
@onready var speed_timer = $canvas_layer/speed_timer
@onready var win = $canvas_layer/win
var in_range = false
var speed = 15
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
var wait = 0
var last_synced_value := 0.0
func _ready() -> void:
	var score_scale = progress_bar.value/100
	$score/score.text = str(round(progress_bar.value*10)/10)
	$score.scale = Vector2(score_scale, score_scale)

func _physics_process(delta: float) -> void:
	if progress_bar.value > 0:
		progress_bar.value -= 0.03 * (1+0.1*wait*wait)
	if shake_timer > 0:
		shake_timer -= delta
		bar.scale = Vector2(1,1) + Vector2(rand_scale,rand_scale) * combo_multiplier * 0.6 * (shake_timer / shake_duration)
		bar.rotation_degrees = 0 + randf_range(-1, 1) * (1.0/combo_multiplier) * shake_strength * (shake_timer / shake_duration)
	else:
		offset = Vector2.ZERO
	win_area.position.y += speed * direction
	var area_position = win_area.position.y
	if min_height > area_position or max_height < area_position:
		direction *= -1
		wait += 1
	if Input.is_action_just_pressed("smack") and can_combo:
		wait = 0
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
			var progress_adition = combo_multiplier * 1 + 10
			progress_bar.value += progress_adition
			shake(progress_bar.value * combo_multiplier * 0.2, 1.0)
		else:
			progress_bar.value *= 0.9
			combo = 0
			combo_multiplier = 1
		combo_text.text = "COMBO\nX" + str(combo)
		speed_timer.start(0.5)
	var score_scale = progress_bar.value/100
	$score/score.text = str(round(progress_bar.value*10)/10)
	$score.scale = Vector2(score_scale, score_scale)
func shake(strength: float, duration: float):
	if combo > 2:
		rand_scale = (0.005*(progress_bar.value))
		shake_strength = strength
		shake_duration = duration
		shake_timer = duration
		original_offset = Vector2(1470,530) + offset

func _on_combo_timer_timeout() -> void:
	can_combo = true

func _on_speed_timer_timeout() -> void:
	speed = base_speed * combo_multiplier
