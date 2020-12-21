var error = false
var name
var AR
var drain
var data

func _init(songName):
	var file = File.new()
	file.open(songName, File.READ)
	var json = JSON.parse(file.get_as_text())
	if not json.error == OK:
		error = true
		return
	drain = json.result.get("drain")
	name = json.result.get("name")
	AR = json.result.get("AR")
	data = json.result.get("map")
	print(data)
	if not (typeof(AR) == TYPE_INT or typeof(AR) == TYPE_REAL) or not (typeof(name) == TYPE_STRING) or not (typeof(drain) == TYPE_INT or typeof(drain) == TYPE_REAL):
		error = true
		return 
