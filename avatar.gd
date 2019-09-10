extends Node2D

onready var _nickname = $Nickname
onready var _sync = $SyncNode


func _ready():
	_sync.connect("replicated", self, "_apply_replication")


func set_nickname(nick):
	_nickname.text = nick
	_sync.data.nickname = nick


func spawn_at(pos):
	position = pos
	_sync.data.position = pos


func _apply_replication(data):
	print("apply repl ", data)
	_nickname.text = _sync.data.nickname
	position = _sync.data.position
