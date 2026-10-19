# in lobby.gd
extends Control

signal started_game
signal quit_game

@export var host_controls: Array[Control] = []
@export var player_card: PackedScene
@export var player_cards: HBoxContainer

# Flag to track if we're in the process of quitting
var is_quitting := false

# --- STEP 1: CONNECT THE SIGNAL ---
# This function runs when the lobby screen becomes visible.
func _on_visibility_changed() -> void:
	if visible:
		setup_screen()
		# CORRECT WAY TO CONNECT: Use the object and the signal name as a string.
		# This connects our local '_on_session_left' function to the global signal.
		
		if not NetworkHandler.is_connected("session_left", _on_session_left):
			NetworkHandler.connect("session_left", _on_session_left)


# --- (Optional but good practice) Disconnect when the scene closes ---
func _on_tree_exiting():
	NetworkHandler.disconnect("session_left", _on_session_left)

# --- STEP 2: UPDATE THE QUIT BUTTON ---
# This function starts the quitting process. It no longer waits.
func _on_quit_pressed() -> void:
	if multiplayer.is_server():
		# Host logic remains the same
		multiplayer.multiplayer_peer.close()
		quit_game.emit()
	else:
		# Client Logic:
		# 1. Tell the server we are leaving (this part works).
		notify_server_of_quit.rpc_id(1)
		
		# 2. Immediately reset our own network connection to the relay.
		NetworkHandler.reset_connection()
		
		# 3. Immediately go back to the main menu.
		quit_game.emit()

# --- STEP 3: CREATE THE CALLBACK FUNCTION ---
# This new function runs ONLY when the 'session_left' signal is received.
func _on_session_left():
	# Check the flag to make sure we initiated the quit.
	if is_quitting:
		is_quitting = false # Reset the flag.
		# Now that we're confirmed disconnected, it's safe to change scenes.
		quit_game.emit()

# --- NO CHANGES NEEDED BELOW THIS LINE ---
func setup_screen() -> void:
	if !multiplayer.is_server():
		print("Lobby Player")
		for c in host_controls:
			c.hide()
	else:
		var pc = player_card.instantiate()
		pc.name = "1"
		player_cards.add_child(pc)
		
		multiplayer.peer_connected.connect(
			func(id: int) -> void:
				var client_pc = player_card.instantiate()
				client_pc.name = str(id)
				player_cards.add_child(client_pc)
		)

@rpc("any_peer", "call_remote")
func notify_server_of_quit():
	if !multiplayer.is_server():
		return

	var client_id = multiplayer.get_remote_sender_id()
	print("Player %d is quitting." % client_id)

	var client_pc = player_cards.get_node_or_null(str(client_id))
	if client_pc:
		client_pc.queue_free()
	
	multiplayer.disconnect_peer(client_id)
