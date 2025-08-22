# GameManager.gd (MODIFIED WITH DEBUG PRINTS)
# THIS SCRIPT SHOULD BE AN AUTOLOAD/SINGLETON.

extends Node

const BALL_SCENE = preload("res://Scenes/Assets/ball.tscn")
const SHOOT_DISTANCE = 50

var spawner: MultiplayerSpawner
var host_spawned = false
var players = {}

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _process(delta):
	if multiplayer.is_server() and not host_spawned:
		var current_scene = get_tree().current_scene
		if current_scene and not current_scene.scene_file_path.ends_with("lobby.tscn"):
			var found_spawner = current_scene.find_child("MultiplayerSpawner", true, false)
			if found_spawner:
				spawner = found_spawner
				print("DEBUG: Spawner found by host. Requesting host player spawn.")
				request_player_spawn(multiplayer.get_unique_id())
				host_spawned = true
			else:
				print("DEBUG: In main scene, but MultiplayerSpawner node not found yet...")


func _on_peer_connected(id):
	if multiplayer.is_server():
		print("DEBUG: Peer %s connected." % id)
		var current_scene_path = get_tree().current_scene.scene_file_path
		rpc_id(id, "client_load_scene", current_scene_path)

func _on_peer_disconnected(id):
	if multiplayer.is_server():
		print("DEBUG: Peer %s disconnected." % id)
		if players.has(id):
			players.erase(id)

@rpc("any_peer", "call_local")
func client_load_scene(scene_path):
	print("DEBUG: Client received request to load scene: %s" % scene_path)
	get_tree().change_scene_to_file(scene_path)

@rpc("call_local")
func _on_client_ready():
	var client_id = multiplayer.get_remote_sender_id()
	print("DEBUG: Server received _on_client_ready from %s." % client_id)
	request_player_spawn(client_id)


func request_player_spawn(id):
	if not multiplayer.is_server(): return
	
	print("DEBUG: request_player_spawn called for ID: %s" % id)
	if not spawner:
		print("ERROR: Attempted to spawn, but spawner is null!")
		return

	var spawn_point = get_best_spawn_point()
	var pos = Vector2.ZERO
	if spawn_point:
		pos = spawn_point.global_position

	var player_data = {"id": id, "position": pos}
	
	if not players.has(id):
		players[id] = player_data
		
	print("DEBUG: Spawning player for ID %s at position %s" % [id, pos])
	spawner.spawn(player_data)

func get_best_spawn_point() -> Node2D:
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if not spawn_points: return null
	return spawn_points.pick_random()

@rpc("call_local")
func _on_player_died(id):
	var player_node = get_tree().get_root().find_child(str(id), true, false)
	if player_node:
		player_node.queue_free()
		if players.has(id):
			players.erase(id)
	
	await get_tree().create_timer(2.0).timeout
	request_player_spawn(id)

@rpc("call_local", "any_peer")
func shoot_ball(shooter_pos, mouse_pos):
	var ball = BALL_SCENE.instantiate()
	var direction = (mouse_pos - shooter_pos).normalized()
	ball.rotation = direction.angle()
	
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(ball)
		ball.global_position = shooter_pos + direction * SHOOT_DISTANCE
