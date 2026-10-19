extends Area2D

var velocity := Vector2.ZERO
var speed := 500.0
var shooter_id: int = 0
var time_alive := 0.0

const SELF_HARM_DELAY = 0.15 

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time_alive += delta
	global_position += velocity * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if body.name.to_int() == shooter_id and time_alive < SELF_HARM_DELAY:
			return
			
		print("Spieler ", body.name, " wurde getroffen!")
		queue_free()
