tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SyncRoot", "Node", preload("sync_root.gd"), null)
	add_custom_type("SyncNode", "Node", preload("sync_node.gd"), null)
	add_custom_type("SyncTransform2D", "Node", preload("sync_transform_2d.gd"), null)
	add_custom_type("SyncTransform3D", "Node", preload("sync_transform_3d.gd"), null)
	add_custom_type("SyncRigidBody2D", "Node", preload("sync_rigid_body_2d.gd"), null)
	add_custom_type("SyncRigidBody3D", "Node", preload("sync_rigid_body_3d.gd"), null)


func _exit_tree():
	remove_custom_type("SyncRigidBody3D")
	remove_custom_type("SyncRigidBody2D")
	remove_custom_type("SyncTransform3D")
	remove_custom_type("SyncTransform2D")
	remove_custom_type("SyncNode")
	remove_custom_type("SyncRoot")
