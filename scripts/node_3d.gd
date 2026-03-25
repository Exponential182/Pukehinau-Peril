extends Node3D

var transitioning := false
var speed = 2
var can_speed = true

func _ready():
	Global.game_active = false
	$UI/time.text = Global.time_string()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("smack") and can_speed:
		speed = 2
	else:
		speed = 1
	$scrolltext.position.y += delta * speed
	$audio_stream_player_3d.pitch_scale = 1* speed
	if $scrolltext.position.y > 58 and not transitioning:
		transitioning = true
		can_speed = false
		$animation_player.play("fade")
		$UI/label.hide()
		Global.game_complete = true
		await $animation_player.animation_finished
		get_tree().change_scene_to_file("res://prefabs/main_menu.tscn")
