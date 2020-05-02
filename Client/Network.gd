extends Node

# Game port and ip
const DEFAULT_IP = "127.0.0.1"
# const DEFAULT_IP = "35.194.86.105"
const DEFAULT_PORT = 44444

signal connection_failed
signal connection_succeeded
signal server_disconnected
signal players_updated
signal player_registered

var my_name = "Client"
var my_color = null

var players = {}
var player_id = null

func _ready():
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("connection_failed", self, "connection_failed")
	get_tree().connect("server_disconnected", self, "server_disconnected")

# Called by the "join" button in the ConnectionUI.
func connect_to_server():
	var host = NetworkedMultiplayerENet.new()
	host.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	player_id = get_tree().get_network_unique_id()
	
	# If this function succeeds, the SceneTree (aka get_tree()) will emit its signal "connected_to_server".

# Tells server to update this client's player position.
# But only tell the server if the player has actually moved.
func update_player_position(old_player_position, new_player_position):
	if old_player_position != new_player_position:
		rpc_id(1, "update_player_position", new_player_position)
		old_player_position = new_player_position

func connected_to_server():
	# Register ourselves with the server with initial data points.
	var data = {'name': my_name, 'color': Color.blue, 'location': Vector2(0,0)}
	rpc_id(1, "register_player", data)
	emit_signal("connection_succeeded")

# "Disconnected" callback function from SceneTree. This is called when the server disconnects.
func server_disconnected():
	# Remove all known player information and try to connect again.
	players.clear()
	
	emit_signal("server_disconnected")
	
	connect_to_server()

# "Failed" callback from SceneTree. This is called when client can't connect to the server.
func connection_failed():
	 # Remove the server by nulling it out... and try to connect again.
	get_tree().set_network_peer(null)
	
	emit_signal("connection_failed")
	
	connect_to_server()

# Called by this client's master (usually the master server, aka rpc id 1).
# When this is called remotely, the master (who is remote) tells this client save a new player's data to a player dictionary.
# A new player being registered can be a different client or this one.
puppet func register_player(id, new_player_data):
	players[id] = new_player_data
	emit_signal("player_registered", id)
	emit_signal("players_updated")

# Called by this client's master, remotely.
# This function updates this client's player dictionary with whatever is in the "new_player_data".
# This function assumes this client already knows the given player id exists.
puppet func update_player(id, new_player_data):
	for key in new_player_data:
		players[id][key] = new_player_data[key]
	
	emit_signal("players_updated")

# Called by this client's master, remotely.
# This function forgets a given player id.
puppet func unregister_player(id):
	players.erase(id)
	emit_signal("players_updated")

# Returns list of player values.
func get_player_list():
	return players.values()
