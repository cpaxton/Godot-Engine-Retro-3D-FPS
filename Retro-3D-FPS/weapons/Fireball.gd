extends CharacterBody3D


var speed = 20
var impact_damage = 20
var exploded = false

func _ready():
	hide()
	
func set_bodies_to_exclude(bodies_to_exclude : Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)
		
func _physics_process(delta):
	var velocity = -global_transform.basis.z * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z)
		
		$SmokeParticles.emitting = true
		speed = 0
		$Graphics.hide()
		$CollisionShape3D.set_deferred("disabled", true)
		
		# Optional: queue_free() after a delay if this is a projectile
		# get_tree().create_timer(2.0).connect("timeout", self, "queue_free")

