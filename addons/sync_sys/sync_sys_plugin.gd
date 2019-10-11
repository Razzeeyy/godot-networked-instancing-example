tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SyncRoot", "Node", preload("sync_root.gd"), null)
	add_custom_type("SyncNode", "Node", preload("sync_node.gd"), null)
	add_custom_type("SyncTransform2D", "Node", preload("sync_transform_2d.gd"), null)

func _exit_tree():
	remove_custom_type("SyncTransform2D")
	remove_custom_type("SyncNode")
	remove_custom_type("SyncRoot")
