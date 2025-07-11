extends Node

const SPAWN_RADIUS = 360
const MIN_SPAWN_TIME = 0.3

@export var basic_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer: Timer = $Timer

var base_spawn_time = 0


func _ready():
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func on_timer_timeout():
	timer.start()
	
	var enemy = basic_enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group('entities_layer')
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_decrease = (.1 / 12) * arena_difficulty
	time_decrease = min(time_decrease, 0.7)
	timer.wait_time = base_spawn_time - time_decrease


func get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null: return Vector2.ZERO
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position = Vector2.ZERO
	
	for i in 4:
		#TAU is 2 pi, or 360 degrees
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		
		#1 << 0 is a bit shift, we want collision layer 1 so we are shifting it 0, but if we wanted layer 19 for instance, we could do 1 << 19
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty(): break #no collision
		else: random_direction = random_direction.rotated(deg_to_rad(90)) #collision, rotate ray by 90 degrees and check again
	
	return spawn_position
