extends KinematicBody2D
class_name Monster

enum MonsterStates { MOVING, IDLE, HIT, ATTACKING, DEAD }
export (MonsterStates) var initial_state
enum Sides { LEFT, RIGHT }
export (Sides) var initial_side
var current_state
var current_side
var current_metadata
var states = {
	MonsterStates.MOVING: {"process": "_process_moving", "start": "_on_moving_start"},
	MonsterStates.IDLE: {"process": "_process_idle", "start": "_on_idle_start"},
	MonsterStates.HIT: {"process": "_process_hit", "start": "_on_hit_start"},
	MonsterStates.ATTACKING: {"process": "_process_attacking", "start": "_on_attacking_start"},
	MonsterStates.DEAD: {"process": "_process_dead", "start": "_on_dead_start"}
}


func _ready():
	set_monster_state(initial_state)
	set_current_side(initial_side)


func _common_physics_process(_delta):
	pass


func _physics_process(delta):
	_common_physics_process(delta)
	var process_func = states[current_state]["process"]
	if has_method(process_func):
		call(process_func, delta, current_metadata)
	else:
		print('UNEXPECTED STATE:', current_state)


func trigger_state_change():
	var change_func = states[current_state]["start"]
	if has_method(change_func):
		call(change_func, current_metadata)
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
