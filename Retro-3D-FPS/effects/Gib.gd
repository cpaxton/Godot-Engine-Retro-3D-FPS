extends CharacterBody3D

@export var start_move_speed = 30
@export var grav = 35.0
@export var drag = 0.01
@export var velo_retained_on_bounce = 0.8
var char_velocity = Vector3.ZERO
var initialized = false

func init():
	initialized = true
	char_velocity = -global_transform.basis.y * start_move_speed
	
func _physics_process(delta):
	if !initialized:
		return
	
	char_velocity += -char_velocity * drag + Vector3.DOWN * grav * delta
	
	var collision = move_and_collide(char_velocity * delta)
	
	if collision:
		var normal = collision.get_normal()
		var reflection = char_velocity.bounce(normal)
		char_velocity = reflection * velo_retained_on_bounce

