extends Node2D

# Holds player ids and their actual character instances.
onready var players = {}

func _ready():
	NetworkClient.connect("player_registered", self, "create_player")
	NetworkClient.connect("players_updated", self, "update_players")

func create_player(player_id):
	var new_player = load('res://Character.tscn').instance()
	new_player.player_id = player_id
	$Spawn.add_child(new_player)
	new_player.global_position = NetworkClient.players[player_id]['location']
	new_player.get_node('Sprite').modulate = NetworkClient.players[player_id]['color']
	self.players[player_id] = new_player

func update_players():
	for player_id in NetworkClient.players:
		self.players[player_id].global_position = NetworkClient.players[player_id]['location']
		self.players[player_id].get_node('Sprite').modulate = NetworkClient.players[player_id]['color']
