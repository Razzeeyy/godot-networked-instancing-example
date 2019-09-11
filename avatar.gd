extends Node2D

export(float) var speed = 250

onready var _nickname = $Nickname
onready var _sync = $SyncNode


func _ready():
	_sync.connect("replicated", self, "_replicated")


func set_nickname(nick):
	_nickname.text = nick
	_sync.data.nickname = nick


func spawn_at(pos):
	position = pos
	_sync.data.position = pos


func _replicated(data):
	print("apply replicated ", multiplayer.get_rpc_sender_id(), ' ', data)
	_nickname.text = _sync.data.nickname
	position = _sync.data.position


func _physics_process(delta):
	if !is_network_master():
		return
	
	var move = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		move.y -= speed
	if Input.is_action_pressed("ui_down"):
		move.y += speed
	if Input.is_action_pressed("ui_left"):
		move.x -= speed
	if Input.is_action_pressed("ui_right"):
		move.x += speed
	
	position += move * delta
	
	_sync.data.position = position