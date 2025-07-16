extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10

var current_health: float


func _ready():
	current_health = max_health


func damage(number: float):
	current_health = max(current_health - number, 0)
	health_changed.emit()
	health_decreased.emit()
	Callable(check_death).call_deferred()


func get_health_percent():
	if max_health <= 0: return 0
	
	return min(current_health / max_health, 1)


func add_health(health_added: float):
	if current_health != max_health:
		current_health += min(health_added, max_health)
		health_changed.emit()


func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
