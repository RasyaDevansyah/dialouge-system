extends Node
class_name InteractSystem

@export var raycast_3D : RayCast3D
@export var interact_label : Label

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if raycast_3D.is_colliding() and raycast_3D.get_collider() is Interact:
			var col : Interact = raycast_3D.get_collider()
			col.triggerInteract()
		
	
	

func _process(_delta: float) -> void:
	if raycast_3D.is_colliding() and raycast_3D.get_collider() is Interact:
		var col : Interact = raycast_3D.get_collider()
		interact_label.visible = true
		interact_label.text = col.text + " [E]"
		pass
	else:
		interact_label.visible = false
	pass
