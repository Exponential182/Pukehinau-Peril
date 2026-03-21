extends Node2D
var dialogues = { 
	"intro" : [
"In the depths of Pukehinau, long after the cleaners went home, a single teacher is trapped, drowning in hundreds of assessments handed in at the last minute.",
"His name?                                                                
Mr. Rodkiss.",
"Your goal is to solve puzzles and save Mr. Rodkiss from the effort of marking all the tests.",
"It may sound impossible, but you do have ONE TRICK up your sleeve.
You can change between BRAINS and BRAWN at any time by pressing SPACE,
which may help you navigate Pukehinau easier.",
"Good luck.",
"Man, it's so dark in here.",
"I should probably turn the lights on...",],
	"shortened_intro" : ["I should probably turn the lights on before exploring."],
	"locked_door" : ["Looks like they went home for the day"],
	"wrong_player" : ["I'm not sure if I'm the right person for this job..."],
	"wrong_player2" : ["If this was a videogame, I would probably try pressing SPACE once I can move around."],
	"alt_wrong_player" : ["I'm not sure if I'm the right person for this job..."],
	"alt_wrong_player2" : ["If this was a videogame, I would probably try pressing SPACE once I can move around."],

}
var visible_ratio = 0
var state = "new_text"
var max_characters = 10
var text_stages = 1
var current_stage = 0
var times_stupid = 0
var current_dialogue = "shortened_intro"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		change_text()
	var characters_per_sec = 50
	var character_limit = clamp(max_characters,50,150)
	if $text.visible_ratio < 1 and state == "typing":
		$text.visible_ratio += 1 * delta * (characters_per_sec)/(character_limit)
	elif $text.visible_ratio >= 1 and state != "finished":
		state = "finished"
		$"../../animation_player".play("pressE")
		$text2.show()
	

func change_text():
	if current_dialogue:
		if state == "typing":
			$text.visible_ratio = 1
		if state == "new_text":
			self.show()
			$"../../player".texting = true
			$"../../player".velocity = Vector2.ZERO
			$"../../player".animation.play(str($"../../player".state) + "_idle")
			state = "typing"
			current_stage = 0
			$text.text = dialogues[current_dialogue][0]
			$text.visible_ratio = 0
			max_characters = dialogues[current_dialogue][0].length()
			text_stages = (dialogues[current_dialogue].size() -1)
			$"../../animation_player".play("resetE")
			$text2.hide()
		elif state == "finished":
			if current_stage == text_stages:
				state = "new_text"
				$text.visible_ratio = 0
				self.hide()
				await get_tree().create_timer(0.25).timeout
				$"../../player".texting = false
				$"../../animation_player".play("resetE")
				$text2.hide()
			else:
				current_stage += 1
				state = "typing"
				print(current_dialogue)
				$text.text = dialogues[current_dialogue][current_stage]
				$text.visible_ratio = 0
				max_characters = dialogues[current_dialogue][current_stage].length()
				$"../../animation_player".play("resetE")
				$text2.hide()
