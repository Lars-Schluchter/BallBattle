extends Node

const IP_ADDRESS: String = "relay.nodetunnel.io"
const PORT: int = 9998

var peer = NodeTunnelPeer.new()

signal relay_connected
signal session_left
var is_ready := false

func _ready():
	multiplayer.multiplayer_peer = peer
	peer.connect_to_relay(IP_ADDRESS, PORT)
	await peer.relay_connected
	multiplayer.server_disconnected.connect(_on_server_disconnected)	
	is_ready = true
	emit_signal("relay_connected")

func start_server() -> void:
	
	peer.host()
	await peer.host()
	
	DisplayServer.clipboard_set(peer.online_id)
	
	print("Server started with ID %d" % peer.unique_id)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func start_client(hostID: String) -> void:
	peer.join(hostID)
	await peer.joined
	print("Client connected with ID %d" % peer.unique_id)

# This function ONLY runs on the server.
func _on_peer_connected(player_id: int):
	print("Player %d connected, telling them to load the game scene." % player_id)
	# Send a remote procedure call to the newly connected player.
	# This tells them to run the "_load_scene" function on their end.
	#_load_scene.rpc_id(player_id, "res://Scenes/game.tscn")

func _on_server_disconnected():
	# This function is called automatically when the server disconnects us.
	# Our NodeTunnelPeer is now back in a clean state, ready to join again.
	emit_signal("session_left")

func reset_connection() -> void:
	# Mark as not ready while we reconnect
	is_ready = false

	# Close the existing connection completely
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()

	# Create a new, clean peer object
	peer = NodeTunnelPeer.new()
	multiplayer.multiplayer_peer = peer
	
	# Connect to the relay again
	peer.connect_to_relay(IP_ADDRESS, PORT)
	await peer.relay_connected
	
	# Mark as ready and notify the game
	is_ready = true
	session_left.emit()

## This function is designed to be called remotely. It will run on the client.
#@rpc("any_peer", "call_remote", "reliable")
#func _load_scene(scene_path: String):
	## The client receives the command from the server and loads the correct scene.
	#print("Received command from server to load scene: %s" % scene_path)
	#get_tree().change_scene_to_file(scene_path)
