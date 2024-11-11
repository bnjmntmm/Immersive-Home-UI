extends Node3D

@onready var Menu = $Menu
@onready var ColorSphere = $ColorSphere

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_sphere_color()
	
	Menu.value_changed.connect(func():
		_update_sphere_color()
	)
	
	Menu.visible_pressed.connect(func():
		print("Here")
		ColorSphere.visible = not ColorSphere.visible
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_sphere_color():
	var material = ColorSphere.get_active_material(0)
		
	material.albedo_color = Color(Menu.red_value, Menu.green_value, Menu.blue_value)
	print(material.albedo_color)
