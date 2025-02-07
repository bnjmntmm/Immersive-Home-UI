@tool

extends Container3D
class_name Button3D

signal on_button_down()
signal on_button_up()
signal on_toggled(active: bool)

#const IconFont = preload ("res://addons/immersive-home-ui/assets/icons/icons.tres")
const ECHO_WAIT_INITIAL = 0.5
const ECHO_WAIT_REPEAT = 0.1

@onready var body: StaticBody3D = $Body
@onready var panel: Panel3D = $Body/Panel3D
@onready var collision: CollisionShape3D = $Body/CollisionShape3D
@onready var label_node: Label3D = $Body/Label
@onready var click_sound = $ClickSound

@onready var fingerArea: Area3D = $FingerArea

@export var focusable: bool = true:
	set(value):
		focusable = value
		if value == false:
			add_to_group("ui_focus_stop")
		else:
			remove_from_group("ui_focus_stop")

@export var font_size: int = 10:
	set(value):
		font_size = value
		if !is_inside_tree()||icon: return
		label_node.font_size = font_size

@export var label: String = "":
	set(value):
		label = value
		if !is_inside_tree(): return
		label_node.text = label

@export var icon: bool = false:
	set(value):
		icon = value
		if !is_inside_tree(): return
		
		if icon:
			$Body/Label.visible = false
			$Body/Icon.visible = true
		else:
			$Body/Label.visible = true
			$Body/Icon.visible = false
		
@export var icon_image : Texture2D = null:
	set(value):
		icon_image = value
		if icon_image:
			$Body/Icon.texture = icon_image
		else:
			$Body/Icon.texture = null
			

@export var toggleable: bool = false
@export var disabled: bool = false
@export var echo: bool = false
@export var initial_active: bool = false:
	set(value):
		if initial_active == value:
			return
			
		initial_active = value
		if !is_inside_tree(): return
		update_animation(1.0 if initial_active else 0.0)

var active: bool = false:
	set(value):
		if active != value:
			on_toggled.emit(value)

		active = value
		if !is_node_ready(): return
		panel.active = active
		update_animation(1.0 if active else 0.0)
	
var echo_timer: Timer = null

func _ready():
	if initial_active:
		active = true

	_update()

	if fingerArea.get_script() == null:
		var script = GDScript.new()
		script.source_code = """
extends StaticBody3D
func pointer_event(event):
	get_parent()._handle_pointer_event(event)
"""
		script.reload()
		fingerArea.set_script(script)
	elif not fingerArea.has_method("pointer_event"):
		push_error("Button3D: The StaticBody3D node must have a pointer_event method to work properly.")

	Update.props(self, ["active", "external_value", "icon", "label", "font_size", "disabled"])

	if echo:
		echo_timer = Timer.new()
		echo_timer.wait_time = ECHO_WAIT_INITIAL
		echo_timer.one_shot = false

		echo_timer.timeout.connect(func():
			echo_timer.stop()
			echo_timer.wait_time=ECHO_WAIT_REPEAT
			echo_timer.start()
			on_button_down.emit()
		)

		add_child(echo_timer)
func _on_echo_timeout():
	echo_timer.wait_time = ECHO_WAIT_REPEAT
	on_button_down.emit()

func update_animation(value: float):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(body, "scale:z", lerpf(1.0, 0.5, value), 0.2)
	tween.tween_property(body, "position:z", lerpf(size.z/2, size.z/4, value), 0.2)

func _handle_pointer_event(event: XRToolsPointerEvent):
	if event.target != body: return  # Ensure events are for our body
	
	match event.event_type:
		XRToolsPointerEvent.Type.ENTERED:
			_on_pointer_entered(event)
		XRToolsPointerEvent.Type.EXITED:
			_on_pointer_exited(event)
		XRToolsPointerEvent.Type.PRESSED:
			_on_pointer_pressed(event)
		XRToolsPointerEvent.Type.RELEASED:
			_on_pointer_released(event)

func _on_pointer_entered(event: XRToolsPointerEvent):
	if disabled: return
	panel.hovering = true

func _on_pointer_exited(event: XRToolsPointerEvent):
	panel.hovering = false

func _on_pointer_pressed(event: XRToolsPointerEvent):
	if disabled: return
	
	click_sound.play()
	
	if toggleable: 
		return  # Toggle handled on release
	
	if echo:
		echo_timer.start()
	
	active = true
	on_button_down.emit()

func _on_pointer_released(event: XRToolsPointerEvent):
	if disabled: return
	
	if toggleable:
		active = !active
		if active: 
			on_button_down.emit()
		else: 
			on_button_up.emit()
	else:
		if echo: 
			echo_timer.stop()
			echo_timer.wait_time = ECHO_WAIT_INITIAL
		active = false
		on_button_up.emit()

func _update():
	body.position = Vector3(0, 0, size.z / 2)

	panel.size = Vector2(size.x, size.y)
	panel.position = Vector3(0, 0, size.z / 2)
	collision.shape.size = Vector3(size.x, size.y, size.z)
	label_node.width = size.x / label_node.pixel_size
	label_node.position = Vector3(0, 0, size.z / 2 + 0.001)
	
	## update icon scale based on button size
	if icon:
		var base_icon_scale = 0.3
		var scale_factor = 1.0
		# If the button's height is less than 0.03, adjust the icon's scale proportionally.
		if size.x < 0.03 or size.y < 0.03:
			scale_factor = min(size.x, size.y) / 0.03
		$Body/Icon.scale = Vector3(base_icon_scale * scale_factor, base_icon_scale * scale_factor, base_icon_scale * scale_factor)
