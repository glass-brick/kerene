extends KinematicBody2D

signal player_died

export (int) var max_speed = 400
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var jump_damage = 10
export (int) var gravity = 1200
export (int) var health = 100
export (int) var damage = 10
export (bool) var jump_damage_activated = false
export (int) var invencibility_time = 5
export (float) var blinking_speed = 0.5

export (Script) var basic_item
export (Script) var basic_item_projectile

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
var shader_timer = 0
var blinking = false
var invencibility = false
var invencibility_counter = 0


func _ready():
	var item = basic_item.new()
	item.item_owner = self
	self.items["basic_attack"] = {"object": item , "amount": 1}
	var item_projectile = basic_item_projectile.new()
	item_projectile.item_owner = self
	self.items["basic_projectile_attack"] = {"object": item_projectile, "amount": 1}
	self.active_item = self.items["basic_attack"]["object"]
	self.tilemap = get_node(tilemap_path)
	self.cursor = load("res://Scenes/Player/Cursor.gd").new(self)
	self.hud = get_node(hud_path)
	self.hud.update_health(self.health)
	self.hud.update_active_item(self.active_item.item_name)


func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	var use = Input.is_action_just_pressed("Use_item")

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
		if jump_damage_activated:
			_on_hit(self.jump_damage)

	get_item_input()
	if use:
		self.use_item()

func get_item_input():
	var item = Input.is_action_just_pressed("item_1")
	var item2 = Input.is_action_just_pressed("item_2")
	var item3 = Input.is_action_just_pressed("item_3")
	
	if item:
		active_item = self.items["basic_attack"]["object"]
	if item2:
		active_item = self.items["basic_projectile_attack"]["object"]
	self.hud.update_active_item(self.active_item.item_name)

	


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
	
	if invencibility:
		invencibility_counter += delta
		shader_timer += delta*blinking_speed
		var mat = $AnimatedSprite.get_material()
		mat.set_shader_param("timer",shader_timer)
		if invencibility_counter > self.invencibility_time:
			invencibility = false
	else:
		invencibility_counter = 0
		shader_timer = 0
		var mat = $AnimatedSprite.get_material()
		mat.set_shader_param("timer",shader_timer)


func _on_hit(damageTaken):
	if not invencibility:
		self.health -= damageTaken
		self.play_random_hit_audio()
		if health <= 0:
			emit_signal('player_died')
			hud.player_is_dead()
			if not is_dead:
				$RestartAfterDeath.start()
			self.is_dead = true
			self.velocity.x = 0
			self.velocity.y = 0
			# Aca iria la animacion de la muerte si tuvieramos
		self.invencibility = true
		self.hud.update_health(self.health)
		
func play_random_hit_audio():
	var audio_choice = rand_range(1,4)
	if audio_choice < 2:
		$Audio1.play()
	elif audio_choice < 3:
		$Audio2.play()
	else:
		$Audio3.play()
		


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
