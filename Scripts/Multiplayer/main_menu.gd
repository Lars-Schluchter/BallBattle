# MainMenu.gd
extends Control

func _on_hostButton_pressed() -> void:
	NetworkHandler.start_server()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func _on_joinButton_pressed() -> void:
	NetworkHandler.start_client()
