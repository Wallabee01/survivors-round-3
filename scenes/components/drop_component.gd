extends Node

@export var health_component: Node
@export var drop_scene: PackedScene
@export_range(0, 1) var drop_percent: float = 0.5


func _ready():
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	var adjusted_drop_percent = drop_percent
	var exp_gain_upgrade_count = MetaProgression.get_upgrade_count("exp_gain")
	if exp_gain_upgrade_count > 0:
		adjusted_drop_percent = adjusted_drop_percent + (exp_gain_upgrade_count * 0.1)
	
	if randf() > adjusted_drop_percent: return
	if drop_scene == null: return
	if not owner is Node2D: return
	
	var spawn_position = (owner as Node2D).global_position
	var drop_instance = drop_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group('entities_layer')
	entities_layer.add_child(drop_instance)
	drop_instance.global_position = spawn_position
