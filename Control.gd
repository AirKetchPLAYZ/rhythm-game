extends Control

var circle = preload("res://circle.tscn")
var numberText = preload("res://num.tscn")

var AR: float = 60

var testmap = {
	60: 1,
	120: 2,
	180: 3,
	240: 4,
	300: 3,
	360: 2
}

var nodestarts = {}

var lastpos

var ticks = -AR

var pos

var health = 100

func _ready():
	lastpos = get_viewport_rect().size
	pos = {
		4: Vector2($Hit4.position.x, -110),
		3: Vector2($Hit3.position.x, -110),
		2: Vector2($Hit2.position.x, -110),
		1: Vector2($Hit1.position.x, -110)
	}

func _physics_process(_delta):
	if health > 100:
		health = 100
	if ticks > 60:
		health = health - 0.833
	get_parent().find_node("ProgressBar").value = health
	layoutmap()
	if ticks == 0:
		$AudioStreamPlayer.play()
	for key in testmap.keys():
		if ticks == key - AR:
			var circ = circle.instance()
			circ.position = pos[testmap[key]]
			#circ.position = Vector2(circ.position.x, 60)
			self.get_parent().add_child(circ)
			var nt = Tween.new()
			nt.name = "Tween"
			circ.add_child(nt)
			nt.interpolate_property(circ, "position", Vector2(circ.position.x, self.rect_position.y - 510 - circ.find_node("TextureRect").rect_size.y), Vector2(circ.position.x, $Hit1.global_position.y + $Hit1.find_node("Hit1").rect_size.y), AR/60)
			nt.start()
			var t = Timer.new()
			nt.add_child(t)
			t.connect("timeout", circ, "queue_free")
			t.set_wait_time(AR/60)
			t.start()
			nodestarts[circ.get_instance_id()] = ticks
	ticks += 1

func _input(input):
	if input.is_action_pressed("piano_1"):
		for area in $Hit1.get_overlapping_areas():
			if area.get_child_count() > 3:
				continue
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit1.global_position)))
			ct.add_child(nt)
			area.add_child(ct)
			self.get_parent().find_node("Label").text = str(int(self.get_parent().find_node("Label").text) + int(100-area.global_position.distance_to($Hit1.global_position)))
			health = health + (20 + area.global_position.distance_to($Hit1.global_position))
	if input.is_action_pressed("piano_2"):
		for area in $Hit2.get_overlapping_areas():
			if area.get_child_count() > 3:
				continue
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit2.global_position)))
			ct.add_child(nt)
			area.add_child(ct)
			self.get_parent().find_node("Label").text = str(int(self.get_parent().find_node("Label").text) + int(100-area.global_position.distance_to($Hit2.global_position)))
			health = health + (20 + area.global_position.distance_to($Hit2.global_position))
	if input.is_action_pressed("piano_3"):
		for area in $Hit3.get_overlapping_areas():
			if area.get_child_count() > 3:
				continue
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit3.global_position)))
			ct.add_child(nt)
			area.add_child(ct)
			self.get_parent().find_node("Label").text = str(int(self.get_parent().find_node("Label").text) + int(100-area.global_position.distance_to($Hit3.global_position)))
			health = health + (20 + area.global_position.distance_to($Hit3.global_position))
	if input.is_action_pressed("piano_4"):
		for area in $Hit4.get_overlapping_areas():
			if area.get_child_count() > 3:
				continue
			var ct = CenterContainer.new()
			ct.rect_size = area.find_node("TextureRect").rect_size
			var nt = numberText.instance()
			nt.text = str(int(100-area.global_position.distance_to($Hit4.global_position)))
			ct.add_child(nt)
			area.add_child(ct)
			self.get_parent().find_node("Label").text = str(int(self.get_parent().find_node("Label").text) + int(100-area.global_position.distance_to($Hit4.global_position)))
			health = health + (20 + area.global_position.distance_to($Hit4.global_position))
func layoutmap():
	if get_viewport_rect().size != lastpos: lastpos = get_viewport_rect().size
	else: return
	self.rect_position = Vector2(0, get_viewport_rect().size.y - $Hit1.find_node("Hit1").rect_size.y)
	for node in get_parent().get_children():
		for noded in node.get_children():
			if (noded.name == "Tween"):
				noded.stop_all()
				noded.interpolate_property(node, "position", Vector2(node.position.x, node.position.y), Vector2(node.position.x, $Hit1.global_position.y + $Hit1.find_node("Hit1").rect_size.y), (AR-(ticks-nodestarts[node.get_instance_id()]))/60)
				noded.start()
