extends Camera2D

const SMOOTHING = 10

var target_position = Vector2.ZERO


func _ready():
	make_current()


func _process(delta):
	acquire_target()
	#Math here is for frame rate independent lerping
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * SMOOTHING))


func acquire_target():
	var player_node = get_tree().get_first_node_in_group('player')
	if player_node != null:
		var player = player_node as Node2D
		target_position = player.global_position
