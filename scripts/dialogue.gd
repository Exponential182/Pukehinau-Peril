extends Node2D
var rodkiss_dialogues = {
	"rodkiss_1" : preload("res://assets/SFX/pukehinau_peril_audio/whosentyou-[AudioTrimmer.com].mp3"),
	"rodkiss_2" : preload("res://assets/SFX/pukehinau_peril_audio/finishedalready-[AudioTrimmer.com].mp3"),
	"rodkiss_3" : preload("res://assets/SFX/pukehinau_peril_audio/youdidwhat-[AudioTrimmer.com].mp3"),
	"rodkiss_good" : preload("res://assets/SFX/pukehinau_peril_audio/thinkofthat-[AudioTrimmer.com].mp3"),
	"rodkiss_bad" : preload("res://assets/SFX/pukehinau_peril_audio/serverfixed-[AudioTrimmer.com].mp3"),
	"rodkiss_4" : preload("res://assets/SFX/pukehinau_peril_audio/gohome-[AudioTrimmer.com].mp3")
}
var dialogues = { 
	"intro" : [
"In the depths of Pukehinau, long after the cleaners went home, a single teacher is trapped, drowning in hundreds of assessments handed in at the last minute.",
"His name?                                                                
Mr. Rodkiss.",
"Your goal is to solve puzzles and save Mr. Rodkiss from the effort of marking all the tests.",
"It may sound impossible, but you do have ONE TRICK up your sleeve.
You can change between BRAINS and BRAWN at any time by pressing SPACE,
which may help you navigate Pukehinau easier.",
"Controls are in the top right,
Good luck.",
"Man, it's so dark in here.",
"I should probably turn the lights on...",],
	"stop_exploring" : ["I should probably turn the lights on before exploring."],
	"locked_door" : ["Looks like they went home for the day"],
	"wrong_player" : ["I'm not sure if I'm the right person for this job..."],
	"wrong_player2" : ["You'd need someone REALLY SMART to hack into this Admin Computer. Even Mr. Rodkiss can't be bothered."],
	"alt_wrong_player" : ["I'm not sure if I'm the right person for this job..."],
	"alt_wrong_player2" : ["If this was a videogame, I would probably try pressing SPACE once I can move around."],
	"push_or_pull" : ["You can't remember if you're supposed to push or pull this door, so it's probably better to leave it shut."],
	"cant_stop" : ["Don't turn back now, Mr. Rodkiss needs your help!"],
	"rodkiss_1" : ["Who sent you?... Oh, it's you... I've got so much work to mark, I wish it just all disappeared somehow..."],
	"rodkiss_good" :[
	"Oh, I'm finished already? I'm on fire today.",
	"*You tell him what you did*",
	"You did WHAT?",
	"Hmm, why didn't I think of that? I don't think the moderators will be happy though.",
	".                                                          
	..                                                        
	...                                                           
	Well, at least I can go home. See you tomorow!"],
	"rodkiss_bad" : [
"Oh, I'm finished already? I'm on fire today.",
"*You tell him what you did*",
"You did WHAT?",
"... That server’s going to take a whole day to fix, I might get in trouble for that.",
".                                     
..                                      
...                                            
Well, at least I can go home. See you tomorrow!"],
	"final_locked" : ["Looks like the door is locked from the inside, you need a key to enter. (Go back!)"]
}
var visible_ratio = 0
var state = "new_text"
var max_characters = 10
var text_stages = 1
var current_stage = 0
var times_stupid = 0
var rodkiss_speed = 0.32
var current_dialogue = "intro"


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
		$text.visible_ratio += 1 * delta * rodkiss_speed * (characters_per_sec)/(character_limit)
	elif $text.visible_ratio >= 1 and state != "finished":
		state = "finished"
		$"../../animation_player".play("pressE")
		$text2.show()
		$"../../song".stop()
	

func change_text():
	if current_dialogue:
		if state == "typing":
			if rodkiss_speed == 1:
				$text.visible_ratio = 1
				$"../../song".stop()
		if state == "new_text" and not $"../../player".texting:
			if str(current_dialogue)[0] != "r":
				$"../../song".play()
				rodkiss_speed = 1
			else:
				$"../../rodkiss_audio".play()
				if current_dialogue == "rodkiss_1":
					rodkiss_speed = 0.32
				else:
					$"../../rodkiss_audio".stream = rodkiss_dialogues["rodkiss_2"]
					$"../../rodkiss_audio".play()
			$"../../animation_player2".play("enter_puzzle")
			self.show()
			$"../../player".texting = true
			$"../../player".move_texting = false
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
				$"../../player".move_texting = true
				self.hide()
				await get_tree().create_timer(1).timeout
				$"../../player".texting = false
				$"../../animation_player".play("resetE")
				$text2.hide()
				if current_dialogue == "rodkiss_good" or current_dialogue == "rodkiss_bad":
					$"../../animation_player".play("fade_to_black")
					await $"../../animation_player".animation_finished
					get_tree().change_scene_to_file("res://prefabs/credit.tscn")
				else:
					$"../../animation_player2".play("exit_puzzle")
			else:
				current_stage += 1
				state = "typing"
				$text.text = dialogues[current_dialogue][current_stage]
				$text.visible_ratio = 0
				max_characters = dialogues[current_dialogue][current_stage].length()
				$"../../animation_player".play("resetE")
				$text2.hide()
				if current_dialogue == "rodkiss_good" or current_dialogue == "rodkiss_bad":
						if current_stage == 1:
							$"../../song".play()
							rodkiss_speed = 1
						elif current_stage == 2:
								$"../../rodkiss_audio".stream = rodkiss_dialogues["rodkiss_3"]
								$"../../rodkiss_audio".play()
								rodkiss_speed = 0.99
						elif current_stage == 3:
							if current_dialogue == "rodkiss_good":
								$"../../rodkiss_audio".stream = rodkiss_dialogues["rodkiss_good"]
								$"../../rodkiss_audio".play()
								rodkiss_speed = 0.32
							elif current_dialogue == "rodkiss_bad":
								$"../../rodkiss_audio".stream = rodkiss_dialogues["rodkiss_bad"]
								$"../../rodkiss_audio".play()
								rodkiss_speed = 0.32
						elif current_stage == 4:
								$"../../rodkiss_audio".stream = rodkiss_dialogues["rodkiss_4"]
								rodkiss_speed = 0.99
								await get_tree().create_timer(2.2).timeout
								$"../../rodkiss_audio".play()
								rodkiss_speed = 0.32
								
				else:
					$"../../song".play()
