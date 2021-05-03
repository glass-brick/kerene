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
export (int) var dig_length = 100

export (Script) var basic_item = load("res://Scenes/Items/BasicAttack.gd")
export (Script) var basic_item_projectile = load("res://Scenes/Items/BasicProjectileAttack.gd")
export (Script) var basic_item_nothing = load("res://Scenes/Items/BasicNothing.gd")

export (NodePath) var hud_path
export (NodePath) var tilemap_path

enum PlayerStates { UNLOCKED, LOCKED, USE, HIT, CLIMB_STOP, CLIMB_MOVE, DEAD }
var current_state = PlayerStates.UNLOCKED

var velocity = Vector2()
var blinking = false
var invincibility = false
var invincibility_counter = 0
const SPRITE_CENTER_OFFSET = Vector2(11, 11)
var time_since_last_use = 0
var pick_up_sounds = {}
var was_on_floor = true
var time_floor_check = 0
var using_item = false
var initial_hit_timer = 20
var hit_timer = 0
var initial_interact_timer = 20
var interact_timer = 0

onready var tilemap = get_node(tilemap_path)
onready var hud = get_node(hud_path)
onready var cursor = load("res://Scenes/Player/Cursor.gd").new(self)
onready var player_attack = $PlayerAttack
var items = {
	"basic_nothing": {"object": basic_item_nothing.new(self), "amount": 1},
	"basic_attack": {"object": basic_item.new(self), "amount": 0},
	"basic_projectile_attack": {"object": basic_item_projectile.new(self), "amount": 0}
}
onready var sprite = $AnimatedSprite
var active_item = "basic_nothing"
onready var acme_time = preload("res://Scenes/Player/AcmeTime.gd").new(self)


func _ready():
	self.load()
	for item in items:
		if items[item]['amount'] > 0 and item != "basic_nothing":
			self.hud.update_active_item(item)
	self.hud.update_health(self.health)
	self.hud.update_active_item(get_active_item().item_name)
	pick_up_sounds['basic_attack'] = $AudioPickupSword
	pick_up_sounds['basic_projectile_attack'] = $AudioPickupWand


func get_active_item():
	return items[active_item]["object"]


func get_input(override_enable_jump):
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var up = Input.is_action_just_pressed('ui_up')
	var jump = Input.is_action_just_pressed('ui_select')

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

	if (
		jump
		and (
			is_on_floor()
			or override_enable_jump
			or acme_time.is_floor()
			or acme_time.is_leave_stair()
		)
	):
		velocity.y = jump_speed
		if acme_time.is_floor():
			acme_time.end_floor()
		if acme_time.is_leave_stair():
			acme_time.end_leave_stair()
		if jump_damage_activated:
			self.health = max(self.health - jump_damage, 0)
			self.hud.update_health(self.health)

	if not was_on_floor and is_on_floor():
		$AudioHitGround.play()
		was_on_floor = is_on_floor()

	if velocity.x and is_on_floor():
		if not $AudioFootsteps.playing:
			$AudioFootsteps.play()
	else:
		if $AudioFootsteps.playing:
			$AudioFootsteps.stop()

	if up:
		var tile_position = tilemap.global_to_map(global_position)
		var is_stair = tilemap.is_stair(tile_position)
		if is_stair:
			current_state = PlayerStates.CLIMB_STOP
			global_position = tilemap.map_to_global(tile_position) + (tilemap.cell_size / 2)
			velocity = Vector2(0, 0)


func get_item_input():
	var item = Input.is_action_just_pressed("item_1")
	var item2 = Input.is_action_just_pressed("item_2")

	if item and items["basic_attack"]['amount'] > 0:
		active_item = "basic_attack"
	if item2 and items["basic_projectile_attack"]['amount'] > 0:
		active_item = "basic_projectile_attack"
	self.hud.update_active_item(get_active_item().item_name)


func get_animation():
	if current_state == PlayerStates.HIT:
		return sprite.play('hit')
	var prev_animation = sprite.animation
	var new_animation
	if current_state == PlayerStates.CLIMB_MOVE or current_state == PlayerStates.CLIMB_STOP:
		new_animation = 'climb'
	elif not is_on_floor():
		if velocity.y < 0:
			new_animation = 'jump'
		else:
			new_animation = 'fall'
	elif velocity.x != 0:
		new_animation = 'walk'
	else:
		new_animation = 'idle'

	print(prev_animation, new_animation, current_state)
	if using_item:
		new_animation += '_interact'
		if prev_animation != new_animation and '_interact' in prev_animation:
			sprite.animation = new_animation
		else:
			sprite.play(new_animation)
		return
	sprite.play(new_animation)
	if current_state == PlayerStates.CLIMB_STOP:
		sprite.stop()


func process_invincibility(delta):
	if invincibility and not current_state == PlayerStates.HIT:
		invincibility_counter += delta
		var mat = sprite.get_material()
		mat.set_shader_param("active", true)
		if invincibility_counter > self.invincibility_time:
			invincibility = false
	else:
		invincibility_counter = 0
		var mat = sprite.get_material()
		mat.set_shader_param("active", false)


func check_for_stair_exit():
	var jump = Input.is_action_just_pressed('ui_select')
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')

	return jump or left or right


func get_stair_input():
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')

	if up or down:
		var tile_position = tilemap.global_to_map(global_position)
		var multiplier = -1 if up else 1
		tile_position.y += multiplier
		if tilemap.is_stair(tile_position):
			velocity.y = 100 * multiplier
			current_state = PlayerStates.CLIMB_MOVE
		else:
			velocity.y = 0
			current_state = PlayerStates.CLIMB_STOP
	else:
		velocity.y = 0
		current_state = PlayerStates.CLIMB_STOP

	if not acme_time.is_enter_stair() and check_for_stair_exit():
		current_state = PlayerStates.UNLOCKED
		get_input(true)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1))


func is_on_stair():
	return current_state == PlayerStates.CLIMB_MOVE or current_state == PlayerStates.CLIMB_STOP


func lock():
	velocity.x = 0
	velocity.y = 0
	current_state = PlayerStates.LOCKED


func can_use_item():
	return not (current_state == PlayerStates.LOCKED or current_state == PlayerStates.HIT)


func unlock():
	current_state = PlayerStates.UNLOCKED


func process_locked(delta):
	get_animation()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))


func process_timers():
	if hit_timer > 0:
		hit_timer -= 1
	elif current_state == PlayerStates.HIT:
		current_state = PlayerStates.UNLOCKED
	if interact_timer > 0:
		interact_timer -= 1
	elif using_item:
		using_item = false


func _physics_process(delta):
	process_timers()
	if current_state == PlayerStates.LOCKED:
		process_locked(delta)
		return

	if not current_state == PlayerStates.DEAD:
		acme_time.update()
		cursor.update()
		get_item_input()
		if current_state == PlayerStates.UNLOCKED:
			get_input(false)
		elif is_on_stair():
			get_stair_input()
		get_animation()
		process_invincibility(delta)

	if not (current_state == PlayerStates.CLIMB_STOP or current_state == PlayerStates.CLIMB_MOVE):
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	self.time_since_last_use += delta
	time_floor_check += delta
	if time_floor_check > 0.1:
		was_on_floor = is_on_floor()
		time_floor_check = 0


func _on_hit(damageTaken, attacker):
	if not invincibility and not current_state == PlayerStates.DEAD:
		self.health = max(self.health - damageTaken, 0)
		self.play_random_hit_audio()
		var attack_direction = attacker.global_position - global_position
		velocity.x = -200 if attack_direction.x > 0 else 200
		velocity.y = -200
		if health > 0:
			current_state = PlayerStates.HIT
			hit_timer = initial_hit_timer
		else:
			hud.player_is_dead()
			$RestartAfterDeath.start()
			self.current_state = PlayerStates.DEAD
			sprite.play('death')
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


func play_mine_sound():
	var audio_choice = rand_range(1, 4)
	if audio_choice < 2:
		$AudioDig1.play()
	elif audio_choice < 3:
		$AudioDig2.play()
	else:
		$AudioDig3.play()


func play_cut_audio():
	$AudioCut.play()


func play_shoot_audio():
	$AudioShoot.play()


func _on_RestartAfterDeath_timeout():
	get_tree().reload_current_scene()
	emit_signal('player_died')


func pickup_item(item_name):
	if item_name in self.items:
		self.items[item_name]["amount"] += 1
		play_pickup_sound(item_name)
		self.active_item = item_name
	return true


func play_pickup_sound(item_name):
	pick_up_sounds[item_name].play()


func use_item():
	if get_active_item():
		if get_active_item().can_use(self.time_since_last_use):
			if is_on_stair():
				sprite.flip_h = (get_global_mouse_position() - global_position).x < 0
			get_active_item().use()
			using_item = true
			interact_timer = initial_interact_timer
			self.time_since_last_use = 0


func mine(tile_position):
	if is_on_stair():
		sprite.flip_h = (get_global_mouse_position() - global_position).x < 0
	tilemap.mine(tile_position)
	using_item = true
	interact_timer = initial_interact_timer


func spend_active_item():
	var current_item_name = get_active_item().item_name
	if self.items[current_item_name] in self.items:
		self.items[current_item_name]["amount"] -= 1
		if self.items[current_item_name]["amount"] < 1:
			active_item = "basic_attack"


func _on_heal(amount):
	if health == 100:
		return false
	self.health = (100 if self.health + amount > 100 else self.health + amount)
	$AudioHeal.play()
	self.hud.update_health(self.health)
	return true


func show_message(message, time):
	hud.show_message(message, time)


func save():
	var dict_save = {}
	dict_save['position'] = {'x': self.global_position.x, 'y': self.global_position.y}
	var save_items = {}
	for name in self.items:
		save_items[name] = {"amount": self.items[name]['amount']}
	dict_save['items'] = save_items
	dict_save['active_item'] = self.active_item
	var playerVariables = get_node('/root/PlayerVariables')
	playerVariables.data = dict_save


func load():
	var playerVariables = get_node('/root/PlayerVariables')
	if not playerVariables.data:
		return
	var dict_save = playerVariables.data
	self.global_position.x = dict_save['position']['x']
	self.global_position.y = dict_save['position']['y']
	for name in dict_save['items']:
		self.items[name]['amount'] = dict_save['items'][name]['amount']
	self.active_item = dict_save['active_item']
