extends Button
class_name SoundButton

func _ready():
	pressed.connect(on_pressed)


func on_pressed():
	$RandomAudioStreamPlayerComponent.play_random()
