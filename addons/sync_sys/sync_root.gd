extends Node

var SyncNode = load("res://addons/sync_sys/sync_node.gd")

func clear(free=true):
	for child in get_children():
		remove_child(child)
		if free:
			child.queue_free()


func sync_spawn(node):
	if node.filename == '': #assume not a scene, currently only scenes supported
		return
	if multiplayer.is_network_server():
		rpc("rpc_sync_spawn", node.filename, node.get_path(), node.get_network_master())
		for child in node.get_children():
			if child is SyncNode:
				child.rpc("rpc_spawned", child.data)
				break


func sync_despawn(node):
	if multiplayer.is_network_server():
		rpc("rpc_sync_despawn", node.get_path())


func sync_client(id):
	if multiplayer.is_network_server():
		for child in get_children():
			_find_and_sync_to_client(child, id)


remote func rpc_sync_spawn(filename, node_path, master_id):
	if multiplayer.is_network_server():
		return
	var sender = multiplayer.get_rpc_sender_id()
	if sender == 1:
		var node_name = node_path.get_name(node_path.get_name_count()-1)
		var parent_path = str(node_path).rstrip(node_name)
		var scene = load(filename)
		var instance = scene.instance()
		instance.name = node_name
		instance.set_network_master(master_id)
		get_node(parent_path).add_child(instance)


remote func rpc_sync_despawn(node_path) -> void:
	if multiplayer.is_network_server():
		return
	var sender = multiplayer.get_rpc_sender_id()
	if sender == 1:
		var node = get_node(node_path)
		node.get_parent().remove_child(node)


func _find_and_sync_to_client(node, id) -> void:
	for child in node.get_children():
		if child is SyncNode:
			rpc_id(id, "rpc_sync_spawn", child.node.filename, child.node.get_path(), child.node.get_network_master())
			child.rpc_id(id, "rpc_spawned", child.data)
			break
	for child in node.get_children():
		_find_and_sync_to_client(child, id)
