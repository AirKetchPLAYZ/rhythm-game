extends CanvasLayer


func start():
	print("button pressed")
	$UITween.remove_all()
	$UITween.interpolate_property($Menu/Button, "rect_scale", Vector2(1,1), Vector2(0,0), 0.5)
	$UITween.interpolate_property($Menu/SongSelection, "rect_scale", Vector2(0,0), Vector2(1,1), 1)
	$UITween.start()
