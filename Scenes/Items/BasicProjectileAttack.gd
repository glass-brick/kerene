var item_name = "basic_projectile_attack"

var projectile_speed = 100
var projectile_damage = 20
var projectile_range = 200
var item_owner = false
var projectileBase = preload("res://Scenes/Monsters/PlayerProjectile.tscn")

func use():
	item_owner.play_shoot_audio()
	var target = item_owner.get_global_mouse_position()
	self.fire_projectile_in_dir((target - item_owner.position).normalized())

func fire_projectile_in_dir(direction):
	var projectile = projectileBase.instance()
	projectile.speed = projectile_speed
	projectile.damage = projectile_damage
	projectile.projectile_range = projectile_range
	projectile.direction = direction
	item_owner.get_tree().get_root().get_node("Level").add_child(projectile)
	projectile.position = item_owner.position

	
