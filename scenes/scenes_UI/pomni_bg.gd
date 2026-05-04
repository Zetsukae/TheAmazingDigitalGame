extends Node3D

@onready var anim_player:AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var anim = anim_player.get_animation("ArmatureAction")
	anim.loop_mode = Animation.LOOP_LINEAR
	anim_player.play("ArmatureAction")
