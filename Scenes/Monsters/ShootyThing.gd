extends "res://Scenes/Monsters/Monster.gd"

export (int) var gravity = 1200
export (int) var attack_time_limit = 60
export (int) var jump_speed = -300
export (int) var damage = 10
export (int) var health = 10
export (int) var shoot_cooldown = 5
export (int) var projectile_speed = 100
export (PackedScene) var Projectile

var shoot_cooldown_current = 0

onready var detection_area = $DetectionArea
var state_time = 0


func _ready():
	set_monster_state(MonsterStates.IDLE)


func _on_idle_start(_meta):
	$AnimatedSprite.play('idle')


func _process_idle(_delta, _meta):
	var detectedEntities = detection_area.get_overlapping_bodies()
	if not detectedEntities.empty():
		var player = detectedEntities[0]
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if result and result.collider == player:
			set_monster_state_with_meta(MonsterStates.ATTACKING, player)


func _process_attacking(delta, target):
	if state_time == 0 or shoot_cooldown_current > self.shoot_cooldown:
		$AnimatedSprite.play('attack')
		var detectedEntities = detection_area.get_overlapping_bodies()
		if detectedEntities.empty():
			set_monster_state(MonsterStates.IDLE)
		var projectile = Projectile.instance()
		var difference = target.position - self.position
		projectile.direction = (difference).normalized()
		projectile.speed = projectile_speed
		get_tree().get_root().get_node("Level").add_child(projectile)
		projectile.position = self.position
		shoot_cooldown_current = 0
	else:
		shoot_cooldown_current += delta
	state_time += delta


func _on_dead_start(_meta):
	$AnimatedSprite.play('death')
	$CleanBody.start()
	# only collide with the world
	collision_mask = 1
	collision_layer = 0


func _on_hit_start(_meta):
	$AnimatedSprite.play('hit')


func _on_hit(damageTaken):
	if not (get_monster_state() == MonsterStates.HIT or get_monster_state() == MonsterStates.DEAD):
		health = max(0, health - damageTaken)
		set_monster_state(MonsterStates.HIT if health > 0 else MonsterStates.DEAD)


func _on_CleanBody_timeout():
	queue_free()


func _on_AnimatedSprite_animation_finished():
	if get_monster_state() != MonsterStates.DEAD:
		$AnimatedSprite.play('idle')
