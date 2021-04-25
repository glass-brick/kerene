extends Area2D



export (int) var damage = 10
export (int) var speed = 40

var direction

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	self.position += self.direction * self.speed * delta

func _on_Area2D_body_entered(body):
	if body.has_method('_on_hit'):
		body._on_hit(self.damage)
		self.queue_free()
	if body.name == 'TileMap':
		self.queue_free()
		
