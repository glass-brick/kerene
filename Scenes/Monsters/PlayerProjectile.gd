extends "res://Scenes/Monsters/Projectile.gd"


export (int) var gravity_projectile = 40

var velocity

func _physics_process(delta):
	if not self.velocity:
		self.velocity = self.direction * self.speed
	self.velocity += Vector2.DOWN * gravity_projectile * delta
	self.position += self.velocity * delta
	distance_made += (self.velocity * delta).length()
	if distance_made > projectile_range:
		self.queue_free()

