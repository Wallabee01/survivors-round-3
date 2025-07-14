extends CharacterBody2D
class_name Enemy

@onready var visuals: Node2D = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var random_stream_player_2d_component = $RandomStreamPlayer2DComponent


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(_delta):
	move()


func move():
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)


func on_hit():
	random_stream_player_2d_component.play_random()
