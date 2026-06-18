extends Node3D

enum Mode { MAIN_MENU, ANIMATIONS, PLAYGROUND }

var current_mode: Mode = Mode.MAIN_MENU
var _player_controller
var _camera_follow: Camera3D


func _ready():
	$Ui/%SubViewport.world_3d = $Scenary.get_world_3d()

	var cam: Camera3D = $Scenary/ % CameraAnchor / %Camera3D
	$Scenary/%CameraAnchor.remove_child(cam)
	$Ui/%SubViewport.add_child(cam)
	_camera_follow = cam

	_player_controller = $Scenary/ % Human

	var anim_player: AnimationPlayer = _player_controller.get_node("AnimationPlayer")
	$Ui.setup_animations(anim_player)
	if anim_player.has_animation("Idle"):
		anim_player.play("Idle")

	$Ui.animations_list_pressed.connect(_switch_to_animations)
	$Ui.playground_pressed.connect(_switch_to_playground)
	$Ui.show_main_menu()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if current_mode == Mode.PLAYGROUND or current_mode == Mode.ANIMATIONS:
			_switch_to_main_menu()
		else:
			get_tree().quit()
		get_viewport().set_input_as_handled()


func _disable_controls():
	_player_controller.disable_controller()
	_camera_follow.disable_follow()


func _enable_controls():
	_player_controller.enable_controller()
	_camera_follow.enable_follow(_player_controller)


func _switch_to_animations():
	current_mode = Mode.ANIMATIONS
	_disable_controls()
	$Ui.show_animations()


func _switch_to_playground():
	current_mode = Mode.PLAYGROUND
	_enable_controls()
	$Ui.show_playground()


func _switch_to_main_menu():
	current_mode = Mode.MAIN_MENU
	_disable_controls()
	$Ui.show_main_menu()
