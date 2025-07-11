extends Node

@export var end_screen_scene: PackedScene


func _ready():
	%Player.health_component.died.connect(on_player_died)


func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	#_ready() is called when a child is added so when manipulating data on a newly instantiated scene, add it to the scene tree first always
	end_screen_instance.set_defeat()
