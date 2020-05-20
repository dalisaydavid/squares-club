extends Control

var player_name = ''
var server_host = ''

func _on_CreateButton_pressed():
	Network.create_server(player_name)
	start_game()

func _on_JoinButton_pressed():
	Network.ip = server_host
	Network.connect_to_server(player_name)
	start_game()

func start_game():
	get_tree().change_scene('res://Map0.tscn')

func _on_HostField_text_changed(new_text):
	server_host = new_text

func _on_NameField_text_changed(new_text):
	player_name = new_text
