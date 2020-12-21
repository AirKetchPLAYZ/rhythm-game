extends Control

var v = Vector2(0,0) #current velocity
var just_stop_under = 1
var multi = -4 #speed of one input
var is_grabbed = false


func _process(_delta):
	v *= 0.9
	if v.length() <= just_stop_under: v = Vector2(0,0)
	if $origin.rect_position.y + ($origin.rect_size.y * 1.2) < get_viewport_rect().size.y/2:
		v += Vector2(0,2)
	if $origin.rect_position.y > get_viewport_rect().size.y/2:
		v += Vector2(0,-2)
	$origin.rect_position += v


func _gui_input(event):

	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_MIDDLE:  is_grabbed = event.pressed

	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_DOWN:  v.y += multi
			BUTTON_WHEEL_UP:    v.y -= multi
			BUTTON_WHEEL_RIGHT: v.x += multi
			BUTTON_WHEEL_LEFT:  v.x -= multi
