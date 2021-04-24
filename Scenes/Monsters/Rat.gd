extends KinematicBody2D

export (int) var speed = 100
export (int) var gravity = 1200
export (int) var attack_time_limit = 30
export (int) var jump_speed = -300
export (int) var damage = 10

enum State { MOVING_LEFT, MOVING_RIGHT, ATTACKING }
var currentState
var velocity = Vector2(0, 0)
onready var detection_area = $DetectionArea
var attack_time = 0


func _ready():
	set_random_move()


func set_random_move():
	if randi() % 2 == 1:
		currentState = State.MOVING_LEFT
	else:
		currentState = State.MOVING_RIGHT


func _physics_process(delta):
	velocity.y += gravity * delta

	if not currentState == State.ATTACKING:
		var detectedEntities = detection_area.get_overlapping_bodies()
		if not detectedEntities.empty():
			var player = detectedEntities[0]
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(
				global_position, player.global_position, [self], 3
			)
			if result and result.collider == player:
				velocity.y = jump_speed
				currentState = State.ATTACKING

	if currentState == State.MOVING_LEFT:
		$AnimatedSprite.flip_h = true
		detection_area.scale.x = -1
		velocity = move_and_slide(Vector2(-speed, velocity.y), Vector2(0, 1))
		if is_on_wall():
			currentState = State.MOVING_RIGHT
	elif currentState == State.MOVING_RIGHT:
		$AnimatedSprite.flip_h = false
		detection_area.scale.x = 1
		velocity = move_and_slide(Vector2(speed, velocity.y), Vector2(0, 1))
		if is_on_wall():
			currentState = State.MOVING_LEFT
	elif currentState == State.ATTACKING:
		attack_time += 1
		velocity = move_and_slide(velocity, Vector2(0, 1))
		var slide_count = get_slide_count()
		if slide_count:
			var collision = get_slide_collision(slide_count - 1)
			if collision.collider.has_method('_on_hit'):
				collision.collider.call('_on_hit', damage)
		if attack_time > attack_time_limit:
			attack_time = 0
			set_random_move()
