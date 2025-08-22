# Player.gd (MODIFIED WITH DEBUG PRINT)
# This script should have a MultiplayerSynchronizer node as a child.

extends CharacterBody2D

@export var speed = 300
@onready var visual = $ColorRect
@onready var collision_shape = $CollisionShape2D

func _ready():
	add_to_group("players")

func _spawned(data):
	print("<<<<< DEBUG: Player %s has been spawned on this machine! >>>>>" % data.id)
	self.name = str(data.id)
	self.position = data.position
	set_multiplayer_authority(data.id)

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func _input(event):
	if not is_multiplayer_authority():
		return
	if event.is_action_pressed("shoot"):
		GameManager.rpc("shoot_ball", global_position, get_global_mouse_position())

func handle_hit():
	if is_multiplayer_authority():
		GameManager.rpc("_on_player_died", name.to_int())
