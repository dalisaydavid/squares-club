extends Node

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://player/Player.tscn').instance()
	var player_id = get_tree().get_network_unique_id()
	new_player.name = str(player_id)
	new_player.set_network_master(player_id)
	add_child(new_player)
	new_player.init(Network.data['name'], Network.data['position'])

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/Menu.tscn')

