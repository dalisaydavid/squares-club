extends Node2D

onready var walk_speed = 200
var player_id = null

func _ready():
	# Character created with a random data.
	randomize()
	global_position = Vector2(rand_range(0.0, 1024.0), rand_range(0.0, 600.0))
	$Sprite.modulate = Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.5, 1.0))

	set_process(true)

func _process(delta):
	if player_id != Network.player_id or player_id == null:
		return
		
	var old_player_position = global_position
	
	if (Input.is_key_pressed(KEY_A)):
		global_position.x += (-walk_speed*delta)
	elif (Input.is_key_pressed(KEY_D)):
		global_position.x +=  (walk_speed*delta)
	elif (Input.is_key_pressed(KEY_W)):
		global_position.y += (-walk_speed*delta)
	elif (Input.is_key_pressed(KEY_S)):
		global_position.y +=  (walk_speed*delta)

	Network.update_player_position(old_player_position, global_position)
