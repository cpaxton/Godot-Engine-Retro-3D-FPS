extends Node3D

@export var flash_time = 0.05
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flash_time
	timer.connect("timeout", Callable(self, "end_flash"))
	hide()
	
func flash():
	timer.start()
	rotation.z = randf_range(0.0, 2*PI)
	show()
	
func end_flash():
	hide()
