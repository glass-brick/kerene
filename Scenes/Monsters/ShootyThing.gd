extends KinematicBody2D


export (int) var gravity = 1200
export (int) var attack_time_limit = 60
export (int) var jump_speed = -300
export (int) var damage = 10
export (int) var health = 10
export (int) var shoot_cooldown = 5
export (int) var projectile_speed = 100
export (PackedScene) var Projectile

var shoot_cooldown_current = 0

enum States { IDLE, HIT, ATTACKING, DEAD }

var currentState
onready var detection_area = $DetectionArea
var target
var state_time = 0


func _ready():
	currentState = States.IDLE
	$AnimatedSprite.play('idle')

func _physics_process(delta):
	if currentState == States.IDLE:
		var detectedEntities = detection_area.get_overlapping_bodies()
		if not detectedEntities.empty():
			var player = detectedEntities[0]
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(global_position, player.global_position, [self])
			if result and result.collider == player:
				target = player
				currentState = States.ATTACKING
				# $AnimatedSprite.play('attack')


	elif currentState == States.ATTACKING:
		if state_time == 0 or shoot_cooldown_current > self.shoot_cooldown:
			var detectedEntities = detection_area.get_overlapping_bodies()
			if detectedEntities.empty():
				currentState = States.IDLE
			var projectile = Projectile.instance()
			var difference = self.position - target.position
			projectile.direction = (target.position - self.position).normalized()
			projectile.speed = projectile_speed
			get_tree().get_root().get_node("Level").add_child(projectile)
			projectile.position = self.position
			shoot_cooldown_current = 0
		else:
			shoot_cooldown_current += delta
		state_time += delta

func _on_hit(damageTaken):
	if not currentState == States.HIT:
		self.health -= damageTaken
		if health > 0:
			currentState = States.HIT
			# $AnimatedSprite.play('hit')
		else:
			$AnimatedSprite.stop()
			$AnimatedSprite.flip_v
			# $AnimatedSprite.play('death')
			currentState = States.DEAD
			$CleanBody.start()

		


func _on_CleanBody_timeout():
	queue_free()
