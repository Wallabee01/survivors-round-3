extends Node

const BASE_RANGE := 100
const BASE_DAMAGE := 15

@export var anvil_scene: PackedScene
@export var base_damage = 5
@export var anvil_damage_upgrade_percent = 0.1

var anvil_count = 1
var additional_damage_percent = 1


func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return
	
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation_degrees = 360.0 / (anvil_count)
	
	for i in anvil_count:
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * randf_range(0, BASE_RANGE))

		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)

		if !result.is_empty():
			spawn_position = result["position"]

		var anvil_instance = anvil_scene.instantiate()
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_instance)
		anvil_instance.global_position = spawn_position
		anvil_instance.hitbox_component.damage = BASE_DAMAGE * additional_damage_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "anvil_count": 
		anvil_count += 1
	elif upgrade.id == "anvil_damage":
		additional_damage_percent = 1 + (current_upgrades["anvil_damage"]["quantity"] * anvil_damage_upgrade_percent)
