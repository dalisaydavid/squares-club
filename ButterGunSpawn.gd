extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Blink")


func _on_RifleGunSpawn_body_entered(body):
	if body.get_name() == str(get_tree().get_network_unique_id()) and body.is_network_master():
		body.equip('rifle')


func _on_ButterGunSpawn_body_entered(body):
	if body.get_name() == str(get_tree().get_network_unique_id()) and body.is_network_master():
		body.equip('butter')
