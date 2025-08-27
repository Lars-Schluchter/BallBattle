extends Control

signal hosting
signal joining

func _ready() -> void:
	
	if NetworkHandler.is_ready:
		_continue_init()
	else:
		NetworkHandler.relay_connected.connect(_continue_init, CONNECT_ONE_SHOT)

# NetworkHandlers ready func is finished here
func _continue_init() -> void:
		%OnlineID.text = NetworkHandler.peer.online_id
		

func _on_hostButton_pressed() -> void:
	await NetworkHandler.start_server()
	var map = preload("res://Scenes/Maps/map_1.tscn").instantiate()
	$"../../SceneContainer".add_child(map)
	hosting.emit()
	
func _on_joinButton_pressed() -> void:
	if %HostOnlineID.text == "":
		return
	await NetworkHandler.start_client(%HostOnlineID.text)
	var map = preload("res://Scenes/Maps/map_1.tscn").instantiate()
	$"../../SceneContainer".add_child(map)
	joining.emit()
