extends Control

onready var status = get_node("VBox/Status")

func _ready():
	NetworkClient.connect("connection_failed", self, "connection_failed")
	NetworkClient.connect("connection_succeeded", self, "connection_succeeded")
	NetworkClient.connect("server_disconnected", self, "server_disconnected")
	NetworkClient.connect("players_updated", self, "players_updated")

func _on_JoinButton_pressed():
	NetworkClient.my_name = $VBox/HBox/LineEdit.text
	NetworkClient.connect_to_server()

func connection_succeeded():
	status.text = "Connected"
	status.modulate = Color.green
	
	$Panel.show()
	
func connection_failed():
	status.text = "Connection failed, trying again"
	status.modulate = Color.red
	
	$Panel.hide()

func server_disconnected():
	status.text = "Server Disconnected, trying to connect..."
	status.modulate = Color.red
	
	$Panel.hide()

func players_updated():
	$Panel/Players.text = String(NetworkClient.get_player_list())
