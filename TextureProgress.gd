extends TextureProgress

var shown = false

var last_modified

func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.4)
	$Tween.interpolate_callback(self, 1, "fade_out")
	$Tween.start()
	shown = true

func fade_out():
	if OS.get_ticks_msec() - last_modified < 800:
		$Tween.interpolate_callback(self, 1, "fade_out")
		$Tween.start()
		return
	shown = false
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(0,0,0,0), 0.4)
	$Tween.start()

func _physics_process(_delta):
	if Input.is_action_just_released("vol_down"):
		if not shown:
			fade_in()
		last_modified = OS.get_ticks_msec()
		value -= 3
	if Input.is_action_just_released("vol_up"):
		if not shown:
			fade_in()
		last_modified = OS.get_ticks_msec()
		value += 3
	AudioServer.set_bus_volume_db(0, value)
