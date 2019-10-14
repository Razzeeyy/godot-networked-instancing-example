extends "sync_node.gd"

export(bool) var interpolate = false
export(float) var lerp_speed = 10


func _enter_tree():
	if !node is RigidBody2D:
		enabled = false
		return
	connect("spawned", self, "_spawned")


func _before_spawn():
	._before_spawn()
	data.transform = node.transform


func _spawned(data):
	node.transform = data.transform


func _physics_process(delta):
	if is_network_master():
		data.transform = node.transform
		data.linear_velocity = node.linear_velocity
		data.angular_velocity = node.angular_velocity


func integrate_forces(state):
	if is_network_master():
		return
	
	if data.has("linear_velocity"):
		state.linear_velocity = data.linear_velocity
	if data.has("angular_velocity"):
		state.angular_velocity = data.angular_velocity
	
	if !data.has("transform"):
		return
	if interpolate:
		state.transform = state.transform.interpolate_with(data.transform, lerp_speed * state.step)
	else:
		state.transform = data.transform