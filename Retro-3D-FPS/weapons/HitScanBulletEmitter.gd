extends Node3D

var hit_effect = preload("res://effects/BulletHitEffect.tscn")

@export var distance = 10000
var bodies_to_exclude = []
var damage = 1

func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude
	
func fire():
	var space_state = get_world_3d().get_direct_space_state()
	var our_pos = global_transform.origin
	
	var query = PhysicsRayQueryParameters3D.create(
		our_pos,
		our_pos - global_transform.basis.z * distance,
		1 + 4,  # collision mask
		bodies_to_exclude
	)
	
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal)
	elif result:
		var hit_effect_inst = hit_effect.instantiate()
		get_tree().get_root().add_child(hit_effect_inst)
		hit_effect_inst.global_transform.origin = result.position
		
		var children : Array = hit_effect_inst.get_children()
		for child in children:
			if child is GPUParticles2D or child is GPUParticles3D:
				child.emitting = true
		
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			return
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			hit_effect_inst.rotate(Vector3.RIGHT, PI)
			return
			
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)
		
		hit_effect_inst.global_transform.basis = Basis(x, y, z)
		
