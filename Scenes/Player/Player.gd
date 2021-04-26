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

enum PlayerStates { UNLOCKED, USE, HIT, CLIMB_STOP, CLIMB_MOVE, DEAD }
var current_state = PlayerStates.UNLOCKED

var velocity = Vector2()
var shader_timer = 0
var blinking = false
var invincibility = false
var invincibility_counter = 0
const SPRITE_CENTER_OFFSET = Vector2(11, 11)
var time_since_last_use = 0
var pick_up_sounds = {}

onready var tilemap = get_node(tilemap_path)
onready var hud = get_node(hud_path)
onready var cursor = load("res://Scenes/Player/Cursor.gd").new(self)
onready var player_attack = $PlayerAttack
onready var items = {
	"basic_nothing": {"object": basic_item_nothing.new(self), "amount": 1},
	"basic_attack": {"object": basic_item.new(self), "amount": 0},
	"basic_projectile_attack": {"object": basic_item_projectile.new(self), "amount": 0}
}
onready var sprite = $AnimatedSprite
var active_item = "basic_nothing"


func _ready():
	self.hud.update_health(self.health)
	self.hud.update_active_item(get_active_item().item_name)
	pick_up_sounds['basic_attack'] = $AudioPickupSword
	pick_up_sounds['basic_projectile_attack'] = $AudioPickupWand



func get_active_item():
	return items[active_item]["object"]


func get_input(override_enable_jump):
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var up = Input.is_action_pressed('ui_up')
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

	if jump and (override_enable_jump or is_on_floor()):
		velocity.y = jump_speed
		if jump_damage_activated:
			self.health = max(self.health - jump_damage, 0)
			self.hud.update_health(self.health)

	if velocity.x and is_on_floor():
		if not $AudioFootsteps.playing:
			$AudioFootsteps.play()
	else:
		if $AudioFootsteps.playing:
			$AudioFootsteps.stop()

	get_item_input()

	if up:
		var tile_position = tilemap.world_to_map(global_position)
		var is_stair = tilemap.is_stair(tile_position)
		if is_stair:
			current_state = PlayerStates.CLIMB_STOP
			position = tilemap.map_to_world(tile_position) + (tilemap.cell_size / 2)
			velocity = Vector2(0, 0)


func get_item_input():
	var item = Input.is_action_just_pressed("item_1")
	var item2 = Input.is_action_just_pressed("item_2")
	var item3 = Input.is_action_just_pressed("item_3")

	if item and items["basic_attack"]['amount'] > 0:
		active_item = "basic_attack"
	if item2 and items["basic_projectile_attack"]['amount']  > 0:
		active_item = "basic_projectile_attack"
	self.hud.update_active_item(get_active_item().item_name)


func get_animation():
	if current_state == PlayerStates.CLIMB_STOP:
		sprite.play('climb')
		sprite.stop()
	elif current_state == PlayerStates.CLIMB_MOVE:
		sprite.play('climb')
	elif current_state == PlayerStates.USE:
		sprite.play('interact')
	elif current_state == PlayerStates.HIT:
		sprite.play('hit')
	elif velocity.y < 0:
		sprite.play('jump')
	elif velocity.y > 0:
		sprite.play('fall')
	elif velocity.x != 0:
		sprite.play('walk')
	else:
		sprite.play('idle')


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


func check_for_stair_exit():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	return right or left or jump


func get_stair_input():
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')

	if up or down:
		var tile_position = tilemap.world_to_map(global_position)
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

	if check_for_stair_exit():
		current_state = PlayerStates.UNLOCKED
		get_input(true)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1))


func _physics_process(delta):
	if not current_state == PlayerStates.DEAD:
		cursor.update()
		if current_state == PlayerStates.UNLOCKED or current_state == PlayerStates.USE:
			get_input(false)
		elif current_state == PlayerStates.CLIMB_STOP or current_state == PlayerStates.CLIMB_MOVE:
			get_stair_input()
		get_animation()
		process_invincibility(delta)

	if not (current_state == PlayerStates.CLIMB_STOP or current_state == PlayerStates.CLIMB_MOVE):
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	self.time_since_last_use += delta


func _on_hit(damageTaken, attacker):
	if not invincibility and not current_state == PlayerStates.DEAD:
		self.health = max(self.health - damageTaken, 0)
		self.play_random_hit_audio()
		var attack_direction = attacker.global_position - global_position
		velocity.x = -200 if attack_direction.x > 0 else 200
		velocity.y = -200
		if health > 0:
			current_state = PlayerStates.HIT
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
		print(self.time_since_last_use)
		if get_active_item().use(self.time_since_last_use):
			current_state = PlayerStates.USE
			self.time_since_last_use = 0


func mine(tile_position):
	tilemap.mine(tile_position)
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


func _on_heal(amount):
	if health == 100:
		return false
	self.health = (100 if self.health + amount > 100 else self.health + amount)
	self.hud.update_health(self.health)
	return true
