extends CanvasLayer

signal transitioned_halfway


func transition_to_scene(scene_name: String):
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file(scene_name)


func transition():
	$ColorRect.visible = true
	$AnimationPlayer.play("default")
	await $AnimationPlayer.animation_finished
	transitioned_halfway.emit()
	$AnimationPlayer.play_backwards("default")
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false
