# NetworkManager.gd
# This script is attached to your "Lobby" scene.

extends Control

@onready var address_entry = $VBoxContainer/AddressEntry
const DEFAULT_PORT = 8910

func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % DEFAULT_PORT)
	get_tree().change_scene_to_file("res://Scenes/Maps/map_1.tscn")

func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var address = address_entry.text
	if address == "":
		address = "127.0.0.1"
	peer.create_client(address, DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	print("Attempting to join server at %s:%d" % [address, DEFAULT_PORT])
