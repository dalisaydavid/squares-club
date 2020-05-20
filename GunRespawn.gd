extends Area2D

export var gun = "rifle"
export(Color, RGBA) var color = Color.white

func _ready():
	$Sprite.modulate = color
	$AnimationPlayer.play('blink')
	
func _on_GunRespawn_body_entered(body):
	if body.is_network_master():
		body.equip(gun)
		
