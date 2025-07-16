extends CanvasLayer


func _ready():
	$AnimationPlayer.play("RESET")
	
	GameEvents.player_damaged.connect(on_player_damaged)


func on_player_damaged():
	$AnimationPlayer.play("hit")
