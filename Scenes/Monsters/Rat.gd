extends KinematicBody2D

export (int) var speed = 100
export (int) var gravity = 1200
export (int) var attack_time_limit = 60
export (int) var jump_speed = -300
export (int) var damage = 10
export (int) var health = 30

enum States { MOVING_LEFT, MOVING_RIGHT, HIT, ATTACKING, DEAD }
var currentState
var velocity = Vector2(0, 0)
onready var detection_area = $DetectionArea
var state_time = 0


func _ready():
	set_random_move_state()


func set_random_move_state():
	$AnimatedSprite.play('run')
	if randi() % 2 == 1:
		currentState = States.MOVING_LEFT
	else:
		currentState = States.MOVING_RIGHT


func _physics_process(delta):
	velocity.y += gravity * delta

	if currentState == States.MOVING_LEFT or currentState == States.MOVING_RIGHT:
		var detectedEntities = detection_area.get_overlapping_bodies()
		if not detectedEntities.empty():
			var player = detectedEntities[0]
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(global_position, player.global_position, [self])
			if result and result.collider == player:
				velocity.y = jump_speed
				currentState = States.ATTACKING
				$AnimatedSprite.play('attack')

	if currentState == States.MOVING_LEFT:
		$AnimatedSprite.flip_h = true
		detection_area.scale.x = -1
		velocity = move_and_slide(Vector2(-speed, velocity.y), Vector2(0, 1))
		if is_on_wall():
			currentState = States.MOVING_RIGHT
	elif currentState == States.MOVING_RIGHT:
		$AnimatedSprite.flip_h = false
		detection_area.scale.x = 1
		velocity = move_and_slide(Vector2(speed, velocity.y), Vector2(0, 1))
		if is_on_wall():
			currentState = States.MOVING_LEFT
	elif currentState == States.ATTACKING:
		state_time += 1
		velocity = move_and_slide(velocity, Vector2(0, 1))
		var slide_count = get_slide_count()
		if slide_count:
			var collision = get_slide_collision(slide_count - 1)
			if collision.collider.has_method('_on_hit'):
				collision.collider.call('_on_hit', damage)
		if state_time > attack_time_limit:
			state_time = 0
			set_random_move_state()


func _on_hit(damageTaken):
	if not currentState == States.HIT:
		self.health -= damageTaken
		if health > 0:
			currentState = States.HIT
			$AnimatedSprite.play('hit')
		else:
			$AnimatedSprite.play('death')
			currentState = States.DEAD
			$CleanBody.start()
			velocity = Vector2(0, 0)


func _on_AnimatedSprite_animation_finished():
	if currentState == States.HIT:
		set_random_move_state()


func _on_CleanBody_timeout():
	queue_free()
