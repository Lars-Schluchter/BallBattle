extends Control

signal hosting
signal joining

func _ready() -> void:
	return		

func _on_hostButton_pressed() -> void:
	await NetworkHandler.become_host()
	var map = preload("res://Scenes/Maps/map_1.tscn").instantiate()
	$"../../SceneContainer".add_child(map)
	hosting.emit()
	
func _on_joinButton_pressed() -> void:
	if %HostOnlineID.text == "":
		return
	await NetworkHandler.join_as_player(%HostOnlineID.text)
	var map = preload("res://Scenes/Maps/map_1.tscn").instantiate()
	$"../../SceneContainer".add_child(map)
	joining.emit()
