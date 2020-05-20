extends KinematicBody2D

const MOVE_SPEED = 10
const MAX_HP = 100
const MAX_STAMINA = 100

enum HorizontalDirection { IDLE, LEFT, RIGHT }
enum VerticalDirection { IDLE, UP, DOWN }

puppet var puppet_position = Vector2()
puppet var puppet_cursor_position = Vector2()

var health_points = MAX_HP
var stamina = MAX_STAMINA

func _ready():
	update_health_bar()

func _physics_process(delta):
	var h_direction = HorizontalDirection.IDLE
	var v_direction = VerticalDirection.IDLE
	if is_network_master():
		if Input.is_action_pressed('left'):
			h_direction = HorizontalDirection.LEFT
		elif Input.is_action_pressed('right'):
			h_direction = HorizontalDirection.RIGHT
			
		if Input.is_action_pressed('up'):
			v_direction = VerticalDirection.UP
		elif Input.is_action_pressed('down'):
			v_direction = VerticalDirection.DOWN
		
		# Change the position of this node on all peers.
		rset_unreliable('puppet_position', global_position)
		
		var cursor_position = get_global_mouse_position()
		$Rifle_.look_at(cursor_position)
		rset_unreliable('puppet_cursor_position', cursor_position)
		
		if stamina <= 0 and $StaminaTimer.is_stopped():
			$StaminaTimer.start()
			
		if Input.is_action_pressed('dash') and $StaminaTimer.is_stopped():
			move(h_direction, v_direction, 10)
			stamina -= 10
		else:
			move(h_direction, v_direction)
	else:
		global_position = puppet_position
		$Rifle_.look_at(puppet_cursor_position)

func move(horizontal_direction, vertical_direction, dash_speed=0):
	if is_network_master():
		var movement_vector = Vector2(0,0)
		match horizontal_direction:
			HorizontalDirection.LEFT:
				movement_vector.x = -(MOVE_SPEED+dash_speed)
			HorizontalDirection.RIGHT:
				movement_vector.x = (MOVE_SPEED+dash_speed)
				
		match vertical_direction:
			VerticalDirection.UP:
				movement_vector.y = -(MOVE_SPEED+dash_speed)
			VerticalDirection.DOWN:
				movement_vector.y = (MOVE_SPEED+dash_speed)
		
		move_and_collide(movement_vector)

func update_health_bar():
	$GUI/HealthBar.value = health_points

func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		rpc('die')
	update_health_bar()

sync func die():
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle_/Rifle.set_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$CollisionShape2D.disabled = true

func _on_RespawnTimer_timeout():
	set_physics_process(true)
	$Rifle_/Rifle.set_process(true)
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false
	health_points = MAX_HP
	update_health_bar()

func equip(gun):
	var gun_scene
	if gun == "rifle":
		gun_scene = preload('res://weapons/rifle/Rifle.tscn')
	elif gun == 'butter':
		gun_scene = preload('res://weapons/butter/Butter.tscn')
		
	var new_gun = gun_scene.instance()
	new_gun.name = 'Rifle'
	new_gun.position = Vector2(108, -1)
	$Rifle_.remove_child($Rifle_/Rifle)
	$Rifle_.add_child(new_gun)
	get_node('/root/Game/CanvasLayer/AmmoHUD').connect_rifle()

func init(start_name, start_position):
	$GUI/Nickname.text = start_name
	global_position = start_position

func _on_StaminaTimer_timeout():
	stamina = MAX_STAMINA
	$StaminaTimer.stop()
