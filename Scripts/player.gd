extends CharacterBody2D

const SPEED = 300.0
const BALL_SCENE = preload("res://Scenes/Prefab/ball.tscn")

@onready var visuals: Node2D = $Visuals
@export var sync_position: Vector2

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		visuals.top_level = true

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		sync_position = global_position
		
		if Input.is_action_just_pressed("ui_accept"):
			var shoot_direction = direction if direction != Vector2.ZERO else Vector2.RIGHT
			request_shoot.rpc_id(1, global_position, shoot_direction)
	else:
		global_position = sync_position

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		visuals.global_position = global_position
	else:
		visuals.global_position = visuals.global_position.lerp(global_position, 15.0 * delta)

@rpc("any_peer", "call_local", "reliable")
func request_shoot(start_pos: Vector2, dir: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var ball = BALL_SCENE.instantiate()
	ball.global_position = start_pos
	ball.velocity = dir.normalized()
	
	if ball.has_method("set_shooter"):
		ball.set_shooter(multiplayer.get_remote_sender_id())
	elif "shooter_id" in ball:
		ball.shooter_id = multiplayer.get_remote_sender_id()
		
	get_parent().add_child(ball, true)
