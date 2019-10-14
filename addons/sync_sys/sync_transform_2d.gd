extends "sync_node.gd"

export(bool) var interpolate = false
export(float) var lerp_speed = 10


func _enter_tree():
	if !node is Node2D:
		enabled = false
		return
	if !is_connected("spawned", self, "_spawned"):
		connect("spawned", self, "_spawned")


func _before_spawn():
	._before_spawn()
	data.transform = node.transform


func _spawned(data):
	node.transform = data.transform


func _process(delta):
	if is_network_master():
		data.transform = node.transform
	else:
		if !data.has("transform"):
			return
		if interpolate:
			node.transform = node.transform.interpolate_with(data.transform, lerp_speed * delta)
		else:
			node.transform = data.transform
