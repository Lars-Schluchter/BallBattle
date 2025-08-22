extends RigidBody2D

@export var speed: float = 400.0
@export var max_bounces: int = 3

var bounces: int = 0
var was_touching: bool = false

func _ready() -> void:
	gravity_scale = 0.0
	custom_integrator = true
	continuous_cd = CCD_MODE_DISABLED  # disable continuous CD to avoid weird sliding
	contact_monitor = true
	max_contacts_reported = 4

	var mat := PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 1.0
	physics_material_override = mat

func shoot(from_pos: Vector2, to_pos: Vector2) -> void:
	global_position = from_pos
	linear_velocity = (to_pos - from_pos).normalized() * speed

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var vel = state.linear_velocity
	var contact_count = state.get_contact_count()

	if contact_count > 0:
		if not was_touching:
			# Average all contact normals
			var normal_sum = Vector2.ZERO
			for i in range(contact_count):
				normal_sum += state.get_contact_local_normal(i)
			var avg_normal = normal_sum.normalized()
			if avg_normal.length() == 0:
				avg_normal = state.get_contact_local_normal(0).normalized()

			# Reflect velocity and add small push away from wall to avoid sticking
			vel = vel.bounce(avg_normal)
			vel += avg_normal * 10  # push velocity slightly away from wall

			# Clamp speed to desired speed to avoid slowdown
			vel = vel.normalized() * speed

			bounces += 1
			was_touching = true

			if bounces >= max_bounces:
				queue_free()
				return
	else:
		was_touching = false

	state.linear_velocity = vel
	linear_velocity = vel
