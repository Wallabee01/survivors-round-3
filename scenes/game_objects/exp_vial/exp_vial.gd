extends Node2D

const EXP_VALUE = 1

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D


func _ready():
	$Area2D.area_entered.connect(on_area_entered)


func on_area_entered(_other_area: Area2D):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	#Allows multiple tweens to run simutaneously
	tween.set_parallel()
	tween.tween_method(tween_method.bind(global_position), 0.0, 1.0, 1.0)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d, 'scale', Vector2.ZERO, 0.15).set_delay(0.85)
	
	#chain lets the above tweens finish before calling below tweens
	tween.chain()
	tween.tween_callback(collect)
	
	await get_tree().create_timer(0.85).timeout
	$RandomStreamPlayer2DComponent.play_random()


func tween_method(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null: return
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(2 * -get_process_delta_time()))


func collect():
	GameEvents.emit_exp_vial_collected(EXP_VALUE)
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true
