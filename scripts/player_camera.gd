extends Camera2D
var shake_strength = 0.0
var shake_duration = 0.0
var shake_timer = 0.0
var original_offset = Vector2.ZERO

func shake(strength: float, duration: float):
	shake_strength = strength
	shake_duration = duration
	shake_timer = duration
	original_offset = offset

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		offset = original_offset + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength * (shake_timer / shake_duration)
	else:
		offset = original_offset
