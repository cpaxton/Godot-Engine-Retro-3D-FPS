extends CharacterBody3D

@onready var aimer = $AimAtObject
@onready var anim_player = $Graphics/AnimationPlayer
@onready var health_manager = $HealthManager
@onready var character_mover = $CharacterMover

# If you need to reference a NavigationRegion3D node
@onready var nav_region = get_parent()

func find_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	
	# Use NavigationServer3D for pathfinding
	return NavigationServer3D.map_get_path(
		nav_region.get_navigation_map(),
		from,
		to,
		true  # optimize path
	)

enum STATES {IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE

var player = null
var path = []

@export var sight_angle = 45.0
@export var turn_speed = 360.0

@export var attack_angle = 5.0
@export var attack_range = 2.0
@export var attack_rate = 1.0
@export var attack_anim_speed_mod = 0.5
var attack_timer : Timer
var can_attack =true

signal attack

func _ready():
	
	# Make sure the parent is actually a NavigationRegion3D
	# assert(nav_region is NavigationRegion3D, "Parent must be a NavigationRegion3D")
	# assert(nav_region is NavigationRegion2D)
	
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", Callable(self, "finish_attack"))
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Graphics/Armature/Skeleton3D.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", Callable(self, "hurt"))
				
	health_manager.connect("dead", Callable(self, "set_state_dead"))
	health_manager.connect("gibbed", Callable($Graphics, "hide"))
	character_mover.init(self)
	set_state_idle()


func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)
			
func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")
	
func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("walk_loop", 0.2)
	
func set_state_attack():
	cur_state = STATES.ATTACK
	
func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")
	character_mover.freeze()
	$CollisionShape3D.disabled = true
	
func process_state_idle(delta):
	if can_see_player():
		set_state_chase()
	
func process_state_chase(delta):
	if within_dist_of_player(attack_range) and has_los_player():
		set_state_attack()
	var player_pos = player.global_transform.origin
	var our_pos = global_transform.origin
	path = find_path(our_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 1 :
		goal_pos = path[1]
	var dir = goal_pos - our_pos
	dir.y = 0
	character_mover.set_move_vec(dir)
	
	face_dir(dir,delta)
	
func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
	if can_attack:
		if !within_dist_of_player(attack_range) or !can_see_player():
			set_state_chase()
		elif !player_within_angle(attack_angle):
			face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)
		else:
			start_attack()
	
func process_state_dead(delta):
	pass

func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_manager.do_hurt(damage, dir)

func start_attack():
	can_attack = false
	anim_player.play("attack", -1, attack_anim_speed_mod)
	attack_timer.start()
	aimer.aim_at_position(player.global_transform.origin + Vector3.UP)
	
func finish_attack():
	can_attack = true

func emit_attack_signal():
	emit_signal("attack")
	
func can_see_player():
	return player_within_angle(sight_angle) and has_los_player()

func player_within_angle(angle: float):
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad_to_deg(forwards.angle_to(dir_to_player)) < angle

func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP
	var player_pos = player.global_transform.origin + Vector3.UP
	
	# var space_state = get_world_3d().get_direct_space_state()
	# var result = space_state.intersect_ray(our_pos,player_pos,[],1)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(our_pos, player_pos)
	query.collision_mask = 1  # Set the collision mask
	query.exclude = []  # Set the exclude array

	var result = space_state.intersect_ray(query)
	
	if result:
		return false
	return true
	
func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg_to_rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += deg_to_rad(turn_speed) * delta * turn_right

func alert(check_los = true):
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase()
	
func within_dist_of_player(dis: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < dis
	
	
	
	
	
	
	
	
	
	
	
