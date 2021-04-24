extends KinematicBody2D

signal player_died

export (int) var max_speed = 400
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var jump_damage = 10
export (int) var gravity = 1200
export (int) var health = 100
export (int) var damage = 10

export (Script) var basic_item

export (NodePath) var hud_path
export (NodePath) var tilemap_path

var active_item
var velocity = Vector2()
var jumping = false
var hud
var is_dead = false
var items = {}
var tilemap
var cursor


func _ready():
	self.items["basic_attack"] = {"object": basic_item.new(), "amount": 1}
	self.active_item = self.items["basic_attack"]["object"]
	self.tilemap = get_node(tilemap_path)
	self.cursor = load("res://Scenes/Player/Cursor.gd").new(self)
	self.hud = get_node(hud_path)
	self.hud.update_health(self.health)


func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	var use = Input.is_action_just_pressed("Use_item")
	var change_item = Input.is_action_just_pressed("Change_item")

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

	if change_item:
		self.active_item = self.items[self.items.keys()[-1]]["object"]
	if use:
		self.use_item()


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


func pickup_item(item):
	var new_item = item.new()
	if new_item.item_name in self.items:
		self.items[new_item.item_name]["amount"] += 1
	else:
		new_item.item_owner = self
		self.items[new_item.item_name] = {"amount": 1, "object": new_item}
	return true


func use_item():
	if self.active_item:
		self.active_item.use()


func spend_active_item():
	var current_item_name = self.active_item.item_name
	if self.items[current_item_name] in self.items:
		self.items[current_item_name]["amount"] -= 1
		if self.items[current_item_name]["amount"] < 1:
			active_item = self.items["basic_attack"]["object"]
