extends Area3D


class_name Pickup

enum PICKUP_TYPES {MACHINE_GUN, MACHINE_GUN_AMMO,
	SHOTGUN, SHOTGUN_AMMO,
	ROCKET_LAUNCHER, ROCKET_LAUNCHER_AMMO,
	HEALTH}
	
@export var pickup_type: PICKUP_TYPES
@export var ammo = 10
