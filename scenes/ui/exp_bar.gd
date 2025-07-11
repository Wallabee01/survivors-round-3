extends CanvasLayer

@export var exp_manager: Node

@onready var progress_bar:ProgressBar = %ProgressBar


func _ready():
	progress_bar.value = 0
	exp_manager.exp_updated.connect(on_exp_updated)


func on_exp_updated(current_exp, target_exp):
	if target_exp == 0: return
	
	var percent = current_exp / target_exp
	progress_bar.value = percent
