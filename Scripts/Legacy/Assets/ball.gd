extends Area2D

var velocity := Vector2.ZERO
var speed := 500.0
var shooter_id: int = 0
var time_alive := 0.0

const SELF_HARM_DELAY = 0.15 

var bounce_count := 0
const MAX_BOUNCES = 2

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time_alive += delta
	var movement = velocity * speed * delta
	
	if multiplayer.is_server():
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + movement)
		
		# ignore own collision
		query.exclude = [get_rid()]  
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var collider = result.collider
			if not collider.is_in_group("players"):
				bounce_count += 1
				
				if bounce_count > MAX_BOUNCES:
					print("Ball maximal abgeprallt. Zerstört.")
					queue_free()
					return
				
				var normal = result.normal
				velocity = velocity.bounce(normal).normalized()
				
				global_position = result.position + (velocity * 2.0)
				return

	global_position += movement

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if body.name.to_int() == shooter_id and time_alive < SELF_HARM_DELAY:
			return
			
		print("Spieler ", body.name, " wurde vom Ball eliminiert!")
		queue_free()
