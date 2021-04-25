extends Node2D

export (Array, PackedScene) var levels

var current_level_index = 0

var current_checkpoint = null  # modificado directamente desde Checkpoint.gd


func start_current_level():
	var level = levels[current_level_index].instance()
	if current_checkpoint != null:
		level.current_checkpoint = current_checkpoint
	add_child(level, true)
	level.connect("on_finish_level", self, "_on_current_level_finish")
	level.connect("on_player_lose", self, "_on_player_lose")


func start_next_level():
	current_checkpoint = null
	var finished_level = get_child(0)
	remove_child(finished_level)
	current_level_index += 1
	start_current_level()


func _on_current_level_finish():
	call_deferred('start_next_level')


func _on_player_lose():
	get_tree().reload_current_scene()
	var level = get_child(0)
	if current_checkpoint != null:
		level.current_checkpoint = current_checkpoint


func _ready():
	start_current_level()
