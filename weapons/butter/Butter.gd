extends Sprite

signal ammo_updated

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
const MAX_AMMO = 3
const MAX_RELOAD_TIME_IN_SECONDS = 1
var ammo = MAX_AMMO

sync var cursor_position = Vector2()

func _ready():
	$ReloadTimer.wait_time = MAX_RELOAD_TIME_IN_SECONDS
	
func _process(delta):
	if get_parent().is_network_master():
		if ammo <= 0 and $ReloadTimer.is_stopped():
			reload(MAX_AMMO-ammo)
		
		if Input.is_action_pressed('reload') and $ReloadTimer.is_stopped():
			reload(MAX_AMMO-ammo)
		
		if Input.is_action_pressed('shoot') and $ShootTimer.is_stopped() and ammo > 0 and $ReloadTimer.is_stopped():
				get_node('/root/Game/Camera').start_shake()
				rpc('shoot')
				ammo = ammo - 1
				emit_signal('ammo_updated')
				$ShootTimer.start()

		rset_unreliable('cursor_position', get_global_mouse_position())
		

func _on_Timer_timeout():
	$ShootTimer.stop()

sync func shoot():
	var bullet = Bullet.instance()
	bullet.live_time = 0.25
	get_node('/root/Game').add_child(bullet)
	bullet.global_position = global_position
	bullet.DAMAGE = 30
	bullet.direction = (cursor_position-bullet.global_position).normalized()
	bullet.get_node('LiveTimer').start()
	
	var bullet_up = Bullet.instance()
	bullet_up.live_time = 0.25
	get_node('/root/Game').add_child(bullet_up)
	bullet_up.global_position = global_position
	bullet_up.DAMAGE = 30
	bullet_up.direction = (cursor_position-bullet.global_position).normalized().rotated(deg2rad(15))
	bullet_up.get_node('LiveTimer').start()
	
	var bullet_down = Bullet.instance()
	bullet_down.live_time = 0.25
	get_node('/root/Game').add_child(bullet_down)
	bullet_down.global_position = global_position
	bullet_down.DAMAGE = 30
	bullet_down.direction = (cursor_position-bullet.global_position).normalized().rotated(deg2rad(-15))
	bullet_down.get_node('LiveTimer').start()

func reload(ammo):
	# Reload time is dynamically set based on how much ammo is actually being reloaded.
	# If your rifle only has to reload 1 bullet vs 10 bullets, the reload time is much faster.
	var reload_time = (ammo/float(MAX_AMMO))*MAX_RELOAD_TIME_IN_SECONDS
	$ReloadTimer.wait_time = reload_time
	modulate = Color.red
	$ReloadTimer.start()

func _on_ReloadTimer_timeout():
	modulate = Color.white
	ammo = MAX_AMMO
	emit_signal('ammo_updated')
	$ReloadTimer.stop()
	# $ReloadTimer.wait_time = MAX_WAIT_TIME_IN_SECONDS
