extends Node

class_name SyncNode

signal replicated(data)

export(bool) var enabled = true
export(bool) var replicated = false
export(bool) var force_reliable = false
export(float) var interval = 1

var data = {}
var node

var _elapsed
var _sync_root
var _first_run


func _find_sync_root_in_parents():
	var parent : Node = get_parent()
	while parent != null:
		if parent is SyncRoot:
			return parent
		parent = parent.get_parent()
	return null


func _enter_tree():
	_first_run = true
	_elapsed = 0
	node = get_parent()
	_sync_root = _find_sync_root_in_parents()


func _exit_tree():
	if !enabled:
		return
	if _sync_root:
		print("sync node despawning ", node.name)
		_sync_root.sync_despawn(node)


func _process(delta):
	if !enabled:
		return
	if _first_run:
		if _sync_root && node:
			print("sync node spawning ", node.name)
			_sync_root.sync_spawn(node)
			replicate()
		_first_run = false
	if replicated:
		_elapsed += delta
		if _elapsed > interval:
			replicate(false)
			_elapsed = 0


func replicate(reliable=true):
	if data.empty():
		return
	var id = multiplayer.get_network_unique_id()
	if id == 1 || id == get_network_master():
		print("replicating ", reliable, ' ', data)
		if reliable || force_reliable:
			rpc("rpc_replicate", data)
		else:
			rpc_unreliable("rpc_replicate", data)


remote func rpc_replicate(_data):
	var sender = multiplayer.get_rpc_sender_id()
	if sender == 1 || sender == get_network_master():
		data = _data
		emit_signal("replicated", data)
