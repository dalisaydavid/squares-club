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
	
	if (Input.is_key_pressed(KEY_A)):
		global_position.x += (-walk_speed*delta)
	elif (Input.is_key_pressed(KEY_D)):
		global_position.x +=  (walk_speed*delta)
	elif (Input.is_key_pressed(KEY_W)):
		global_position.y += (-walk_speed*delta)
	elif (Input.is_key_pressed(KEY_S)):
		global_position.y +=  (walk_speed*delta)
		

	if (Input.is_action_just_released("shoot")):
		shoot()
	# Tells server to update this client's player position.
	# But only tell the server if the player has actually moved.
	Network.send_to_server({'location': global_position})
	
func shoot():
	var new_projectile = load('res://Projectile.tscn').instance()
	get_parent().add_child(new_projectile)
	new_projectile.global_position = global_position
	
	Network.send_to_server({'projectile'})
