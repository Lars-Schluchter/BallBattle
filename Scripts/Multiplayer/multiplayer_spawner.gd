# PlayerSpawnManager.gd
extends Node

@export var network_player: PackedScene

# This spawns the character for EVERYONE.
func spawn_for_everyone(player_id: int, spawn_transform: Transform2D):
	# Call the RPC on all clients and on the server itself.
	_spawn_character.rpc(player_id, spawn_transform)

# This spawns the character for ONLY ONE specific client (for state syncing).
func spawn_for_single_client(target_client_id: int, player_id: int, spawn_transform: Transform2D):
	_spawn_character.rpc_id(target_client_id, player_id, spawn_transform)

# This is the core function that does the work on each machine.
@rpc("any_peer", "call_local", "reliable")
func _spawn_character(player_id: int, spawn_transform: Transform2D):
	# Prevent creating duplicates if a network message arrives out of order.
	if get_parent().has_node(str(player_id)):
		return

	var player = network_player.instantiate()
	player.name = str(player_id)
	
	# Add the player as a child of the map root.
	get_parent().add_child(player)
	player.global_transform = spawn_transform
