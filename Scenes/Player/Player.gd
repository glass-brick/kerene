extends KinematicBody2D

signal player_died

export (int) var max_speed = 400
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var jump_damage = 10
export (int) var gravity = 1200
export (int) var health = 100

export (Script) var basic_item

export (NodePath) var hud_path
var active_item 

var velocity = Vector2()
var jumping = false
var hud_path_node
var is_dead = false
var items = {
	"basic_attack":{
		"object": basic_item,
		"amount": 1
	}
}



func _ready():
	self.hud_path_node = get_node(hud_path)
	self.hud_path_node.update_health(self.health)
	active_item = self.items["basic_attack"]["object"]
	


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
		self.active_item = self.items[self.items.keys()[-1]]["object"];
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
		get_input()
		get_animation()

		velocity.y += gravity * delta

		if jumping:
			jumping = false

		velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_hit(damage):
	self.health -= damage
	if health <= 0:
		emit_signal('player_died')
		hud_path_node.player_is_dead()
		$RestartAfterDeath.start()
		self.is_dead = true
		self.velocity.x = 0
		self.velocity.y = 0
		# Aca iria la animacion de la muerte si tuvieramos
	self.hud_path_node.update_health(self.health)


func _on_RestartAfterDeath_timeout():
	get_tree().reload_current_scene()

func pickup_item(item):
	print(item)
	
	if item.item_name in self.items:
		self.items[item.item_name]["amount"] += 1
	else:
		self.items[item.item_name] = {"amount": 1, "object": item}
	item.pick_up_item()
	
func use_item():
	if self.active_item:
		self.active_item.use()

func spend_active_item():
	if self.items[self.active_item.item_name] in self.items:
		self.items[self.active_item.item_name]["amount"] -= 1
		if self.items[self.active_item.item_name]["amount"] < 1:
			active_item = self.items["basic_attack"]["object"]
	
