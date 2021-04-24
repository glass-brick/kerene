extends KinematicBody2D

export (int) var max_speed = 400
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var gravity = 1200
export (int) var health = 100

export (NodePath) var hud_path

var velocity = Vector2()
var jumping = false
var hud_path_node

func _ready():
	self.hud_path_node = get_node(hud_path)
	self.hud_path_node.update_health(self.health)

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
	get_input()
	get_animation()

	velocity.y += gravity * delta

	if jumping:
		jumping = false

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func _on_Player_get_hit(damage):
	self.health -= damage
	self.hud_path_node.update_health(self.health)

