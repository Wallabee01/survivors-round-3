extends CharacterBody2D

const UPGRADE_SPEED_PERCENT = 0.1

@export var arena_time_manager: Node

@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var health_bar: ProgressBar = $HealthBar
@onready var abilities: Node = $Abilities
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var random_stream_player_2d_component = $RandomStreamPlayer2DComponent

var num_colliding_bodies = 0
var base_speed = 0


func _ready():
	base_speed = velocity_component.max_speed
	
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	$DamageArea2D.body_entered.connect(on_body_entered)
	$DamageArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_decreased.connect(on_health_decreased)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_bar()


func _process(_delta):
	var movement_vector = get_movement_vector()
	#normalized() sets vector to a length between 0.0 and 1.0
	var direction = movement_vector.normalized()
	
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play('walk')
	else:
		animation_player.play('RESET')
	
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func get_movement_vector():
	var x_movement = Input.get_action_strength('move_right') - Input.get_action_strength('move_left')
	var y_movement = Input.get_action_strength('move_down') - Input.get_action_strength('move_up')
	
	return Vector2(x_movement, y_movement)


func check_deal_damage():
	if num_colliding_bodies == 0 || !damage_interval_timer.is_stopped(): return
	
	health_component.damage(1)
	damage_interval_timer.start()

#Call check_deal_damage on timer.timeout again in case body hasn't exited yet
func on_damage_interval_timer_timeout():
	check_deal_damage()


func update_health_bar():
	health_bar.value = health_component.get_health_percent()


func on_health_decreased():
	GameEvents.emit_player_damaged()
	update_health_bar()
	random_stream_player_2d_component.play_random()


func on_body_entered(_other_body: Node2D):
	num_colliding_bodies += 1
	check_deal_damage()


func on_body_exited(_other_body: Node2D):
	num_colliding_bodies -= 1


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		abilities.add_child((ability_upgrade as Ability).ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * UPGRADE_SPEED_PERCENT)


func on_arena_difficulty_increased(difficulty: int):
	var health_regen_quantity = MetaProgression.get_upgrade_count("health_regen")
	if health_regen_quantity > 0:
		var is_thirty_second_interval = (difficulty % 6) == 0
	
		if is_thirty_second_interval:
			health_component.add_health(health_regen_quantity)
			update_health_bar()
