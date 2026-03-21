extends Node2D

var random_number = []
var stage = 1
var can_input = false
var number_buttons = []

signal number_puzzle_completed

func _ready() -> void:
	number_puzzle_completed.connect(get_parent().number_puzzle_completed)
	for i in range(8):
		random_number.append(randi_range(0, 9))
	number_buttons = [$button10,$button,$button2,$button3,$button4,$button5,$button6,$button7,$button8,$button9]
	var all_buttons = number_buttons + [$delete, $replay]
	for btn in all_buttons:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
	show_sequence()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_0, KEY_KP_0: add_digit(0)
			KEY_1, KEY_KP_1: add_digit(1)
			KEY_2, KEY_KP_2: add_digit(2)
			KEY_3, KEY_KP_3: add_digit(3)
			KEY_4, KEY_KP_4: add_digit(4)
			KEY_5, KEY_KP_5: add_digit(5)
			KEY_6, KEY_KP_6: add_digit(6)
			KEY_7, KEY_KP_7: add_digit(7)
			KEY_8, KEY_KP_8: add_digit(8)
			KEY_9, KEY_KP_9: add_digit(9)
			KEY_BACKSPACE: _on_delete_pressed()
			KEY_R: _on_replay_pressed()

func play_beep(digit: int) -> void:
	$beep.stop()
	$beep.pitch_scale = 0.5 + (digit * 0.1)
	$beep.play()

func flash_color(color: Color) -> void:
	$"../number_puzzle".modulate = color
	await get_tree().create_timer(0.5).timeout
	$"../number_puzzle".modulate = Color.WHITE

func set_buttons_disabled(disabled: bool) -> void:
	for btn in number_buttons:
		btn.disabled = disabled
	$delete.disabled = disabled

func show_sequence() -> void:
	can_input = false
	$replay.disabled = true
	set_buttons_disabled(true)
	$line_edit.text = ""
	_reveal_next_digit(0)

func _reveal_next_digit(index: int) -> void:
	if index >= stage:
		await get_tree().create_timer(1.0).timeout
		$line_edit.text = ""
		can_input = true
		$replay.disabled = false
		set_buttons_disabled(false)
		return
	var digit = random_number[index]
	number_buttons[digit].disabled = false
	play_beep(digit)
	$line_edit.text += str(digit)
	await get_tree().create_timer(0.5).timeout
	number_buttons[digit].disabled = true
	_reveal_next_digit(index + 1)

func add_digit(digit: int) -> void:
	if not can_input:
		return
	play_beep(digit)
	$line_edit.text += str(digit)
	if $line_edit.text.length() >= stage:
		check_input()

func check_input() -> void:
	if not can_input:
		return
	var correct = ""
	for i in range(stage):
		correct += str(random_number[i])
	if $line_edit.text == correct:
		if stage == 8:
			$"../number_puzzle".modulate = Color.WHITE
			$ending.show()
			number_puzzle_completed.emit()
		else:
			can_input = false
			await flash_color(Color.GREEN)
			stage += 1
			await get_tree().create_timer(0.5).timeout
			show_sequence()
	else:
		can_input = false
		await flash_color(Color.RED)
		show_sequence()

func _on_delete_pressed() -> void:
	if not can_input:
		return
	$line_edit.text = ""

func _on_replay_pressed() -> void:
	show_sequence()

func _on_button_hover(btn: Button) -> void:
	btn.scale = Vector2(1.035, 1.035)

func _on_button_unhover(btn: Button) -> void:
	btn.scale = Vector2(1.0, 1.0)


func _on_good_pressed() -> void:
	number_puzzle_completed.emit("good")
	self.queue_free()


func _on_bad_pressed() -> void:
	number_puzzle_completed.emit("bad")
	self.queue_free()
