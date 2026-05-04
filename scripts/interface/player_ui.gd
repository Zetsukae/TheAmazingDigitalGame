extends Control

@export var link: String
@export var Slink: String
@export var Elink: String
@onready var pause_menu: CanvasLayer = $pause_menu
@onready var controls: CanvasLayer = $controls
@onready var htp: CanvasLayer = $howToPlay

func _ready() -> void:
	pause_menu.visible = false
	controls.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if controls.visible:
			back_pressed()
		elif htp.visible:
			back_pressed()
		else:
			toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	
	pause_menu.visible = new_pause_state
	if not new_pause_state:
		controls.visible = false
		htp.visible = false
	
	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func controls_pressed():
	pause_menu.visible = false
	controls.visible = true
	htp.visible = false

func back_pressed():
	pause_menu.visible = true
	controls.visible = false
	htp.visible = false

func resume_pressed():
	toggle_pause() 

func main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/scenes_UI/main_menu.tscn")

func quit_pressed():
	get_tree().quit()

func youtube_button():
	OS.shell_open(link)

func website_button():
	OS.shell_open(Slink)

func source_button():
	OS.shell_open(Elink)

func htp_pressed():
	pause_menu.visible = false
	controls.visible = false
	htp.visible = true
