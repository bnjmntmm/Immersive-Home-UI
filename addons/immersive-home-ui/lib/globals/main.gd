extends Node

const Main = preload ("res://content/main.gd")
const ControllerLeft = preload ("res://addons/immersive-home-ui/content/system/controller_left/controller_left.gd")
const ControllerRight = preload ("res://addons/immersive-home-ui/content/system/controller_right/controller_right.gd")

@onready var main: Main = get_node_or_null("/root/Main")
@onready var camera: XRCamera3D = get_node_or_null("/root/Main/XROrigin3D/XRCamera3D")
@onready var controller_left: ControllerLeft = get_node_or_null("/root/Main/XROrigin3D/XRControllerLeft")
@onready var controller_right: ControllerRight = get_node_or_null("/root/Main/XROrigin3D/XRControllerRight")
