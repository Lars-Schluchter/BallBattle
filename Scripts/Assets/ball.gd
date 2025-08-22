# Ball.gd (NEWLY ADDED)
# This script controls the ball's movement and collision logic.

extends CharacterBody2D

@export var speed = 500
@export var max_bounces = 2

var bounces = 0

func _ready():
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	# The ball's logic should only run on the server to prevent cheating
	# and keep physics consistent for all players.
	if not multiplayer.is_server():
		return
		
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		# Check if the object we hit is a player
		if collider.has_method("handle_hit"):
			collider.handle_hit()
			queue_free() # Destroy the ball
		else:
			# If it's not a player, it must be a wall, so bounce
			velocity = velocity.bounce(collision.get_normal())
			bounces += 1
			if bounces > max_bounces:
				queue_free()
