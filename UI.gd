extends Control

signal animations_list_pressed
signal playground_pressed

var animation_player: AnimationPlayer
var _grid_created: bool = false
var _controls_overlay_created: bool = false


func _ready():
	%AnimationsButton.pressed.connect(func(): animations_list_pressed.emit())
	%PlaygroundButton.pressed.connect(func(): playground_pressed.emit())
	%ExitButton.pressed.connect(func(): get_tree().quit())


func setup_animations(anim_player: AnimationPlayer):
	animation_player = anim_player
	_create_grid()


func _create_grid():
	if _grid_created:
		return
	_grid_created = true

	var grid := %AnimationsRows.get_child(0) as GridContainer
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)

	for anim_name in animation_player.get_animation_list():
		var btn := Button.new()
		btn.text = anim_name
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_animation_button_pressed.bind(anim_name))
		grid.add_child(btn)


func _on_animation_button_pressed(anim_name: String):
	animation_player.play(anim_name)


func _setup_controls_overlay():
	if _controls_overlay_created:
		return
	_controls_overlay_created = true

	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0.55)
	stylebox.set_corner_radius_all(8)
	stylebox.content_margin_left = 16
	stylebox.content_margin_top = 12
	stylebox.content_margin_right = 16
	stylebox.content_margin_bottom = 12
	%ControlsPanel.add_theme_stylebox_override("panel", stylebox)

	var binds := [
		["Move", "WASD / Arrow Keys"],
		["Jump", "Space"],
		["Crouch", "C"],
		["Sprint", "Shift"],
		["Back", "Esc"],
	]

	for bind in binds:
		var label := Label.new()
		label.text = bind[0] + ": " + bind[1]
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color.WHITE)
		%ControlsVBox.add_child(label)


func show_main_menu():
	%Overlay.hide()
	%MainMenu.show()
	%Panel.hide()
	%Logo.hide()
	_set_subviewport(1.0)


func show_animations():
	%Overlay.hide()
	%MainMenu.hide()
	%Panel.show()
	%Logo.show()
	_set_subviewport(0.601)


func show_playground():
	_setup_controls_overlay()
	%Overlay.show()
	%MainMenu.hide()
	%Panel.hide()
	%Logo.show()
	_set_subviewport(1.0)


func _set_subviewport(right: float):
	var svc := %SubViewportContainer
	svc.anchor_left = 0.0
	svc.anchor_top = 0.0
	svc.anchor_right = right
	svc.anchor_bottom = 1.0
	svc.offset_left = 0.0
	svc.offset_top = 0.0
	svc.offset_right = 0.0
	svc.offset_bottom = 0.0
