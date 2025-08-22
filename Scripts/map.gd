# Main.gd (MODIFIED WITH MORE ROBUST READY SIGNAL)
# This script is attached to the root node of your `main.tscn` scene.

extends Node2D

var client_ready_sent = false

func _process(delta):
	# This loop ensures the ready signal is sent as soon as the network is ready.
	if not multiplayer.is_server() and not client_ready_sent:
		# Check if we have a valid connection to the server (peer ID 1)
		if multiplayer.get_peers().has(1):
			print("DEBUG: Client is ready and connected. Sending ready signal to server.")
			GameManager.rpc_id(1, "_on_client_ready")
			client_ready_sent = true # Set the flag to only send this once
