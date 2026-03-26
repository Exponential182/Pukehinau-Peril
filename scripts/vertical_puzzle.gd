extends Node2D
@onready var win_area = $canvas_layer/win_area
@onready var progress_bar = $canvas_layer/bar/ProgressBar
@onready var bar = $lightbulb
@onready var offset = $canvas_layer/bar/ProgressBar.position
@onready var combo_counter = $canvas_layer/combo_counter
@onready var combo_text = $canvas_layer/combo_counter/combo_count
@onready var combo_timer = $canvas_layer/combo_timer
@onready var speed_timer = $canvas_layer/speed_timer
@onready var win = $canvas_layer/win
var in_range = false
var speed = 15
var direction = 1
var min_height = 122
var max_height = 974
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
var done_switch = false
var state = "paused"
signal vertical_puzzle_completed

func _ready() -> void:
	
	vertical_puzzle_completed.connect(get_parent().vertical_puzzle_completed)

func _physics_process(delta: float) -> void:
	if state == "playing":
		if progress_bar.value > 0.1:
			progress_bar.value -= wait * 0.03 * (1+0.1*wait)
			$lightbulb/point_light_2d.energy = 0.5 + progress_bar.value/100
			$lightbulb/point_light_2d.scale = Vector2(1 + progress_bar.value/100,1 + progress_bar.value/100)
			pass
		else:
			$canvas_layer/fail.show()
			$canvas_layer/combo_counter.hide()
			state = "paused"
			can_combo = false
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
		if Input.is_action_just_pressed("smack") and can_combo or Input.is_action_just_pressed("interact") and can_combo:
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
				color_flash(Color("green"))
				$combo.play()
				$combo.pitch_scale = 0.5 + (combo * 0.1)
				combo += 1
				var progress_adition = combo_multiplier * 4 + 5
				progress_bar.value += progress_adition
				shake(progress_bar.value * combo_multiplier * 0.2, 1.0)
				if progress_bar.value >=99.9 and not done_switch:
					$combo.stop()
					$done.play()
					done_switch = true
					await get_tree().create_timer(2).timeout
					vertical_puzzle_completed.emit()
					self.queue_free()
			else:
				color_flash(Color("red"))
				$combo.play()
				$combo.pitch_scale = 0.35
				progress_bar.value -= 10
				combo = 0
				combo_multiplier = 1
			combo_text.text = "COMBO\nX" + str(combo)
			speed_timer.start(0.5)
		$canvas_layer/score/score.text = str(round(progress_bar.value*10)/10)
func shake(strength: float, duration: float):
	if combo > 2:
		rand_scale = (0.005*(progress_bar.value))
		shake_strength = strength
		shake_duration = duration
		shake_timer = duration
		original_offset = Vector2(1470,530) + offset

func color_flash(color:Color):
	$lightbulb/point_light_2d.energy = 0.5 + progress_bar.value/100
	$lightbulb/point_light_2d.color = color
	await get_tree().create_timer(0.5).timeout
	$lightbulb/point_light_2d.color = "white"
	
func _on_combo_timer_timeout() -> void:
	can_combo = true

func _on_speed_timer_timeout() -> void:
	speed = base_speed * combo_multiplier


func _on_button_pressed() -> void:
	state = "playing"
	$canvas_layer/fail.hide()
	$canvas_layer/combo_counter.show()
	$canvas_layer/fail/Tutorial.show()
	$canvas_layer/fail/button.text = "Retry"
	progress_bar.value = 20
	wait = 0
	combo = 0
	can_combo = true
	
