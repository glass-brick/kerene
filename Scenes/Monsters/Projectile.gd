extends Area2D



export (int) var damage = 10
export (int) var speed = 40
export (int) var projectile_range = 400

var direction
var distance_made = 0

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	self.position += self.direction * self.speed * delta
	distance_made += (self.direction * self.speed * delta).length()
	if distance_made > projectile_range:
		self.queue_free()

func _on_Area2D_body_entered(body):
	if body.has_method('_on_hit'):
		body._on_hit(self.damage)
		self.queue_free()
	if body.name == 'TileMap':
		self.queue_free()
		
