extends "res://Scenes/Monsters/Monster.gd"

export (int) var speed = 100
export (int) var gravity = 1200
export (int) var attack_time_limit = 60
export (int) var jump_speed = -300
export (int) var damage = 10
export (int) var health = 30

var velocity = Vector2(0, 0)
var state_time = 0

enum RatStates { MOVING, ATTACKING, HIT, DEAD }


func _ready():
	setup(RatStates)
	set_monster_state(RatStates.MOVING)


func _on_moving_start(_meta):
	$AnimatedSprite.play('run')
	set_current_side(Sides.LEFT if randi() % 2 == 1 else Sides.RIGHT)


func _on_flip_side(new_side):
	$AnimatedSprite.flip_h = new_side == Sides.LEFT
	$DetectionArea.scale.x = (1 if new_side == Sides.RIGHT else -1)


func _process_moving(_delta, _meta):
	if is_on_wall():
		if not detect_attack():
			flip_side()
	velocity.x = speed if get_current_side() == Sides.RIGHT else -speed


func detect_attack():
	var detectedEntities = $DetectionArea.get_overlapping_bodies()
	if not detectedEntities.empty():
		var player = detectedEntities[0]
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if result and result.collider == player:
			set_monster_state(RatStates.ATTACKING)
			return true
	return false


func _on_attacking_start(_meta):
	velocity.y = jump_speed
	$AnimatedSprite.play('attack')


func _process_attacking(_delta, _meta):
	velocity.x = speed if get_current_side() == Sides.RIGHT else -speed
	state_time += 1
	if state_time > attack_time_limit:
		state_time = 0
		set_monster_state(RatStates.MOVING)


func _common_physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, 1))


func _on_hit(damageTaken, attacker):
	if not (get_monster_state() == RatStates.HIT or get_monster_state() == RatStates.DEAD):
		health = max(0, health - damageTaken)
		set_monster_state_with_meta(RatStates.HIT if health > 0 else RatStates.DEAD, attacker)


func _on_hit_start(attacker):
	$AudioHit.play()
	$AnimatedSprite.play('hit')
	var attack_direction = attacker.global_position - global_position
	velocity.x = -50 if attack_direction.x > 0 else 50
	velocity.y = -100


func _on_dead_start(_meta):
	$AudioDeath.play()
	$AnimatedSprite.play('death')
	# only collide with the world
	collision_mask = 1
	collision_layer = 0
	$CleanBody.start()
	velocity = Vector2(0, 0)


func _on_AnimatedSprite_animation_finished():
	if get_monster_state() == RatStates.HIT:
		set_monster_state(RatStates.MOVING)


func _on_CleanBody_timeout():
	queue_free()


func _on_Hitbox_body_entered(body):
	if not get_monster_state() == RatStates.DEAD and body.has_method('_on_hit'):
		body._on_hit(self.damage, self)
