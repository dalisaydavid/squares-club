extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
const MAX_AMMO = 10
var ammo = MAX_AMMO

func _process(delta):
	if is_network_master():
		if ammo <= 0 and $ReloadTimer.is_stopped():
			reload()
		
		if Input.is_action_pressed('shoot') and $ShootTimer.is_stopped() and ammo > 0:
				get_node('/root/Game/Camera2D').start_shake()
				rpc('shoot')
				ammo = ammo - 1
				$ShootTimer.start()

func _on_Timer_timeout():
	$ShootTimer.stop()

sync func shoot():
	var bullet = Bullet.instance()
	get_node('/root/Game').add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = -1 if flip_h else 1

func reload():
	if not $ReloadTimer.is_stopped():
		return
	modulate = Color.red
	$ReloadTimer.start()

func _on_ReloadTimer_timeout():
	modulate = Color.white
	ammo = MAX_AMMO
	$ReloadTimer.stop()
