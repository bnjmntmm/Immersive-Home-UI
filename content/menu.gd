extends StaticBody3D

signal value_changed
signal visible_pressed

@onready var SliderRed = $SliderRed
@onready var SliderBlue = $SliderBlue
@onready var SliderGreen = $SliderGreen
@onready var BtnVisible = $BtnVisible

var red_value: float
var green_value: float
var blue_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	SliderRed.on_value_changed.connect(func(value):
		red_value = value
		value_changed.emit()
	)
	
	SliderGreen.on_value_changed.connect(func(value):
		green_value = value
		value_changed.emit()
	)
	
	SliderBlue.on_value_changed.connect(func(value):
		blue_value = value
		value_changed.emit()
	)
	
	BtnVisible.on_button_up.connect(func():
		visible_pressed.emit()
	)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
