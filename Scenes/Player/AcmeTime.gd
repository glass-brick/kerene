class_name AcmeTime

enum AcmeTypes { FLOOR, LEAVE_STAIR, ENTER_STAIR }

var states = {
	AcmeTypes.FLOOR:
	{"prev": false, "limit": 3, "check_fn": "floor_check", "active": false, "frame": 0},
	AcmeTypes.LEAVE_STAIR:
	{"prev": false, "limit": 3, "check_fn": "enter_stair_check", "active": false, "frame": 0},
	AcmeTypes.ENTER_STAIR:
	{"prev": false, "limit": 5, "check_fn": "leave_stair_check", "active": false, "frame": 0},
}

var player = null


func _init(p):
	player = p


func floor_check():
	return player.is_on_floor()


func enter_stair_check():
	return player.is_on_stair()


func leave_stair_check():
	return not player.is_on_stair()


func update():
	for type in states:
		var state = states[type]
		if not state["active"]:
			if not state["prev"] and call(state["check_fn"]):
				state["prev"] = true

			if state["prev"] and not call(state["check_fn"]):
				state["active"] = true
		else:
			if state["frame"] > state["limit"]:
				end_state(type)
			else:
				state["frame"] += 1


func end_state(type):
	var state = states[type]
	state["prev"] = false
	state["active"] = false
	state["frame"] = 0


func is_floor():
	return states[AcmeTypes.FLOOR]["active"]


func end_floor():
	end_state(AcmeTypes.FLOOR)


func is_enter_stair():
	return states[AcmeTypes.ENTER_STAIR]["active"]


func end_enter_stair():
	end_state(AcmeTypes.ENTER_STAIR)


func is_leave_stair():
	return states[AcmeTypes.LEAVE_STAIR]["active"]


func end_leave_stair():
	end_state(AcmeTypes.LEAVE_STAIR)
