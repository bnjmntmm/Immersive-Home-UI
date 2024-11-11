extends Node
# Tempory hack until I solve problem with my headset 
# Source: https://github.com/godotengine/godot/issues/86683

# Headset position / orientation at application launch (not yet synchronized) :
@onready var uninitialized_hmd_transform:Transform3D = XRServer.get_hmd_transform()
var hmd_synchronized:bool = false

func _ready():
	# Installs the "view reset" handler :
	if $StartXR.xr_interface and $StartXR.xr_interface.is_initialized() :
		$StartXR.xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)

# Handler associated with "view reset" (synchronizes headset ORIENTATION only):
# e.g.: long press on "meta" button
func _on_openxr_pose_recentered() -> void:
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

func _process(_delta):
	if hmd_synchronized:
		return

	# Synchronizes headset ORIENTATION as soon as tracking information begins to arrive :
	if uninitialized_hmd_transform != XRServer.get_hmd_transform():
		hmd_synchronized = true
		_on_openxr_pose_recentered()
