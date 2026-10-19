extends Node

@export var player_scene: PackedScene
@export var player_spawner: MultiplayerSpawner

func _ready() -> void:
	player_spawner.spawn_function = _multiplayer_spawner_player

func _spawn_player(authority_pid: int) -> void:
	player_spawner.spawn(authority_pid)

func _multiplayer_spawner_player(authority_pid: int) -> Player:
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	return player
	
	
func _on_lobby_quit_game() -> void:
	for child in $SceneContainer.get_children():
		child.queue_free()

func _wait_for_authority() -> void:
	while not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		await get_tree().process_frame

func _on_main_menu_joining() -> void:
	pass # Replace with function body.

func _on_lobby_started_game() -> void:
	_spawn_players()
	
func _spawn_players() -> void:
	_spawn_player(1) #Server Player
	for peer in multiplayer.get_peers():
		_spawn_player(peer)
