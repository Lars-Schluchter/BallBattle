extends CanvasLayer

func _on_main_menu_hosting() -> void:
	_switch_to_lobby()

func _on_main_menu_joining() -> void:
	_switch_to_lobby()
	
func _switch_to_lobby() -> void:
	$MainMenu.hide()
	$Lobby.show()

func _on_lobby_started_game() -> void:
	hide_child.rpc("Lobby")

func _on_lobby_quit_game() -> void:
	$Lobby.hide()
	$MainMenu.show()

@rpc("call_local")
func hide_child(path: NodePath) -> void:
	get_node(path).hide()
