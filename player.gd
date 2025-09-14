extends CharacterBody3D

signal hit

@export var speed: float = 14.0
@export var fall_acceleration: float = 75.0
@export var jump_impulse: float = 20.0
@export var bounce_impulse: float = 16.0
@export var max_fall_speed: float = 50.0  # Optional limit

var target_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("move_backward"):
		direction.z += 1.0
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1.0

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Rotate the pivot to face movement direction (XZ only)
		$Pivot.look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)

	# Horizontal movement
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Gravity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
		target_velocity.y = max(target_velocity.y, -max_fall_speed)  # Clamp fall speed

	# Jump (only on floor, not on mobs)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# Handle collisions
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			var hit_from_above := Vector3.UP.dot(collision.get_normal()) > 0.85
			if hit_from_above:
				mob.squash()
				target_velocity.y = bounce_impulse
				break  # Only squash one mob per frame

	# Move the player
	velocity = target_velocity
	move_and_slide()

# Called when player "dies"
func die():
	hit.emit()
	queue_free()

# Triggered when a mob touches the player (e.g. from the side)
func _on_mob_detector_body_entered(body) -> void:
	die()
