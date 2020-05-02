extends Node

# Default game port
const DEFAULT_PORT = 44444

# Max number of players
const MAX_PLAYERS = 12

# Players dict stored as id:name
var players = {}


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	
	create_server()


func create_server():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(host)


# Callback from SceneTree, called when client connects
func _player_connected(_id):
	print("Client ", _id, " connected")


# Callback from SceneTree, called when client disconnects
func _player_disconnected(id):
	rpc("unregister_player", id)
	print("Client ", id, " disconnected")


# Player management functions
remote func register_player(new_player_data):
	print("start of register_player")
	# We get id this way instead of as parameter, to prevent users from pretending to be other users
	var caller_id = get_tree().get_rpc_sender_id()

	# Add everyone to new player:
	for p_id in players:
		rpc_id(caller_id, "register_player", p_id, players[p_id]) # Send each player to new dude
	
	# Add him to our list
	players[caller_id] = {'name': new_player_data['name'], 'color': new_player_data['color'], 'location': new_player_data['location']}
	
	rpc("register_player", caller_id, players[caller_id]) # Send new dude to all players
	

	print(caller_id, " registered on server.")

	return caller_id

remote func update_player_position(new_player_location):
	var caller_id = get_tree().get_rpc_sender_id()
	players[caller_id]['location'] = new_player_location
	rpc("update_player", caller_id, players[caller_id]) 

puppetsync func unregister_player(id):
	players.erase(id)
	
	print("Client ", id, " was unregistered")
