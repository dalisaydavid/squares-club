extends Camera2D

export var shake_on = false
export var shake_amount = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

func _physics_process(delta):
	global_position = get_node('/root/Game/' + str(get_tree().get_network_unique_id())).global_position
	
	# if shake_on:
	#	shake()

func start_shake():
	shake_on = true
	$ShakeTimer.start()
	
func shake():
	if shake_on:
		self.set_offset(Vector2( \
			rand_range(-1.0, 1.0) * shake_amount, \
			rand_range(-1.0, 1.0) * shake_amount \
		))

func _on_ShakeTimer_timeout():
	shake_on = false
