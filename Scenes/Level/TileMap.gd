extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cursor = load("res://Sprites/cursor.png")
var pick = load("res://Sprites/pick.png")

var tilePosition = Vector2(0, 0)
var tileInPosition = false


func update_mouse_positions():
	var mousePosition = get_global_mouse_position()
	tilePosition = world_to_map(mousePosition)
	tileInPosition = get_cellv(tilePosition) != -1
	if tileInPosition:
		Input.set_custom_mouse_cursor(pick)
	else:
		Input.set_custom_mouse_cursor(cursor)


func _process(_delta):
	update_mouse_positions()
	var click = Input.is_action_just_pressed('click')
	if click and tileInPosition:
		set_cellv(tilePosition, -1)
		update_bitmask_region()
