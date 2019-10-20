extends Node

const SyncRoot = preload("sync_root.gd")

signal spawned(data)
signal replicated(data)

export(bool) var enabled = true
export(bool) var replicated = false
export(bool) var force_reliable = false
export(float) var interval = 1

var validate = null # expects funcref validate(old_data, new_data)

var data = {}
var node

var _elapsed
var _sync_root
var _first_run


func _before_spawn(): #subclasses could override this to gather proper spawn data
	pass


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
		_sync_root.sync_despawn(node)


func _process(delta):
	if !enabled:
		return
	if _first_run:
		if _sync_root && node:
			_before_spawn()
			_sync_root.sync_spawn(node)
		_first_run = false
	if (multiplayer.is_network_server() || is_network_master()) && replicated:
		_elapsed += delta
		if _elapsed > interval:
			replicate(false)
			_elapsed = 0


func replicate(reliable=true):
	var server = multiplayer.is_network_server()
	if (!server && !is_network_master()) || data.empty():
		return
	if reliable || force_reliable:
		rpc("rpc_replicate", data) if server else rpc_id(1, "rpc_replicate", data)
	else:
		rpc_unreliable("rpc_replicate", data) if server else rpc_unreliable_id(1, "rpc_replicate", data)


remotesync func rpc_replicate(_data):
	var sender = multiplayer.get_rpc_sender_id()
	var host_call = multiplayer.is_network_server() && sender == 0
	if sender == 1 || sender == get_network_master() || host_call:
		if !host_call:
			if validate is FuncRef:
				validate.call_func(data, _data)
			data = _data
		emit_signal("replicated", data)


remotesync func rpc_spawned(_data):
	var sender = multiplayer.get_rpc_sender_id()
	var host_call = multiplayer.is_network_server() && sender == 0
	if sender == 1 || host_call:
		if !host_call:
			data = _data
		emit_signal("spawned", data)
		emit_signal("replicated", data)