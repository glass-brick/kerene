extends "res://Scenes/Monsters/Monster.gd"

export (int) var idle_frames = 60
export (int) var speed = 100
export (int) var alert_speed = 200
export (int) var gravity = 1200
export (int) var damage = 10
export (int) var health = 30

enum MecheritoStates { IDLE, MOVING, ALERT, EXPLODING }
var velocity = Vector2(0, 0)


func _ready():
	setup(MecheritoStates)
	set_monster_state(MecheritoStates.IDLE)


var frames_to_change = 0


func _on_idle_start(_meta):
	$AnimatedSprite.play('idle')
	velocity.x = 0
	set_current_side(Sides.LEFT if randi() % 2 == 1 else Sides.RIGHT)


func _process_idle(_delta, _meta):
	var player = detect_player_at_distance()
	if player:
		set_monster_state_with_meta(MecheritoStates.ALERT, player)
		return
	if frames_to_change < idle_frames:
		frames_to_change += 1
	else:
		frames_to_change = 0
		set_monster_state(MecheritoStates.MOVING)


func _on_moving_start(_meta):
	$AnimatedSprite.play('walk')


func _process_moving(_delta, _meta):
	var player = detect_player_at_distance()
	if player:
		set_monster_state_with_meta(MecheritoStates.ALERT, player)
		return
	if is_on_wall():
		flip_side()
	velocity.x = speed if get_current_side() == Sides.RIGHT else -speed
	if frames_to_change < idle_frames:
		frames_to_change += 1
	else:
		frames_to_change = 0
		set_monster_state(MecheritoStates.IDLE)


func detect_player(area):
	var detectedEntities = area.get_overlapping_bodies()
	if not detectedEntities.empty():
		var player = detectedEntities[0]
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if result and result.collider == player:
			return player


func detect_player_at_distance():
	return detect_player($DetectionArea)


func detect_player_for_detonation():
	return detect_player($DetonationDetectionArea)


func _on_alert_start(_meta):
	$AnimatedSprite.play('alert_walk')


func _process_alert(_delta, _meta):
	if not detect_player_at_distance():
		return set_monster_state(MecheritoStates.MOVING)
	elif detect_player_for_detonation():
		return set_monster_state(MecheritoStates.EXPLODING)
	velocity.x = alert_speed if get_current_side() == Sides.RIGHT else -alert_speed


var knockback_frames = 0


func _on_hit(damageTaken, attacker):
	if not get_monster_state() == MecheritoStates.EXPLODING:
		set_monster_state(MecheritoStates.EXPLODING)
	elif $AnimatedSprite.frame >= 8:
		# Dont process damage if it's already exploding
		return
	health = max(0, health - damageTaken)
	var attack_direction = attacker.global_position - global_position
	velocity.x = -50 if attack_direction.x > 0 else 50
	velocity.y = -100
	knockback_frames = 10


func _on_exploding_start(_meta):
	$AnimatedSprite.play("detonate")


func _process_exploding(_delta, _meta):
	if knockback_frames > 0:
		knockback_frames -= 1
	else:
		velocity.x = 0


func _on_AnimatedSprite_frame_changed():
	if get_monster_state() == MecheritoStates.EXPLODING:
		if $AnimatedSprite.frame >= 8 and $AnimatedSprite.frame <= 12:
			var detectedEntities = $ExplosionArea.get_overlapping_bodies()
			for target in detectedEntities:
				if target.has_method('_on_hit'):
					target.call('_on_hit', damage, self)
		elif $AnimatedSprite.frame == 13:
			# finished explosion
			queue_free()


func _on_flip_side(new_side):
	$AnimatedSprite.flip_h = new_side == Sides.LEFT
	$DetectionArea.scale.x = (1 if new_side == Sides.RIGHT else -1)
	$Hitbox.scale.x = (1 if new_side == Sides.RIGHT else -1)


func _common_physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, 1))
