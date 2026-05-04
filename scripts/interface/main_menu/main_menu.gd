extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var fade_rect: ColorRect = $ui/anim_fade

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	fade_rect.visible = true
	
	anim_player.play("open")
	
	await anim_player.animation_finished
	anim_player.play("quit")

func play_pressed():
	anim_player.play("start")
	await anim_player.animation_finished
	
	get_tree().change_scene_to_file("res://scenes/scenes_gameplay/playable_circus.tscn")

func quit_pressed():
	get_tree().quit()

func eg_pressed():
	get_tree().change_scene_to_file("res://scenes/scenes_gameplay/easter_scare.tscn")
