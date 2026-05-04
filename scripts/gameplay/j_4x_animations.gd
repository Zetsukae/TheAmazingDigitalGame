extends CharacterBody3D

@export var patrol_points: Array[Node3D]
@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var flee_speed: float = 8.0
@export var chase_distance: float = 15.0
@export var jumpscare_distance: float = 1.5 
@export var rotation_speed: float = 5.0 

@onready var anim_mixer: AnimationPlayer = $J4xAnimations/AnimationPlayer
@onready var node_idle = $J4xAnimations/idle
@onready var node_run = $J4xAnimations/run
@onready var chase_sound = $ChaseSound 

@onready var player: Node3D = get_tree().current_scene.find_child("player", true, false)

var chasing: bool = false
var fleeing: bool = false
var game_over: bool = false
var current_target_pos: Vector3 = Vector3.ZERO
var is_waiting: bool = false

func _ready():
	_pick_next_patrol_pos()

func _physics_process(delta):
	if game_over or player == null:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var dist_to_player = global_position.distance_to(player.global_position)

	var player_has_corn = player.has_method("is_holding_item") and player.is_holding_item("corn")

	if player_has_corn and dist_to_player <= chase_distance:
		fleeing = true
		chasing = false
		if chase_sound and chase_sound.playing: chase_sound.stop()
	elif dist_to_player <= chase_distance:
		fleeing = false
		if not chasing:
			chasing = true
			if chase_sound: chase_sound.play()
		current_target_pos = player.global_position
	else:
		fleeing = false
		if chasing:
			chasing = false
			if chase_sound: chase_sound.stop()
			_pick_next_patrol_pos()

	if dist_to_player <= jumpscare_distance and not player_has_corn:
		game_over = true
		get_tree().change_scene_to_file("res://scenes/scenes_gameplay/jumpscare_animation.tscn")
		return

	if fleeing:
		var flee_dir = (global_position - player.global_position).normalized()
		flee_dir.y = 0
		velocity.x = flee_dir.x * flee_speed
		velocity.z = flee_dir.z * flee_speed
		_smooth_rotate(flee_dir, delta)
		_play_anim("run")
	else:
		var dir = (current_target_pos - global_position)
		dir.y = 0 
		if dir.length() > 0.5 and not is_waiting:
			var direction = dir.normalized()
			var speed = run_speed if chasing else walk_speed
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			_smooth_rotate(direction, delta)
			_play_anim("run")
		else:
			velocity.x = 0
			velocity.z = 0
			_play_anim("idle")
			if not chasing and not is_waiting:
				_wait_at_point()

	move_and_slide()


func _pick_next_patrol_pos():
	if patrol_points.is_empty(): return
	current_target_pos = patrol_points[randi() % patrol_points.size()].global_position

func _wait_at_point():
	is_waiting = true
	await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
	is_waiting = false
	_pick_next_patrol_pos()

func _play_anim(anim_name: String):
	node_idle.visible = (anim_name == "idle")
	node_run.visible = (anim_name == "run")
	if anim_mixer.current_animation != anim_name:
		anim_mixer.play(anim_name, 0.3)

func _smooth_rotate(direction: Vector3, delta: float):
	if direction.length() > 0.001:
		var look_pos = global_position + direction
		var target_transform = transform.looking_at(look_pos, Vector3.UP)
		transform.basis = transform.basis.slerp(target_transform.basis, rotation_speed * delta).orthonormalized()
