extends Area2D

export (int) var damage = 10
export (int) var speed = 40
export (int) var projectile_range = 400

var direction
var distance_made = 0
var exploding = false


func _ready():
	$AnimatedSprite.play()


func _physics_process(delta):
	if exploding:
		return
	self.position += self.direction * self.speed * delta
	distance_made += (self.direction * self.speed * delta).length()
	if distance_made > projectile_range:
		explode()


func explode():
	$AudioStreamPlayer.play()
	$AnimatedSprite.play('explode')
	$Trail.emitting = false
	$ExplodeTimer.start()
	exploding = true


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'explode':
		$AnimatedSprite.visible = false


func _on_ExplodeTimer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	if exploding:
		return
	if body.has_method('_on_hit'):
		body._on_hit(self.damage, self)
		explode()
	if body.name == 'TileMap':
		explode()
