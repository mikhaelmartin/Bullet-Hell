extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count = 0
	for key in BulletManager.multi_bullet_dict:
		for multi_bullet in BulletManager.multi_bullet_dict[key]:
			count += multi_bullet.multimesh.visible_instance_count
			
	count += BulletManager.get_child_count() - BulletManager.multi_bullet_dict.size() 
	text = "bullets " + str(count)
