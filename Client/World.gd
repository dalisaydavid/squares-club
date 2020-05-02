extends Node2D

# Holds player ids and their actual character instances.
onready var players = {}

func _ready():
	Network.connect("player_registered", self, "create_player")
	Network.connect("players_updated", self, "update_players")
	Network.connect("player_unregistered", self, "remove_player")
	
func create_player(player_id):
	var new_player = load('res://Character.tscn').instance()
	new_player.player_id = player_id
	$Spawn.add_child(new_player)
	new_player.global_position = Network.players[player_id]['location']
	new_player.get_node('Sprite').modulate = Network.players[player_id]['color']
	self.players[player_id] = new_player

func remove_player(player_id):
	var player = players[player_id]
	players.erase(player_id)
	player.queue_free()

func update_players():
	for player_id in Network.players:
		self.players[player_id].global_position = Network.players[player_id]['location']
		self.players[player_id].get_node('Sprite').modulate = Network.players[player_id]['color']
