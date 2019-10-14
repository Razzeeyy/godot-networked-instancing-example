extends Spatial

export(float) var speed = 5

onready var _sync = $SyncTransform3D


func setup(spawn_position, nickname):
	transform.origin = spawn_position


func _on_SyncNode_spawned(data):
	pass


func _physics_process(delta):
	if !is_network_master():
		return
	
	var move = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		move.z -= speed
	if Input.is_action_pressed("ui_down"):
		move.z += speed
	if Input.is_action_pressed("ui_left"):
		move.x -= speed
		transform = transform.rotated(Vector3.UP, -1 * delta)
	if Input.is_action_pressed("ui_right"):
		move.x += speed
		transform = transform.rotated(Vector3.UP, 1 * delta)
	
	transform.origin += move * delta
