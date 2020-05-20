extends Control

const label_prefix = 'Ammo: '
var rifle
func _ready():
	call_deferred('connect_rifle')

func connect_rifle():
	rifle = get_node('/root/Game/' + str(get_tree().get_network_unique_id()) + '/Rifle_/Rifle')
	rifle.connect('ammo_updated', self, 'update_ammo')
	update_ammo()

func update_ammo():
	$AmmoLabel.text = label_prefix + str(rifle.ammo)
