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
export (int) var invincibility_time = 2
export (float) var blinking_speed = 0.05

export (Script) var basic_item = load("res://Scenes/Items/BasicAttack.gd")
export (Script) var basic_item_projectile = load("res://Scenes/Items/BasicProjectileAttack.gd")

export (NodePath) var hud_path
export (NodePath) var tilemap_path

enum PlayerStates { UNLOCKED, USE, HIT, DEAD }
var current_state = PlayerStates.UNLOCKED

var velocity = Vector2()
var jumping = false
var shader_timer = 0
var blinking = false
var invincibility = false
var invincibility_counter = 0

onready var tilemap = get_node(tilemap_path)
onready var hud = get_node(hud_path)
onready var cursor = load("res://Scenes/Player/Cursor.gd").new(self)
onready var player_attack = $PlayerAttack
onready var items = {
	"basic_attack": {"object": basic_item.new(self), "amount": 1},
	"basic_projectile_attack": {"object": basic_item_projectile.new(self), "amount": 1}
}
onready var sprite = $AnimatedSprite
var active_item = "basic_attack"


func _ready():
	self.hud.update_health(self.health)
	self.hud.update_active_item(get_active_item().item_name)


func get_active_item():
	return items[active_item]["object"]


func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	var use = Input.is_action_just_pressed("Use_item")

	if (left or right) and not (left and right):
		sprite.flip_h = left
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
			self.health = max(self.health - jump_damage, 0)
			self.hud.update_health(self.health)

	get_item_input()
	if use:
		self.use_item()


func get_item_input():
	var item = Input.is_action_just_pressed("item_1")
	var item2 = Input.is_action_just_pressed("item_2")
	var item3 = Input.is_action_just_pressed("item_3")

	if item:
		active_item = "basic_attack"
	if item2:
		active_item = "basic_projectile_attack"
	self.hud.update_active_item(get_active_item().item_name)


func get_animation():
	var new_animation
	if current_state == PlayerStates.USE:
		new_animation = 'interact'
	elif current_state == PlayerStates.HIT:
		new_animation = 'hit'
	elif velocity.y < 0:
		new_animation = 'jump'
	elif velocity.y > 0:
		new_animation = 'fall'
	elif velocity.x != 0:
		new_animation = 'walk'
	else:
		new_animation = 'idle'
	sprite.play(new_animation)


func process_invincibility(delta):
	if invincibility and not current_state == PlayerStates.HIT:
		invincibility_counter += delta
		shader_timer += delta * blinking_speed
		var mat = sprite.get_material()
		mat.set_shader_param("timer", shader_timer)
		if invincibility_counter > self.invincibility_time:
			invincibility = false
	else:
		invincibility_counter = 0
		shader_timer = 0
		var mat = sprite.get_material()
		mat.set_shader_param("timer", shader_timer)


func _physics_process(delta):
	if not current_state == PlayerStates.DEAD:
		cursor.update()
		if current_state == PlayerStates.UNLOCKED or current_state == PlayerStates.USE:
			get_input()
		get_animation()
		process_invincibility(delta)

		velocity.y += gravity * delta

		if jumping:
			jumping = false

		velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_hit(damageTaken, attacker):
	if not invincibility and not current_state == PlayerStates.DEAD:
		self.health = max(self.health - damageTaken, 0)
		self.play_random_hit_audio()
		if health > 0:
			current_state = PlayerStates.HIT
			var attack_direction = attacker.global_position - global_position
			velocity.x = -200 if attack_direction.x > 0 else 200
			velocity.y = -200
		else:
			emit_signal('player_died')
			hud.player_is_dead()
			$RestartAfterDeath.start()
			self.current_state = PlayerStates.DEAD
			self.velocity.x = 0
			self.velocity.y = 0
			# Aca iria la animacion de la muerte si tuvieramos
		self.invincibility = true
		self.hud.update_health(self.health)


func play_random_hit_audio():
	var audio_choice = rand_range(1, 4)
	if audio_choice < 2:
		$Audio1.play()
	elif audio_choice < 3:
		$Audio2.play()
	else:
		$Audio3.play()


func play_cut_audio():
	$AudioCut.play()


func play_shoot_audio():
	$AudioShoot.play()


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
	if get_active_item():
		get_active_item().use()
		current_state = PlayerStates.USE


func _on_AnimatedSprite_animation_finished():
	if current_state == PlayerStates.USE or current_state == PlayerStates.HIT:
		current_state = PlayerStates.UNLOCKED


func spend_active_item():
	var current_item_name = get_active_item().item_name
	if self.items[current_item_name] in self.items:
		self.items[current_item_name]["amount"] -= 1
		if self.items[current_item_name]["amount"] < 1:
			active_item = "basic_attack"
