extends Area3D

class_name HitBox

@export var weak_spot = false
@export var critical_damage_multiplayer = 2
signal hurt

func do_hurt(damage: int, dir: Vector3):
	if weak_spot:
		emit_signal("hurt", damage*critical_damage_multiplayer, dir)
	else:
		emit_signal("hurt", damage, dir)
