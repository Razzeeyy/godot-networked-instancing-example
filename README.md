# Godot Networked Instancing Example


## About example

This example showcases the usage of SyncSys add-on to simplify networking of scene spawns/despawns over network.  
Even though the example showcases it in 2D this system is general enough and can be used for 3D or even UI too.


## About SyncSys add-on

### The Why

Godot's main unit of abstraction is node/scene and high level networking provides great tools for networking some aspects of that abstraction. However in my opinion that's not enough. What's the main pain-point and missing feature I have in high level networking is inability to easily network node spawns/despawns. That's why I created the SyncSys addon as a workaround. Also later an optional replication feature was added.

### How To Use

1. Copy the `addons/sync_sys` folder into the `addons` folder of your project.
2. Activate `SyncSys` plugin under `Project -> Project Settings -> Plugins`.
3. Add `SyncRoot` node, somewhere appropriate in your SceneTree. Usually an AutoLoad works great. Make sure to call `sync_client(id)` when new client connects to the server, to update that client with the current state of the world.
4. Navigate to a scene whose instantiation you would want to be networked.
5. Add `SyncNode` node as the direct child of the given scene's root. Tweak the settings to your liking, see [API reference](#SyncNode) for more info.
6. Instantiate the given scene and add that instance as a child anywhere under the `SyncRoot`'s node in hierarchy.
7. It should work automagically.


### API Overview

#### SyncRoot

* `sync_client(id)` -- used to sync whole sync root tree state to the client
* `sync_spawn(node)` -- synchronizes spawn of the given node over network, usually doesn't need to be called directly because SyncNode will do it for us automatically
* `sync_spawn(node)` -- synchronizes despawn of the given node over network, usually doesn't need to be called directly because SyncNode will do it for us automatically

#### SyncNode
* `signal spawned(data)` -- this signal is called when the initial spawn data is sent, it will awlays get called once on node spawn if node enabled even if replication itself is disabled
* `signal replicated(data)` -- this signal is called when the new replication data arrives, it's not getting called if the replication for this node is disabled
* `var enabled : bool` -- if this node is enabled it's spawning and despawning will be synchronized over network
* `var replicated : bool` -- whether or not automatic replication is enabled
* `var force_reliable : bool` -- by default replication (except for spawn/despawn messages) is sent as unreliable, turn this on if you wish for it to be always sent as reliable
* `var interval : float` -- interval at which replication happens if enabled
* `var data : Dictionary` -- this dictionary gets sent from master to puppets if replicated is set to true
* `replicate(reliable=true)` -- this function can be called to replicate the data dictionary over to puppets, will only work on masters. Doesn't usually need to be called directly, it's called automatically under the hood. Although you can call it directly if you've disabled automatic replication and want to control exactly when the replication data is sent out.