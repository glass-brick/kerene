extends KinematicBody2D
class_name Monster

enum Sides { LEFT, RIGHT }
export (Sides) var initial_side
var current_state
var current_side
var current_metadata
var states
var stateFunctions = {}


func setup(statesEnum):
	states = statesEnum
	for key in statesEnum.keys():
		stateFunctions[statesEnum[key]] = {
			"process": "_process_%s" % key.to_lower(),
			"start": "_on_%s_start" % key.to_lower(),
		}


func _common_physics_process(_delta):
	pass


func _physics_process(delta):
	_common_physics_process(delta)
	var process_func = stateFunctions[current_state]["process"]
	if not process_func:
		print('UNEXPECTED STATE:', current_state)
	if has_method(process_func):
		call(process_func, delta, current_metadata)


func trigger_state_change():
	var change_func = stateFunctions[current_state]["start"]
	if not change_func:
		print('UNEXPECTED STATE:', current_state)
	if has_method(change_func):
		call(change_func, current_metadata)


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
