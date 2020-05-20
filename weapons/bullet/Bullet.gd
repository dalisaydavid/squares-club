extends Area2D

export(float) var SPEED = 2000
export(float) var DAMAGE = 15
export(float) var live_time = 1

var direction = 0

func _ready():
	set_as_toplevel(true)
	
	$LiveTimer.wait_time = live_time

func _process(delta):
	position.x += direction.x * SPEED * delta
	position.y += direction.y * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group('players'):
		body.damage(DAMAGE)
	
	
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_LiveTimer_timeout():
	queue_free()
