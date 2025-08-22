# GameManager.gd
extends Node

var spawn_manager: Node
var spawn_points: Array = []
var current_map_path: String = ""

func _ready():
	if multiplayer.is_server():
		change_map("res://Scenes/Maps/map_1.tscn")
	else:
		request_map_info.rpc_id(1)

@rpc("any_peer", "reliable")
func request_map_info():
	var player_id = multiplayer.get_remote_sender_id()
	if not current_map_path.is_empty():
		_load_new_map.rpc_id(player_id, current_map_path)

@rpc("any_peer", "reliable")
func notify_server_map_loaded():
	var new_player_id = multiplayer.get_remote_sender_id()
	print("Player %d is ready. Performing state sync." % new_player_id)

	var map_root = spawn_manager.get_parent()
	if not map_root: return

	# STEP 1: Tell the new client about all EXISTING players.
	var server_char = map_root.get_node_or_null("1")
	if server_char:
		spawn_manager.spawn_for_single_client(new_player_id, 1, server_char.global_transform)
	
	for peer_id in multiplayer.get_peers():
		if peer_id != new_player_id:
			var player_char = map_root.get_node_or_null(str(peer_id))
			if player_char:
				spawn_manager.spawn_for_single_client(new_player_id, peer_id, player_char.global_transform)
	
	# STEP 2: Spawn the NEW player's character for EVERYONE.
	spawn_player(new_player_id)

func change_map(map_path: String):
	if not multiplayer.is_server():
		return
	current_map_path = map_path 
	_load_new_map.rpc(map_path)

@rpc("any_peer", "call_local")
func _load_new_map(map_path: String):
	var container = get_node("SceneContainer")
	if container.get_child_count() > 0:
		container.get_child(0).queue_free()

	var new_map_instance = load(map_path).instantiate()
	container.add_child(new_map_instance)

	spawn_manager = new_map_instance.find_child("PlayerSpawnManager", true, false)
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	if not spawn_manager:
		print("CRITICAL ERROR: Could not find 'PlayerSpawnManager' in new map!")
		return
		
	if multiplayer.is_server():
		initial_spawn()
	else:
		notify_server_map_loaded.rpc_id(1)

func initial_spawn():
	spawn_player(1) # For the server
	for player_id in multiplayer.get_peers():
		spawn_player(player_id)

func spawn_player(player_id: int):
	if not multiplayer.is_server() or not spawn_manager or spawn_points.is_empty():
		return

	var spawn_point = spawn_points.pick_random()
	spawn_manager.spawn_for_everyone(player_id, spawn_point.global_transform)
