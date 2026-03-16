extends Node2D
var dialogues = { 
	"intro" : [
"Student is present in class Student is in the sick bay Student has a study period Student is in an examination Student is participating in a school activity (whether on site, like a sports day, or off site, like a camp or school trip) Student is on work experience Student has been internally stood down (ie, removed from class but still at school) Student is attending a Secondary Tertiary Programme Student is attending Alternative Education",
"SOMETHINGSDHLKJH KLJHSDF KJHDS FLKDSHF LKDS HFLKDSJ FHLKSD FHLKDSJF HDYFOWHDLK EJHFLKWJ HDLKJF HELWKJ HDLFIEUWFNIUDHWLFIEHWLFKJDWFL",
"akdljfhkjl a kdjfshlk lkajsehf ekjw halkjsdhf  qeafwasdf"],
	"locked_door" : ["Looks like they went home for the day"]
	
}
var visible_characters = 0
var state = "new_text"
var max_characters = 10
var text_stages = 1
var current_stage = 0
var current_dialogue = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
				await get_tree().create_timer(0.2).timeout
				$"../../player".texting = false
			else:
				current_stage += 1
				state = "typing"
				$text.text = dialogues[current_dialogue][current_stage]
				$text.visible_characters = 0
				max_characters = dialogues[current_dialogue][current_stage].length()
