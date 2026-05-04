extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const PLUSH_SPEED = 12.0
const JUMP_VELOCITY = 4.5

var stamina : float = 100.0
var max_stamina : float = 100.0
var stamina_consumption : float = 30.0
var stamina_regeneration : float = 15.0
var jump_stamina_cost : float = 20.0
var can_sprint : bool = true

@onready var interact_ray: RayCast3D = $head/Camera3D/InteractionRay
@onready var hand = $head/Camera3D/Hand 
@onready var stamina_bar = get_node('StaminaBar')
@onready var item_label = get_node("player_ui/items/ItemLabel")

var held_item = null 
var stamina_tween : Tween
var is_fading_out : bool = false

func _ready():
	if interact_ray:
		interact_ray.enabled = true
	if item_label:
		item_label.text = "Nothing in Inventory"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		check_interaction()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var has_plush = is_holding_item("plush")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if has_plush or stamina >= jump_stamina_cost:
			velocity.y = JUMP_VELOCITY
			if not has_plush:
				stamina -= jump_stamina_cost
			show_stamina_bar()

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = SPEED
	if has_plush:
		current_speed = PLUSH_SPEED
	
	var is_sprinting = Input.is_action_pressed("sprint") and direction != Vector3.ZERO and (stamina > 0 or has_plush) and can_sprint
	
	if is_sprinting:
		current_speed = PLUSH_SPEED if has_plush else SPRINT_SPEED
		
		if not has_plush:
			stamina -= stamina_consumption * delta
		
		if stamina <= 0 and not has_plush:
			stamina = 0
			can_sprint = false
	else:
		stamina += stamina_regeneration * delta
		if stamina >= max_stamina: stamina = max_stamina
		if stamina >= 40.0: can_sprint = true

	update_stamina_ui(is_sprinting)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func check_interaction():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		
		if target.is_in_group("items"):
			pick_up_item(target)
		elif target.owner and target.owner.is_in_group("items"):
			pick_up_item(target.owner)

func pick_up_item(item):
	if held_item != null: return 

	var root_item = item
	if item is StaticBody3D or item is MeshInstance3D:
		root_item = item.owner
	
	print("item-taken: ", root_item.name)
	held_item = root_item

	if item_label:
		item_label.text = "Item(s) in inventory : " + root_item.name.capitalize()

	root_item.reparent(hand)
	root_item.position = Vector3.ZERO
	root_item.rotation = Vector3.ZERO
	
	for child in root_item.find_children("*", "CollisionShape3D", true):
		child.disabled = true

func show_stamina_bar():
	is_fading_out = false
	if stamina_tween: stamina_tween.kill()
	stamina_bar.modulate.a = 1.0
	stamina_bar.visible = true

func update_stamina_ui(is_sprinting: bool) -> void:
	if not stamina_bar: return
	
	if is_holding_item("plush"):
		stamina_bar.value = max_stamina
		stamina_bar.modulate = Color(0, 1, 1)
	else:
		stamina_bar.value = stamina
		var ratio = stamina / max_stamina
		if ratio > 0.5:
			stamina_bar.modulate = Color(1.0 - (ratio - 0.5) * 2.0, 1.0, 0.0)
		else:
			stamina_bar.modulate = Color(1.0, ratio * 2.0, 0.0)

	if is_sprinting or stamina < max_stamina:
		show_stamina_bar()
	elif stamina >= max_stamina and not is_fading_out:
		fade_out_stamina()

func fade_out_stamina():
	is_fading_out = true
	if stamina_tween: stamina_tween.kill()
	stamina_tween = create_tween()
	stamina_tween.tween_interval(1.5)
	stamina_tween.tween_property(stamina_bar, "modulate:a", 0.0, 0.5)
	stamina_tween.tween_callback(func(): stamina_bar.visible = false)

func is_holding_item(item_name: String) -> bool:
	if held_item != null:
		return item_name.to_lower() in held_item.name.to_lower()
	return false
