extends Area2D

onready var sprite = $AttackSprite

var damage


func attack_right(dmg):
	scale.x = 1
	attack(dmg)


func attack_left(dmg):
	scale.x = -1
	attack(dmg)


func attack(dmg):
	damage = dmg
	sprite.frame = 0
	sprite.show()
	sprite.play()


func _physics_process(_delta):
	if sprite.is_playing() and sprite.visible:
		var targets = get_overlapping_bodies()
		if not targets.empty():
			var target = targets[0]

			if target.collision_layer == 2:
				if target.has_method('_on_hit'):
					target.call('_on_hit', damage)


func _on_AttackSprite_animation_finished():
	sprite.stop()
	sprite.hide()
