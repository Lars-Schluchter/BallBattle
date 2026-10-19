extends Node

const SERVER_IP := "127.0.0.1"
const SERVER_PORT := 9998

var server_multiplayer: MultiplayerAPI
var client_multiplayer: MultiplayerAPI
var host_mode_enabled := false


func become_host():
	print("Starting host!")

	host_mode_enabled = true

	# --- Server setup ---
	var server_peer := ENetMultiplayerPeer.new()
	var err := server_peer.create_server(SERVER_PORT)
	if err != OK:
		push_error("Failed to create server peer: %s" % err)
		return

	server_multiplayer = MultiplayerAPI.create_default_interface()
	server_multiplayer.multiplayer_peer = server_peer

	server_multiplayer.peer_connected.connect(
		func(id): print("Server: peer connected %s" % id)
	)
	server_multiplayer.peer_disconnected.connect(
		func(id): print("Server: peer disconnected %s" % id)
	)

	# --- Client setup (host as a normal player) ---
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)

	client_multiplayer = MultiplayerAPI.create_default_interface()
	client_multiplayer.multiplayer_peer = client_peer

	# Apply client multiplayer to the current scene root using NodePath
	var root := get_tree().current_scene
	if root:
		get_tree().set_multiplayer(client_multiplayer, root.get_path())
		print("Applied client multiplayer to scene: %s" % root.name)


func join_as_player(server_ip: String):
	print("Joining as player")

	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip, SERVER_PORT)

	client_multiplayer = MultiplayerAPI.create_default_interface()
	client_multiplayer.multiplayer_peer = client_peer

	var root := get_tree().current_scene
	if root:
		get_tree().set_multiplayer(client_multiplayer, root.get_path())
		print("Applied client multiplayer to scene: %s" % root.name)
