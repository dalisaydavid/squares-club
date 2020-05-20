extends Sprite

signal ammo_updated

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
const MAX_AMMO = 15
const MAX_RELOAD_TIME_IN_SECONDS = 1
var ammo = MAX_AMMO

sync var cursor_position = Vector2()

func _ready():
	$ReloadTimer.wait_time = MAX_RELOAD_TIME_IN_SECONDS
	
func _process(delta):
	
	if is_network_master():
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
	get_node('/root/Game').add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = (cursor_position-bullet.global_position).normalized()

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
