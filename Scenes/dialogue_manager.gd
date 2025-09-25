extends Node3D
@export var jsonDialogue : String

var data : Dictionary
var access : FileAccess

func _ready() -> void:
	access = FileAccess.open(jsonDialogue, FileAccess.READ)
	data = JSON.parse_string(access.get_as_text())
	access.close()
	
	# Testing if Json can be read 
	
	print(data["SD1_1"])
	print(data["SD1_1"]["character"])
	print(data["SD1_1"]["expression"])
	
	if data["SD1_1"]["text"] is Array:
		for text in data["SD1_1"]["text"]:
			print(text)
	elif data["SD1_1"]["text"] is String:
		print(data["SD1_1"]["text"])
	
	pass
	#
#func _physics_process(_delta: float) -> void:
	#
	#pass
