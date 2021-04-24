extends KinematicBody2D

signal player_died

export (int) var max_speed = 400
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var jump_damage = 10
export (int) var gravity = 1200
export (int) var health = 100
export (int) var damage = 10

export (NodePath) var hud_path
export (NodePath) var tilemap_path

var velocity = Vector2()
var jumping = false
var hud
var is_dead = false
var tilemap
var cursor


func _ready():
	self.tilemap = get_node(tilemap_path)
	self.cursor = load("res://Scenes/Player/Cursor.gd").new(self)
	self.hud = get_node(hud_path)
	self.hud.update_health(self.health)


func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	if (left or right) and not (left and right):
		$AnimatedSprite.flip_h = left
		if right and velocity.x < max_speed:
			velocity.x += acceleration
		elif left and velocity.x > -max_speed:
			velocity.x -= acceleration
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - acceleration, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + acceleration, 0)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
		_on_hit(self.jump_damage)


func get_animation():
	var new_animation
	if velocity.y < 0:
		new_animation = 'jump'
	elif velocity.y > 0:
		new_animation = 'fall'
	elif velocity.x != 0:
		new_animation = 'walk'
	else:
		new_animation = 'idle'
	$AnimatedSprite.play(new_animation)


func _physics_process(delta):
	if not is_dead:
		cursor.update()
		get_input()
		get_animation()

		velocity.y += gravity * delta

		if jumping:
			jumping = false

		velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_hit(damageTaken):
	self.health -= damageTaken
	if health <= 0:
		emit_signal('player_died')
		hud.player_is_dead()
		$RestartAfterDeath.start()
		self.is_dead = true
		self.velocity.x = 0
		self.velocity.y = 0
		# Aca iria la animacion de la muerte si tuvieramos
	self.hud.update_health(self.health)


func _on_RestartAfterDeath_timeout():
	get_tree().reload_current_scene()
