extends Node3D

@onready var anim_jump:AnimationPlayer = $J4xAnimations/AnimationPlayer
@onready var anim_cam:AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim_jump.play("jumpscare")
	anim_cam.play("jumpscare")
	await anim_cam.animation_finished
	get_tree().change_scene_to_file("res://scenes/scenes_UI/main_menu.tscn")
