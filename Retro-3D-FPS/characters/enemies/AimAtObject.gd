extends Node3D

func aim_at_position(pos: Vector3):
	rotation = Vector3.ZERO
	var offset = to_local(pos)
	offset.x = 0
	rotation.x = -atan2(offset.y, offset.z)

	var first_child = get_child(0)
	first_child.fire()
