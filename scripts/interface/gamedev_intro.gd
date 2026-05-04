extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$VideoStreamPlayer.finished.connect(_on_video_finished)

func _on_video_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/scenes_UI/main_menu.tscn")
