extends Node

class_name SyncRoot

var SyncNode = load("res://sync_node.gd")


func sync_spawn(node):
	if node.filename == '': #assume not a scene, currently only scenes supported
		return
	if is_network_master():
		rpc("rpc_sync_spawn", node.filename, node.get_path(), node.get_network_master())


func sync_despawn(node):
	if is_network_master():
		rpc("rpc_sync_despawn", node.get_path())


func sync_client(id):
	if is_network_master():
		for child in get_children():
			_find_and_sync_to_client(child, id)


remote func rpc_sync_spawn(filename, node_path, master_id):
	var sender = multiplayer.get_rpc_sender_id()
	if sender == 1 || sender == get_network_master():
		print("rpc sync spawn ", filename, ' ', node_path, ' ', master_id)
		var node_name = node_path.get_name(node_path.get_name_count()-1)
		var parent_path = str(node_path).rstrip(node_name)
		var scene = load(filename)
		var instance = scene.instance()
		_disable_sync(instance)
		instance.name = node_name
		instance.set_network_master(master_id)
		get_node(parent_path).add_child(instance)


remote func rpc_sync_despawn(node_path) -> void:
	var sender = multiplayer.get_rpc_sender_id()
	if sender == 1 || sender == get_network_master():
		print("rpc sync despawn ", node_path)
		var node = get_node(node_path)
		node.get_parent().remove_child(node)


func _find_and_sync_to_client(node, id) -> void:
	for child in node.get_children():
		if child is SyncNode:
			rpc_id(id, "rpc_sync_spawn", child.node.filename, child.node.get_path(), child.node.get_network_master())
			child.rpc_id(id, "rpc_replicate", child.data)
	for child in node.get_children():
		_find_and_sync_to_client(child, id)


func _disable_sync(instance) -> void:
	if instance is SyncNode:
		print("disabling sync node", instance.name)
		instance.enabled = false
	for child in instance.get_children():
		_disable_sync(child)
