# Godot Networked Instancing Example

An example for a (semi-)automatic instantiation and replication of nodes over network for Godot.
Even though the example showcases it in 2D this system is general enough and can be used for 3D or even UI too.

## How To Use In Your Project

Just copy the files `sync_node.gd` and `sync_root.gd` over to the root of your project.  
If wish to copy into another directory that isn't the root then you need to change the line in `sync_root.gd`

```gdscript
var SyncNode = load("res://sync_node.gd")
```
to properly point to the directory where you've placed the `sync_node.gd` file.

## API Overview

* SyncRoot
    * `sync_client(id)` -- used to sync whole sync root tree state to the client
    * `sync_spawn(node)` -- synchronizes spawn of the given node over network, usually doesn't need to be called directly because SyncNode will do it for us automatically
    * `sync_spawn(node)` -- synchronizes despawn of the given node over network, usually doesn't need to be called directly because SyncNode will do it for us automatically
* SyncNode
    * `signal spawned(data)` -- this signal is called when the initial spawn data is sent, it will awlays get called once on node spawn if node enabled even if replication itself is disabled
    * `signal replicated(data)` -- this signal is called when the new replication data arrives, it's not getting called if the replication for this node is disabled
    * `var enabled : bool` -- if this node is enabled it's spawning and despawning will be synchronized over network
    * `var replicated : bool` -- whether or not automatic replication is enabled
    * `var force_reliable : bool` -- by default replication (except for spawn/despawn messages) is sent as unreliable, turn this on if you wish for it to be always sent as reliable
    * `var interval : float` -- interval at which replication happens if enabled
    * `var data : Dictionary` -- this dictionary gets sent from master to puppets if replicated is set to true
    * `replicate(reliable=true)` -- this function can be called to replicate the data dictionary over to puppets, will only work on masters. Doesn't usually need to be called directly, it's called automatically under the hood. Although you can call it directly if you've disabled automatic replication and want to control exactly when the replication data is sent out.