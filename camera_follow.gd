extends Camera3D

@export var follow_speed: float = 4.0
@export var look_target_height: float = 1.0
@export var offset: Vector3 = Vector3(0, 1.8, 1.8)
@export var showcase_distance: float = 2.5
@export var showcase_height: float = 1.8

var target: Node3D
var enabled: bool = false
var _showcase_mode: bool = false


func _process(delta):
	if enabled and is_instance_valid(target):
		var target_pos := target.global_position + offset
		global_position = global_position.lerp(target_pos, follow_speed * delta)
		look_at(target.global_position + Vector3(0, look_target_height, 0), Vector3.UP)
	elif _showcase_mode and is_instance_valid(target):
		var front_dir := target.global_basis.z
		var desired_pos := target.global_position + front_dir * showcase_distance + Vector3(0, showcase_height, 0)
		global_position = global_position.lerp(desired_pos, follow_speed * delta)
		look_at(target.global_position + Vector3(0, look_target_height, 0), Vector3.UP)


func enable_follow(t: Node3D):
	target = t
	enabled = true
	_showcase_mode = false


func disable_follow():
	enabled = false
	_showcase_mode = true
