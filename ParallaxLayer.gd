extends ParallaxLayer

func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_ENTER:
			motion_offset = Vector2(0,0)


func _ready():
	#OS.window_borderless = true
	#OS.window_maximized = true
	$TextureRect.rect_size = get_viewport().size * 1.2
	$TextureRect.rect_position = -(Vector2($TextureRect.rect_size.x * 0.08, $TextureRect.rect_size.y * 0.09))
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "resized")

func resized():
	motion_offset = Vector2(0,0)
	$TextureRect.rect_size = get_viewport().size * 1.2
	$TextureRect.rect_position = -(Vector2($TextureRect.rect_size.x * 0.08, $TextureRect.rect_size.y * 0.1))

func _input(event):
	if event is InputEventMouseMotion:
		#print(event.relative)
		motion_offset += event.relative * 0.1
