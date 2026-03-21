extends Node2D

var random_number = []
var stage = 1
var can_input = false
var number_buttons = []

func _ready() -> void:
	for i in range(7):
		random_number.append(randi_range(0, 9))
	print(random_number)
	number_buttons.resize(10)
	number_buttons[0] = $button10
	number_buttons[1] = $button
	number_buttons[2] = $button2
	number_buttons[3] = $button3
	number_buttons[4] = $button4
	number_buttons[5] = $button5
	number_buttons[6] = $button6
	number_buttons[7] = $button7
	number_buttons[8] = $button8
	number_buttons[9] = $button9
	
	$button.pressed.connect(add_digit.bind(1))
	$button2.pressed.connect(add_digit.bind(2))
	$button3.pressed.connect(add_digit.bind(3))
	$button4.pressed.connect(add_digit.bind(4))
	$button5.pressed.connect(add_digit.bind(5))
	$button6.pressed.connect(add_digit.bind(6))
	$button7.pressed.connect(add_digit.bind(7))
	$button8.pressed.connect(add_digit.bind(8))
	$button9.pressed.connect(add_digit.bind(9))
	$button10.pressed.connect(add_digit.bind(0))
	$delete.pressed.connect(_on_delete_pressed)
	$replay.pressed.connect(_on_replay_pressed)
	
	show_sequence()

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
	$line_edit.text += str(digit)
	await get_tree().create_timer(0.5).timeout
	number_buttons[digit].disabled = true
	_reveal_next_digit(index + 1)

func add_digit(digit: int) -> void:
	if not can_input:
		return
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
		if stage == 7:
			$"../number_puzzle".modulate = Color.BLUE
			print("nice")
		else:
			can_input = false
			await flash_color(Color.GREEN)
			stage += 1
			await get_tree().create_timer(0.5).timeout
			show_sequence()
	else:
		print("bad")
		can_input = false
		await flash_color(Color.RED)
		show_sequence()

func _on_delete_pressed() -> void:
	if not can_input:
		return
	$line_edit.text = ""

func _on_replay_pressed() -> void:
	show_sequence()
