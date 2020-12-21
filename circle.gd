extends Area2D


func TweenDown(time, pos):
	$Tween.interpolate_property(self, "position", Vector2(self.position.x, self.position.y), Vector2(self.position.x, pos), time)
	$Tween.start()
