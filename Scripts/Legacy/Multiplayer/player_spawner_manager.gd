extends Node

@export var network_player: PackedScene

# This is the function the GameManager will call.
func spawn_player(player_id: int, spawn_transform: Transform3D):
	# This must only be called on the server.
	if not multiplayer.is_server():
		return
		
	# First, spawn the player on the server itself.
	_spawn_character(player_id, spawn_transform)
	
	# Now, send an RPC to all clients, telling them to spawn the same character.
	_spawn_character.rpc(player_id, spawn_transform)

# This function will be called remotely on all clients.
# It's also called directly by the server for itself.
@rpc("any_peer", "call_local", "reliable")
func _spawn_character(player_id: int, spawn_transform: Transform3D):
	var player: Node2D = network_player.instantiate()
	player.name = str(player_id)
	
	# Players are children of the map's root node. The spawner is also a child,
	# so get_parent() refers to the map's root.
	get_parent().add_child(player)
	
	# Set position AFTER adding to the scene tree.
	player.global_transform = spawn_transform
