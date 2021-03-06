extends Spatial

export(float) var speed = 5

onready var _sync = $SyncTransform3D
onready var _box = $CSGBox

func setup(spawn_position, color):
	translation = spawn_position
	_sync.data.color = color
	_box.material = SpatialMaterial.new()
	_box.material.albedo_color = color


func _on_SyncNode_spawned(data):
	_box.material = SpatialMaterial.new()
	_box.material.albedo_color = _sync.data.color


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
		rotation.y -= 3 * delta
	if Input.is_action_pressed("ui_right"):
		move.x += speed
		rotation.y += 3 * delta
	
	translation += move * delta
