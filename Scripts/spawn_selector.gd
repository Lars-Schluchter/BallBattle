class_name SpawnSelector

static func pick(tree: SceneTree, spawning_player: Node2D) -> Vector2:
	var container := tree.current_scene.find_child("Spawnpoints", true, false)
	if container == null or container.get_child_count() == 0:
		push_warning("No Spawnpoints node (or it is empty) in the current map.")
		return Vector2.ZERO

	var others: Array[Node2D] = []
	for p in tree.get_nodes_in_group("players"):
		if p != spawning_player:
			others.append(p)

	var best_score := -1.0
	var candidates: Array[Vector2] = []

	for point in container.get_children():
		if not point is Node2D:
			continue
		var pos: Vector2 = point.global_position

		var nearest := INF
		for p in others:
			nearest = minf(nearest, pos.distance_squared_to(p.global_position))

		if nearest > best_score + 0.001:
			best_score = nearest
			candidates = [pos]
		elif absf(nearest - best_score) <= 0.001 or (is_inf(nearest) and is_inf(best_score)):
			candidates.append(pos)

	return candidates.pick_random()
