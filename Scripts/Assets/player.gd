# player.gd
class_name Player
extends CharacterBody2D

@export var speed = 300

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta):
	# This guard clause prevents errors when the network isn't fully ready.
	if multiplayer.get_unique_id() == 0:
		return

	if not is_multiplayer_authority():
		return
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	#if Input.is_action_just_pressed("shoot"):
			#request_to_fire.rpc_id(1, global_position)
	#
#@rpc("authority", "reliable")
#func request_to_fire(spawn_position: Vector2):
	#pass
