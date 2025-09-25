extends Interact

@export var dialogue_manager: dialouge_manager
@export var dialogue_id : String
@export var dialogue_index : int


func triggerInteract() -> void:
	dialogue_manager.start_dialogue(dialogue_id, dialogue_index)
	active = false
	pass
