# Godot Networked Instancing Example

## About Example

This example showcases the usage of SyncSys add-on to simplify networking of scene spawns/despawns over network.  
Even though the example showcases it in 2D this system is general enough and can be used for 3D or even UI too.  
Verified to work with Godot 3.1.

### Video Overview

https://youtu.be/0kXzSleNixo


## About SyncSys Addon

### The Why

Godot's main unit of abstraction is node/scene and high level networking provides great tools for networking some aspects of that abstraction. However in my opinion that's not enough. What's the main pain-point and missing feature I have in high level networking is inability to easily network node spawns/despawns. That's why I created the SyncSys addon as a workaround. Also later an optional replication feature was added.

### Design Choices

System consists of the 2 new nodes: `SyncRoot` and `SyncNode`.
When a `SyncNode` is added under a `SyncRoot` in hierarchy then (if the `SyncRoot` node is a network master) the `SyncNode`'s direct parent addition/removal will be networked if `enabled` is set to true, and replicated if `replicated` is set to true.  
`SyncNode`'s parent `name` and `network master id` is carried over the network properly when spawned.  
Clients listen to server or masters. Server automatically relays events from masters to puppets.  
System was designed with dedicated servers in mind. Currently server-as-player may not work properly, to be improved in the future.  
There can be as many `SyncRoot` nodes in a hierarchy as one wishes. It's up to the server/master to manage them. They will co-exist simultaneously just fine. This could be used to achieve streaming different parts of open-world map to different clients without much effort.

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
* `clear(free=true)` -- removes and frees all children, if argument free is set the children will also be queued for free upon being removed

#### SyncNode

* `signal spawned(data)` -- this signal is called when the initial spawn data is sent, it will awlays get called once on node spawn if node enabled even if replication itself is disabled
* `signal replicated(data)` -- this signal is called when the new replication data arrives, it's not getting called if the replication for this node is disabled
* `var enabled : bool` -- if this node is enabled it's spawning and despawning will be synchronized over network
* `var replicated : bool` -- whether or not automatic replication is enabled
* `var force_reliable : bool` -- by default replication (except for spawn/despawn messages) is sent as unreliable, turn this on if you wish for it to be always sent as reliable
* `var interval : float` -- interval at which replication happens if enabled
* `var data : Dictionary` -- this dictionary gets sent from master to puppets if replicated is set to true
* `replicate(reliable=true)` -- this function can be called to replicate the data dictionary over to puppets, will only work on masters. Doesn't usually need to be called directly, it's called automatically under the hood. Although you can call it directly if you've disabled automatic replication and want to control exactly when the replication data is sent out.


### Changelog

#### 0.1

Initial release

#### 0.2

Ability for host play added. Server now can spawn objects for himself and sync node emulates replication to itself, so the code stays the same as for remote clients.

#### 0.3

Introduction of specific SyncNode subclasses to simplify common replication usecases:
* SyncTransform2D
* SyncTransform3D
