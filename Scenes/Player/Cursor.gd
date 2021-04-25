var cursor = load("res://Sprites/cursor.png")
var sword = load("res://Sprites/sword.png")
var pick = load("res://Sprites/pick.png")

var tilePosition = null
var targetedEnemy = null
enum CursorTypes { CURSOR, MINE, ATTACK }
var cursorType = CursorTypes.CURSOR
var tilemap
var player


func _init(p):
	player = p
	tilemap = p.tilemap


func update_mouse_positions():
	var mousePosition = player.get_global_mouse_position()

	var space_state = player.get_world_2d().direct_space_state

	var intersections = space_state.intersect_point(mousePosition, 1, [player, tilemap])
	if not intersections.empty():
		var target = intersections[0].collider

		if target.collision_layer == 2:
			targetedEnemy = target
			cursorType = CursorTypes.ATTACK
			return

		elif target == tilemap:
			tilePosition = tilemap.world_to_map(mousePosition)
			if tilemap.is_mineable(tilePosition):
				cursorType = CursorTypes.MINE
				return

	cursorType = CursorTypes.CURSOR


func update_mouse_image():
	if cursorType == CursorTypes.MINE:
		Input.set_custom_mouse_cursor(pick)
	elif cursorType == CursorTypes.ATTACK:
		Input.set_custom_mouse_cursor(sword)
	else:
		Input.set_custom_mouse_cursor(cursor)


func update():
	update_mouse_positions()
	update_mouse_image()
	var click = Input.is_action_just_pressed('click')
	var right_click = Input.is_action_just_pressed("right_click")
	if click:
		player.use_item()
	if right_click:
		if cursorType == CursorTypes.MINE:
			tilemap.mine(tilePosition)
