extends "res://Scenes/Monsters/Monster.gd"

export (int) var speed = 100
export (int) var gravity = 1200
export (int) var attack_time_limit = 60
export (int) var jump_speed = -300
export (int) var damage = 10
export (int) var health = 30

var velocity = Vector2(0, 0)
var state_time = 0


func _ready():
	set_monster_state(MonsterStates.MOVING)


func _on_moving_start(_meta):
	$AnimatedSprite.play('run')
	set_current_side(Sides.LEFT if randi() % 2 == 1 else Sides.RIGHT)


func _on_flip_side(new_side):
	$AnimatedSprite.flip_h = new_side == Sides.LEFT
	$DetectionArea.scale.x = (1 if new_side == Sides.RIGHT else -1)


func _process_moving(_delta, _meta):
	var current_speed = speed if get_current_side() == Sides.RIGHT else -speed
	velocity = move_and_slide(Vector2(current_speed, velocity.y), Vector2(0, 1))
	if is_on_wall():
		flip_side()
	detect_attack()


func detect_attack():
	var detectedEntities = $DetectionArea.get_overlapping_bodies()
	if not detectedEntities.empty():
		var player = detectedEntities[0]
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if result and result.collider == player:
			set_monster_state(MonsterStates.ATTACKING)


func _on_attacking_start(_meta):
	velocity.y = jump_speed
	$AnimatedSprite.play('attack')


func _process_attacking(_delta, _meta):
	var current_speed = speed if get_current_side() == Sides.RIGHT else -speed
	state_time += 1
	velocity = move_and_slide(Vector2(current_speed, velocity.y), Vector2(0, 1))
	print(current_speed, velocity)
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		if collision.collider.has_method('_on_hit'):
			collision.collider.call('_on_hit', damage)
	if state_time > attack_time_limit:
		state_time = 0
		set_monster_state(MonsterStates.MOVING)


func _process_hit(_delta, _meta):
	velocity = move_and_slide(Vector2(0, velocity.y), Vector2(0, 1))


func _process_dead(_delta, _meta):
	velocity = move_and_slide(Vector2(0, velocity.y), Vector2(0, 1))


func _common_physics_process(delta):
	print(get_monster_state())
	velocity.y += gravity * delta


func _on_hit(damageTaken):
	if not (get_monster_state() == MonsterStates.HIT or get_monster_state() == MonsterStates.DEAD):
		health = max(0, health - damageTaken)
		set_monster_state(MonsterStates.HIT if health > 0 else MonsterStates.DEAD)


func _on_hit_start(_meta):
	$AudioHit.play()
	$AnimatedSprite.play('hit')


func _on_dead_start(_meta):
	$AudioDeath.play()
	$AnimatedSprite.play('death')
	# only collide with the world
	collision_mask = 1
	collision_layer = 0
	$CleanBody.start()
	velocity = Vector2(0, 0)


func _on_AnimatedSprite_animation_finished():
	if get_monster_state() == MonsterStates.HIT:
		set_monster_state(MonsterStates.MOVING)


func _on_CleanBody_timeout():
	queue_free()
