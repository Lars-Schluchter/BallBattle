extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 8910

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % PORT)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	print("Client connecting to %s:%d" % [IP_ADDRESS, PORT])

# This function ONLY runs on the server.
func _on_peer_connected(player_id: int):
	print("Player %d connected, telling them to load the game scene." % player_id)
	# Send a remote procedure call to the newly connected player.
	# This tells them to run the "_load_scene" function on their end.
	_load_scene.rpc_id(player_id, "res://Scenes/game.tscn")

# This function is designed to be called remotely. It will run on the client.
@rpc("any_peer", "call_remote", "reliable")
func _load_scene(scene_path: String):
	# The client receives the command from the server and loads the correct scene.
	print("Received command from server to load scene: %s" % scene_path)
	get_tree().change_scene_to_file(scene_path)
