extends Control

var MapLoader = preload("res://maploader.gd")

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func _ready():
	var directory = Directory.new()
	var file = File.new()
	for dir in list_files_in_directory("user://Maps/"):
		if directory.dir_exists("user://Maps/" + dir):

			if file.file_exists("user://Maps/" + dir + "/" + dir + ".aclm") and (file.file_exists("user://Maps/" + dir + "/song.ogg") or file.file_exists("user://Maps/" + dir + "/song.wav")):
				var ext
				if file.file_exists("user://Maps/" + dir + "/song.ogg"):
					ext = "ogg"
				else:
					ext = "wav"
				var map = MapLoader.new("user://Maps/" + dir + "/" + dir + ".aclm")
				if not map.error:
					var entry = load("res://SongListEntry.tscn").instance()
					entry.find_node("Label").text = map.name
					$ScrollContainer/origin.add_child(entry)
					entry.find_node("Button").connect("pressed", get_parent(), "song_chosen", [dir, "user://Maps/" + dir + "/" + dir + ".aclm", ext])
				else:
					print("error loading map: " + dir)
			else:
				print("MAP INCOMPLETE: " + dir)
