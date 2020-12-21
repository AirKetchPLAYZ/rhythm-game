extends Label

export(int) var max_font_size : int = 40 #setget max_font_size_change

func _enter_tree():
	best_fit_check()
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "best_fit_check")

func best_fit_check():
	var font = get("custom_fonts/font")
	if font == null:
		return

	font.set("size", max_font_size)
	var font_size = max_font_size
	while get_visible_line_count() < get_line_count():
		font.set("size", font_size - 1)
		font_size = font.get("size")
		pass
