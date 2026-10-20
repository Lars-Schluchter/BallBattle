extends Control

const SERVER_IP := "127.0.0.1"
const SERVER_PORT := 9753

const PLAYER_SCENE = preload("res://Scenes/Prefab/player.tscn")

@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var host_button: Button = $VBoxContainer/HostButton
@onready var players_folder: Node2D = $"../Players"

func _ready() -> void:
	join_button.pressed.connect(_on_join_pressed)
	host_button.pressed.connect(_on_host_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func _on_join_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(SERVER_IP, SERVER_PORT)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Connecting to host...")
		_hide_ui()
	else:
		print("Failed to initiate connection: ", error)
func _on_host_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, 8)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Hosting started on port ", SERVER_PORT)
		_hide_ui()
		_spawn_player(1)
	else:
		print("Failed to host: ", error)
		
func _hide_ui() -> void:
	host_button.visible = false
	join_button.visible = false

func _on_peer_connected(id: int) -> void:
	print("Player connected with network ID: ", id)
	_spawn_player(id)

func _spawn_player(id: int) -> void:
	if not multiplayer.is_server():
		return
	if players_folder.has_node(str(id)):
		print("Player node ", id, " already exists. Skipping spawn.")
		return

	var new_player = PLAYER_SCENE.instantiate()
	new_player.name = str(id)
	
	players_folder.add_child(new_player)
