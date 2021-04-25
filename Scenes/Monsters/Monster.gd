extends KinematicBody2D
class_name Monster

enum MonsterStates { MOVING, IDLE, HIT, ATTACKING, DEAD }
export (MonsterStates) var initial_state
enum Sides { LEFT, RIGHT }
export (Sides) var initial_side
var current_state
var prev_state
var current_side
var current_metadata


func _ready():
	set_monster_state(initial_state)
	set_current_side(initial_side)


func _process_moving(_delta, _meta):
	pass


func _on_moving_start(_meta):
	pass


func _process_idle(_delta, _meta):
	pass


func _on_idle_start(_meta):
	pass


func _process_hit(_delta, _meta):
	pass


func _on_hit_start(_meta):
	pass


func _process_attacking(_delta, _meta):
	pass


func _on_attacking_start(_meta):
	pass


func _process_dead(_delta, _meta):
	pass


func _on_dead_start(_meta):
	pass


func _common_physics_process(_delta):
	pass


func _physics_process(delta):
	_common_physics_process(delta)
	if current_state == MonsterStates.MOVING:
		_process_moving(delta, current_metadata)
	elif current_state == MonsterStates.IDLE:
		_process_idle(delta, current_metadata)
	elif current_state == MonsterStates.HIT:
		_process_hit(delta, current_metadata)
	elif current_state == MonsterStates.ATTACKING:
		_process_attacking(delta, current_metadata)
	elif current_state == MonsterStates.DEAD:
		_process_dead(delta, current_metadata)
	else:
		print('UNEXPECTED STATE:', current_state)


func trigger_state_change():
	if current_state == MonsterStates.MOVING:
		_on_moving_start(current_metadata)
	elif current_state == MonsterStates.IDLE:
		_on_idle_start(current_metadata)
	elif current_state == MonsterStates.HIT:
		_on_hit_start(current_metadata)
	elif current_state == MonsterStates.ATTACKING:
		_on_attacking_start(current_metadata)
	elif current_state == MonsterStates.DEAD:
		_on_dead_start(current_metadata)
	else:
		print('UNEXPECTED STATE:', current_state)


func set_monster_state(new_state):
	current_state = new_state
	current_metadata = null
	trigger_state_change()


func set_monster_state_with_meta(new_state, state_metadata):
	current_state = new_state
	current_metadata = state_metadata
	trigger_state_change()


func get_monster_state():
	return current_state


func set_current_side(side):
	current_side = side
	_on_flip_side(current_side)


func get_current_side():
	return current_side


func _on_flip_side(_new_side):
	pass


func flip_side():
	current_side = Sides.LEFT if current_side == Sides.RIGHT else Sides.RIGHT
	_on_flip_side(current_side)
