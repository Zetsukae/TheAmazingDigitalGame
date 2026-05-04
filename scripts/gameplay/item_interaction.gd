extends Node3D

@export var interaction_label: Label3D
@export var height_offset: float = 1.5

var is_player_inside: bool = false
var current_area: Area3D = null 

var item_already_taken: bool = false 

func _ready() -> void:
	if interaction_label:
		interaction_label.hide()
	
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_area_entered.bind(child))
			child.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node3D, area: Area3D) -> void:
	if item_already_taken: 
		return
		
	if body.is_in_group("Player") or body.name == "Player":
		is_player_inside = true
		current_area = area
		if interaction_label:
			interaction_label.global_position = area.global_position + Vector3(0, height_offset, 0)
			interaction_label.show()

func _input(event):
	if item_already_taken:
		return

	if is_player_inside and event.is_action_pressed("interact"):
		item_already_taken = true 
		
		if interaction_label:
			interaction_label.hide()
		
		if current_area:
			print("Item-taken ! You cant take more item.")
			current_area.queue_free()
		
		is_player_inside = false
		current_area = null

func _on_area_exited(body: Node3D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		is_player_inside = false
		current_area = null
		if interaction_label:
			interaction_label.hide()
