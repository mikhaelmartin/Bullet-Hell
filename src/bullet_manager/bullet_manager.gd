extends Node2D

@export var use_interpolation:bool = true
var multi_bullet_dict:Dictionary = {}
var bullet_instance_dict:Dictionary = {}


func spawn(
	p_position:Vector2,
	p_rotation:float,
	bullet_scene:PackedScene,
	bullet_data:BulletData,
	target:Node2D = null,
) -> Node2D:
	var state = bullet_scene.get_state()
	var bullet
	
	if state.get_node_groups(0).has("bullet"):
		bullet = bullet_scene.instantiate()
		self.add_child(bullet)
		bullet.set_up(p_position, p_rotation, bullet_data,target)
		
	elif state.get_node_groups(0).has("multi_bullet"):
		if not multi_bullet_dict.has(bullet_scene):
			multi_bullet_dict[bullet_scene] = []
			
			var num_threads := 0
			for i in state.get_node_property_count(0):
				if state.get_node_property_name(0,i) == "num_threads":
					num_threads = state.get_node_property_value(0,i)
			
			if num_threads:
				for _i in num_threads:
					var multi_bullet = bullet_scene.instantiate()
					multi_bullet.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
					self.add_child(multi_bullet)
					multi_bullet_dict[bullet_scene].append(multi_bullet)
			else:
				var multi_bullet = bullet_scene.instantiate()
				self.add_child(multi_bullet)
				multi_bullet_dict[bullet_scene].append(multi_bullet)
		
		
		multi_bullet_dict[bullet_scene].sort_custom(
			func(a:MultiBullet,b:MultiBullet):
				return a.multimesh.visible_instance_count < b.multimesh.visible_instance_count
		)
	
		multi_bullet_dict[bullet_scene][0].add_bullet(p_position, p_rotation, bullet_data, target)
		bullet = multi_bullet_dict[bullet_scene][0]
	
	return bullet

