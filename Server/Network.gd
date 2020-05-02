extends Node

const DEFAULT_PORT = 44444
const MAX_PLAYERS = 10

var players = {}

func _ready():
	# Connect SceneTree's network signals.
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self,"player_disconnected")
	
	# Since this is the server... create the server.
	create_server()
	
func create_server():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(host)

func player_connected(player_id):
	print("Client ", player_id, " connected")

func player_disconnected(player_id):
	# Tell all other players that player_id has disconnected.
	# This calls the server's unregister_player too, because I wanted to use puppetsync omegalul.
	rpc("unregister_player", player_id)
	print("Client ", player_id, " disconnected")

# Remotely called by a client when a client is registering themselves to the server.
remote func register_player(new_player_data):
	var new_player_id = get_tree().get_rpc_sender_id()

	# Tell the new player about all the other players.
	# And register the other players to the new player.
	for player_id in players:
		rpc_id(new_player_id, "register_player", player_id, players[player_id])
	
	# Add the new player to the global list of players.
	players[new_player_id] = new_player_data
	
	# Tell all other players about the new player.
	rpc("register_player", new_player_id, players[new_player_id])
	
	print(new_player_id, " registered on server.")

	return new_player_id

# Remotely called by a client when a client wants to tell all others that they've moved positions.
remote func update_player_position(new_player_location):
	var caller_id = get_tree().get_rpc_sender_id()
	players[caller_id]['location'] = new_player_location
	
	for player_id in players:
		if player_id == caller_id:
			continue
		rpc_id(player_id, "update_player", caller_id, players[caller_id]) 

puppetsync func unregister_player(id):
	players.erase(id)
	print("Client ", id, " was unregistered")
