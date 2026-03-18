extends Node2D
var dialogues = { 
	"intro" : [
"Man, it's so dark in here.",
"I should probably turn the lights on...",],
	"locked_door" : ["Looks like they went home for the day"],
	"wrong_player" : ["I'm not sure if I'm the right man for this job..."]
	
}
var visible_characters = 0
var state = "new_text"
var max_characters = 10
var text_stages = 1
var current_stage = 0
var current_dialogue = "intro"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		change_text()

	if $text.visible_characters < max_characters and state == "typing":
		$text.visible_characters += 1
	elif $text.visible_characters >= max_characters:
		state = "finished"
	

func change_text():
	if current_dialogue:
		if state == "typing":
			$text.visible_characters = max_characters
		if state == "new_text":
			self.show()
			$"../../player".texting = true
			$"../../player".velocity = Vector2.ZERO
			$"../../player".animation.play(str($"../../player".state) + "_idle")
			state = "typing"
			current_stage = 0
			$text.text = dialogues[current_dialogue][0]
			$text.visible_characters = 0
			max_characters = dialogues[current_dialogue][0].length()
			text_stages = (dialogues[current_dialogue].size() -1)
		elif state == "finished":
			if current_stage == text_stages:
				state = "new_text"
				$text.visible_characters = 0
				self.hide()
				await get_tree().create_timer(0.25).timeout
				$"../../player".texting = false

			else:
				current_stage += 1
				state = "typing"
				$text.text = dialogues[current_dialogue][current_stage]
				$text.visible_characters = 0
				max_characters = dialogues[current_dialogue][current_stage].length()
