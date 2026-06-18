extends Node3D

enum State {
	GROUND,
	AIR,
	CROUCH,
}

@export var speed: float = 3.0
@export var sprint_speed: float = 6.0
@export var rotation_speed: float = 6.0
@export var jump_velocity: float = 7.0
@export var gravity: float = 12.0
@export var early_land_threshold: float = 0.5
@export var jump_windup_duration: float = 0.2
@export var acceleration: float = 5.0
@export var crouch_speed: float = 1.5

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var floor_ray: RayCast3D = %FloorRay

var enabled: bool = false
var state: State = State.GROUND
var _vertical_velocity: float = 0.0
var _early_landing_triggered: bool = false
var _jump_windup_timer: float = -1.0
var _blend_position: float = 0.0


func _process(delta):
	if not enabled:
		return

	var kbd_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(kbd_dir.x, 0.0, kbd_dir.y)
	var is_moving := direction.length() > 0.01

	if is_moving:
		direction = direction.normalized()
		var target_basis := Basis.looking_at(direction, Vector3.UP).rotated(Vector3.UP, PI)
		global_basis = global_basis.slerp(target_basis, rotation_speed * delta)

	match state:
		State.GROUND:
			var is_sprinting := is_moving and Input.is_action_pressed("dash")
			var current_speed := sprint_speed if is_sprinting else speed

			if is_moving:
				global_position.x += direction.x * current_speed * delta
				global_position.z += direction.z * current_speed * delta

			var target_blend := 0.0
			if is_sprinting:
				target_blend = 1.0
			elif is_moving:
				target_blend = 0.5
			_blend_position = move_toward(_blend_position, target_blend, acceleration * delta)
			animation_tree.set("parameters/Ground/blend_position", _blend_position)

			if Input.is_action_just_pressed("jump"):
				state = State.AIR
				_vertical_velocity = jump_velocity
				if playback.get_current_node() == "Jump_Land":
					playback.travel("Jump")
				else:
					playback.travel("Jump_Start")
					_jump_windup_timer = 0.0
			elif playback.get_current_node() == "Jump_Land":
				if Input.is_action_pressed("crouch"):
					state = State.CROUCH
					playback.travel("Crouch")
				else:
					playback.travel("Ground")
			elif Input.is_action_pressed("crouch"):
				state = State.CROUCH
				playback.travel("Crouch")
			elif playback.get_current_node() != "Ground":
				playback.travel("Ground")
		State.CROUCH:
			if is_moving:
				global_position.x += direction.x * crouch_speed * delta
				global_position.z += direction.z * crouch_speed * delta

			var target_blend := 1.0 if is_moving else 0.0
			_blend_position = move_toward(_blend_position, target_blend, acceleration * delta)
			animation_tree.set("parameters/Crouch/blend_position", _blend_position)

			if Input.is_action_just_pressed("jump"):
				state = State.AIR
				_vertical_velocity = jump_velocity
				playback.travel("Jump_Start")
				_jump_windup_timer = 0.0
			elif not Input.is_action_pressed("crouch"):
				state = State.GROUND
				playback.travel("Ground")
		State.AIR:
			if is_moving:
				global_position.x += direction.x * speed * delta
				global_position.z += direction.z * speed * delta

			_vertical_velocity -= gravity * delta
			global_position.y += _vertical_velocity * delta

			if _jump_windup_timer >= 0.0:
				_jump_windup_timer += delta
				if _jump_windup_timer >= jump_windup_duration:
					_jump_windup_timer = -1.0
					playback.travel("Jump")

			if _vertical_velocity <= 0 and not _early_landing_triggered and floor_ray.is_colliding():
				var dist = global_position.y - floor_ray.get_collision_point().y
				if dist <= early_land_threshold:
					_early_landing_triggered = true
					playback.travel("Jump_Land")

			if _early_landing_triggered and Input.is_action_just_pressed("jump"):
				_vertical_velocity = jump_velocity
				_early_landing_triggered = false
				_jump_windup_timer = 0.0
				playback.travel("Jump_Start")

			if floor_ray.is_colliding() and global_position.y <= floor_ray.get_collision_point().y:
				global_position.y = floor_ray.get_collision_point().y
				_vertical_velocity = 0.0
				state = State.GROUND
				_early_landing_triggered = false
				_jump_windup_timer = -1.0
				playback.travel("Jump_Land")


func enable_controller():
	enabled = true
	animation_tree.active = true


func disable_controller():
	enabled = false
	animation_tree.active = false
