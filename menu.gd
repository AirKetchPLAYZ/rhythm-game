extends Control


signal song_chosen

func song_chosen(mapname, path, ext):
	print("song chosen: " + path)
	emit_signal("song_chosen", mapname, path, ext)
