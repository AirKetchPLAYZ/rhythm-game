extends Control

var songdir = Directory.new()

var paused = false

var MapLoader = preload("res://maploader.gd")
var circle = preload("res://circle.tscn")
var numberText = preload("res://num.tscn")

# Default values. They have no effect but they are still here since I cannot be bothered to remove their values.
# They had a use before maploading was added

var AR: float = 80

var map = [
]

var drain = 0.633333335

var maps

# Values to keep track of the game state, among other things

var nodestarts = {}

var draining = false

var lastpos

var dead = true

var regen = false

var ticks = -AR

var pos

var health = 100

var already_died = true

var menu

func restart():
	print("restart")
	paused = false
	health = 100
	draining = true
	dead = false
	already_died = false
	ticks = -AR
	$AudioStreamPlayer.volume_db = 0
	$AudioStreamPlayer.seek(0)
	$AudioStreamPlayer.pitch_scale = 1
	if get_tree().root.find_node("GameOver", true, false):
		get_tree().root.find_node("GameOver", true, false).queue_free()
	if get_parent().get_parent().find_node("Results"):
		get_parent().get_parent().find_node("Results").queue_free()
	for child in get_parent().get_parent().get_children():
		if child.name == "Menu" or child.name == "Results":
			child.queue_free()
	for node in get_parent().get_children():
		if node is Area2D:
			node.queue_free()
	get_parent().get_parent().find_node("Pause").visible = false
	$AudioStreamPlayer.stream_paused = paused
		
func _ready():
# warning-ignore:return_value_discarded
	get_parent().get_parent().find_node("Pause").find_node("Resume").connect("pressed", self, "unpause")
# warning-ignore:return_value_discarded
	get_parent().get_parent().find_node("Pause").find_node("Restart").connect("pressed", self, "restart")
# warning-ignore:return_value_discarded
	get_parent().get_parent().find_node("Pause").find_node("Menu").connect("pressed", self, "return_to_menu")
	menu = load("res://menu.tscn").instance()
	menu.connect("song_chosen", self, "_on_Menu_song_chosen")
	menu.find_node("Button").connect("pressed", get_parent().get_parent(), "start")
	menu.name = "Menu"
	get_parent().get_parent().call_deferred("add_child", menu)

func _physics_process(_delta):
	if dead and not already_died:
		print("death")
		already_died = true
		$AudioStreamPlayer/Tween.interpolate_property($AudioStreamPlayer, "pitch_scale", 1, 0.7, 5)
		$AudioStreamPlayer/Tween.start()
		$AudioStreamPlayer/Timer.start()
		$AudioStreamPlayer.pitch_scale = 0.7
		for node in get_parent().get_children():
			if node.name == "AudioStreamPlayer":
				print("skip")
			for noded in node.get_children():
				if (noded.name == "Tween"):
					noded.stop_all()
					noded.interpolate_property(node, "position", Vector2(node.position.x, node.position.y), Vector2(node.position.x, $Hit1.global_position.y + $Hit1.find_node("Hit1").rect_size.y), 5)
					noded.start()
				if (noded.name == "Timer" or noded.name == "Timer2"):
					noded.stop()
					noded.wait_time = 5
					noded.start()
		var gameOver = preload("res://gameover.tscn").instance()
		gameOver.name = "GameOver"
		gameOver.find_node("Timer", false, true).start()
		gameOver.find_node("Button").connect("pressed", self, "restart")
		gameOver.find_node("menu").connect("pressed", self, "return_to_menu")
		get_parent().get_parent().add_child(gameOver)
	if health > 100:
		health = 100
	if health < 0:
		dead = true
	if ticks > 60 and draining and not paused:
		health = health - drain
	get_parent().find_node("ProgressBar").value = health
	layoutmap()
	if ticks == 0:
		print("play")
		$AudioStreamPlayer.playing = true
		print($AudioStreamPlayer.pitch_scale)
	if not dead:
		if regen and health == 100:
			regen = false
			draining = true
		elif regen:
			health = health + 2
		for arr in map:
			var key = arr[0]
			if arr[1] == 8 and ticks == key:
				print("Regenerating HP")
				draining = false
				regen = true
			if arr[1] == 5 and ticks == key:
				print("End of song!")
				$AudioStreamPlayer/Tween.interpolate_property($AudioStreamPlayer, "volume_db", 0, -80, 5)
				$AudioStreamPlayer/Tween.start()
				$AudioStreamPlayer/Timer.start(5)
				draining = false
				dead = true
				already_died = true
				var res = load("res://Results.tscn").instance()
				res.find_node("Label").text = "Score: " + self.get_parent().find_node("Score").text
				res.find_node("restart").connect("pressed", self, "restart")
				res.find_node("menu").connect("pressed", self, "return_to_menu")
				res.name = "Results"
				get_parent().get_parent().add_child(res)
			if arr[1] == 6 and ticks == key:
				print("Pause drain")
				draining = false
			if arr[1] == 7 and ticks == key:
				print("Resume drain")
				draining = true
			if arr[1] < 5:
				if ticks == key - AR:
					print("spawning note! ticks: " + str(ticks))
					var circ = circle.instance()
					var a1 = int(arr[1])
					circ.position = pos.get(a1)
					self.get_parent().add_child(circ)
					var nt = Tween.new()
					nt.name = "Tween"
					circ.add_child(nt)
					nt.interpolate_property(circ, "position", Vector2(circ.position.x, self.rect_position.y - 510 - circ.find_node("TextureRect").rect_size.y), Vector2(circ.position.x, $Hit1.global_position.y), AR/60)
					nt.start()
					var t = Timer.new()
					t.name = "Timer"
					circ.add_child(t)
					t.connect("timeout", circ, "TweenDown", [(AR/60)/10, $Hit1.global_position.y + $Hit1/Hit1.rect_size.y])
					t.set_wait_time(AR/60)
					t.start()
					var tt = Timer.new()
					tt.name = "Timer2"
					circ.add_child(tt)
					tt.connect("timeout", circ, "queue_free")
					tt.set_wait_time(AR/60 + (AR/60)/10)
					tt.start()
					nodestarts[circ.get_instance_id()] = ticks
	if not dead and not paused:
		ticks += 1

func _input(input):
	if input.is_action_pressed("ui_cancel") and not dead:
		paused = not paused
		get_parent().get_parent().find_node("Pause").visible = paused
		$AudioStreamPlayer.stream_paused = paused
		if paused:
			for node in get_parent().get_children():
				for noded in node.get_children():
					if (noded.name == "Tween"):
						noded.stop_all()
					if noded.name == "Timer" or noded.name == "Timer2":
						noded.paused = true
		else:
			for node in get_parent().get_children():
				for noded in node.get_children():
					if (noded.name == "Tween"):
						noded.resume_all()
					if noded.name == "Timer" or noded.name == "Timer2":
						noded.paused = false
	if input.is_action_pressed("piano_1"):
		if draining:
			health -= 20
		for area in $Hit1.get_overlapping_areas():
			if area.get_child_count() > 5:
				continue
			for child in area.get_children():
				if child.name == "Tween":
					child.remove_all()
				if child.name == "Timer" or child.name == "Timer2":
					child.stop()
					if child.name == "Timer2":
						child.start(5 + (AR/60)/10)
					else:
						child.start(5)
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit1.global_position)))
			var t = Tween.new()
			nt.add_child(t)
			t.interpolate_property(area, "global_position", area.global_position, $Hit5.global_position, 0.1)
			ct.add_child(nt)
			area.add_child(ct)
			t.start()
			self.get_parent().find_node("Score").text = str(int(self.get_parent().find_node("Score").text) + int(100-area.global_position.distance_to($Hit1.global_position)))
			health = health + (20 + (100 - area.global_position.distance_to($Hit1.global_position)) / 4)
	if input.is_action_pressed("piano_2"):
		if draining:
			health -= 20
		for area in $Hit2.get_overlapping_areas():
			if area.get_child_count() > 5:
				continue
			for child in area.get_children():
				if child.name == "Tween":
					child.remove_all()
				if child.name == "Timer" or child.name == "Timer2":
					child.stop()
					if child.name == "Timer2":
						child.start(5 + (AR/60)/10)
					else:
						child.start(5)
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit2.global_position)))
			var t = Tween.new()
			nt.add_child(t)
			t.interpolate_property(area, "global_position", area.global_position, $Hit5.global_position, 0.1)
			ct.add_child(nt)
			area.add_child(ct)
			t.start()
			self.get_parent().find_node("Score").text = str(int(self.get_parent().find_node("Score").text) + int(100-area.global_position.distance_to($Hit2.global_position)))
			health = health + (20 + (100 - area.global_position.distance_to($Hit2.global_position)) / 4)
	if input.is_action_pressed("piano_3"):
		if draining:
			health -= 20
		for area in $Hit3.get_overlapping_areas():
			if area.get_child_count() > 5:
				continue
			for child in area.get_children():
				if child.name == "Tween":
					child.remove_all()
				if child.name == "Timer" or child.name == "Timer2":
					child.stop()
					if child.name == "Timer2":
						child.start(5 + (AR/60)/10)
					else:
						child.start(5)
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit3.global_position)))
			var t = Tween.new()
			nt.add_child(t)
			t.interpolate_property(area, "global_position", area.global_position, $Hit5.global_position, 0.1)
			ct.add_child(nt)
			area.add_child(ct)
			t.start()
			self.get_parent().find_node("Score").text = str(int(self.get_parent().find_node("Score").text) + int(100-area.global_position.distance_to($Hit3.global_position)))
			health = health + (20 + (100 - area.global_position.distance_to($Hit3.global_position)) / 4)
	if input.is_action_pressed("piano_4"):
		if draining:
			health -= 20
		for area in $Hit4.get_overlapping_areas():
			if area.get_child_count() > 5:
				continue
			for child in area.get_children():
				if child.name == "Tween":
					child.remove_all()
				if child.name == "Timer" or child.name == "Timer2":
					child.stop()
					if child.name == "Timer2":
						child.start(5 + (AR/60)/10)
					else:
						child.start(5)
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit4.global_position)))
			var t = Tween.new()
			nt.add_child(t)
			t.interpolate_property(area, "global_position", area.global_position, $Hit5.global_position, 0.1)
			ct.add_child(nt)
			area.add_child(ct)
			t.start()
			self.get_parent().find_node("Score").text = str(int(self.get_parent().find_node("Score").text) + int(100-area.global_position.distance_to($Hit4.global_position)))
			health = health + (20 + (100 - area.global_position.distance_to($Hit4.global_position)) / 4)
func layoutmap():
	if get_viewport_rect().size != lastpos: lastpos = get_viewport_rect().size
	else: return
	get_parent().rect_position = Vector2(get_viewport_rect().size.x/2 - ($Hit1.find_node("Hit1").rect_size.x * 2), 0)

	for node in get_parent().get_children():
		for noded in node.get_children():
			if (noded.name == "Tween"):
				noded.stop_all()
				noded.interpolate_property(node, "position", Vector2(node.position.x, node.position.y), Vector2(node.position.x, $Hit1.global_position.y + $Hit1.find_node("Hit1").rect_size.y), (AR-(ticks-nodestarts[node.get_instance_id()]))/60)
				noded.start()


func _on_Menu_song_chosen(mapname, path, ext):
	var f = File.new()
	f.open("user://Maps/" + mapname + "/song." + ext, File.READ)
	maps = MapLoader.new(path)
	drain = maps.drain
	AR = maps.AR
	map = maps.data
	print(map)
	lastpos = get_viewport_rect().size
	pos = {
		4: Vector2($Hit4.position.x, -110),
		3: Vector2($Hit3.position.x, -110),
		2: Vector2($Hit2.position.x, -110),
		1: Vector2($Hit1.position.x, -110)
	}
	var bytes = f.get_buffer(f.get_len())
	var stream
	if ext == "wav":
		stream = AudioStreamSample.new()
		stream.format = AudioStreamSample.FORMAT_16_BITS
		stream.stereo = true
		stream.mix_rate = 48000
		print(stream.mix_rate)
	else:
		stream = AudioStreamOGGVorbis.new()
		print("ogg")
	stream.data = bytes
	$AudioStreamPlayer.stream = stream
	get_parent().get_parent().find_node("UITween").interpolate_callback(self, 1, "restart")
	get_parent().get_parent().find_node("UITween").interpolate_property(menu, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1)
	get_parent().get_parent().find_node("UITween").start()
	

func unpause():
	paused = false
	get_parent().get_parent().find_node("Pause").visible = false
	$AudioStreamPlayer.stream_paused = paused
	for node in get_parent().get_children():
		for noded in node.get_children():
			if (noded.name == "Tween"):
				noded.resume_all()
			if noded.name == "Timer" or noded.name == "Timer2":
				noded.paused = false

func return_to_menu():
	menu = load("res://menu.tscn").instance()
	menu.connect("song_chosen", self, "_on_Menu_song_chosen")
	menu.find_node("Button").connect("pressed", get_parent().get_parent(), "start")
	menu.name = "Menu"
	for child in get_parent().get_parent().get_children():
		if child.name == "Results" or child.name == "GameOver":
			child.queue_free()
		if child.name == "Pause":
			child.visible = false
	get_parent().get_parent().call_deferred("add_child", menu)
