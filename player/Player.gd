extends KinematicBody2D

const MOVE_SPEED = 10
const MAX_HP = 100

enum Direction { IDLE, UP, DOWN, LEFT, RIGHT }

puppet var puppet_position = Vector2()
puppet var puppet_direction = null

var health_points = MAX_HP
var dash_speed = 0

func _ready():
	update_health_bar()

func _physics_process(delta):
	var direction = Direction.IDLE
	if is_network_master():
		if Input.is_action_pressed('left'):
			direction = Direction.LEFT
		elif Input.is_action_pressed('right'):
			direction = Direction.RIGHT
		elif Input.is_action_pressed('up'):
			direction = Direction.UP
		elif Input.is_action_pressed('down'):
			direction = Direction.DOWN
			
		if Input.is_action_pressed('dash'):
			dash_speed = 10
		elif Input.is_action_just_released('dash'):
			dash_speed = 0
		
		# Change the position of this node on all peers.
		rset_unreliable('puppet_position', position)
		
		# Change the direction of this node on all peers.
		rset('puppet_direction', direction)
		
		move(direction)
	else:
		move(puppet_direction)

func move(direction):
	if is_network_master():
		match direction:
			Direction.IDLE:
				return
			Direction.UP:
				move_and_collide(Vector2(0, -(MOVE_SPEED+dash_speed)))
			Direction.DOWN:
				move_and_collide(Vector2(0, (MOVE_SPEED+dash_speed)))
			Direction.LEFT:
				move_and_collide(Vector2(-(MOVE_SPEED+dash_speed), 0))
				_rifle_left()
			Direction.RIGHT:
				move_and_collide(Vector2((MOVE_SPEED+dash_speed), 0))
				_rifle_right()
	else:
		match direction:
			Direction.LEFT:
				_rifle_left()
			Direction.RIGHT:
				_rifle_right()
		
		position = puppet_position
		
func _rifle_right():
	$Rifle.position.x = abs($Rifle.position.x)
	$Rifle.flip_h = false

func _rifle_left():
	$Rifle.position.x = -abs($Rifle.position.x)
	$Rifle.flip_h = true

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
	$Rifle.set_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$CollisionShape2D.disabled = true

func _on_RespawnTimer_timeout():
	set_physics_process(true)
	$Rifle.set_process(true)
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false
	health_points = MAX_HP
	update_health_bar()

func init(start_name, start_position):
	$GUI/Nickname.text = start_name
	global_position = start_position
