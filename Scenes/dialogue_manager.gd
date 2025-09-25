extends Node3D
class_name dialouge_manager

@export var jsonDialogue : String

var data : Dictionary
var access : FileAccess

@warning_ignore("unused_signal")
signal dialogue_started()
@warning_ignore("unused_signal")
signal dialouge_ended()


@export var player: Player
@export var label : Label
@export var dialogue_box: Control
@export var options : MarginContainer
@export var optionsContainer: HBoxContainer


#dialogue Properties
enum states {
	NOT_PLAYING,
	PLAYING,
	WAITING_NEXT_DIALOGUE,
	WAITING_NEXT_INPUT
	
}
var currentState : states = states.NOT_PLAYING
var currentDialogue : Dictionary
var nextDialogueID : String
var nextDialogueIndex : int

@export var speed : float = 5
@export var waitSeconds : float = 0.5

func _ready() -> void:
	dialogue_box.visible = false
	options.visible = false # Ensure options are hidden at start
	access = FileAccess.open(jsonDialogue, FileAccess.READ)
	data = JSON.parse_string(access.get_as_text())
	access.close()
	
	# Example of how to start the dialogue
	# start_dialogue("SD1", 0)


func _unhandled_input(event: InputEvent) -> void:
	# Only advance dialogue on input if we are in the PLAYING state
	# This prevents skipping dialogue while waiting for player to choose an option
	if event.is_action_pressed("dialogueInteract") and currentState == states.PLAYING:
		if nextDialogueID == "" or nextDialogueIndex == -1:
			end_dialogue()
		else:
			start_dialogue(nextDialogueID, nextDialogueIndex)


func start_dialogue(dialogueID : String, dialogueIndex : int):
	currentDialogue = data.get(dialogueID +"_"+ str(dialogueIndex), {})
	
	if currentDialogue:
		currentState = states.PLAYING
		label.text = ""
		dialogue_box.visible = true
		
		# Handle if text is a single line or an array of lines
		if currentDialogue["text"] is Array:
			for text in currentDialogue["text"]:
				label.text += text
		elif currentDialogue["text"] is String:
			label.text = currentDialogue["text"]
	
		# Check for a function call, like ending the dialogue
		if currentDialogue.has("function"):
			match currentDialogue["function"]:
				"end_dialogue":
					nextDialogueID = ""
					nextDialogueIndex = -1
		else:
			# By default, prepare to go to the next dialogue entry in sequence
			nextDialogueID = dialogueID
			nextDialogueIndex = dialogueIndex + 1
			
		if currentDialogue.has("options"):
			_clear_options()
			player.set_player_control(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			currentState = states.WAITING_NEXT_INPUT
			display_options(currentDialogue.get("options"))


func display_options(optionTexts : Array):
	# Make the options container visible
	options.visible = true
	var go_to_indices = currentDialogue.get("go to", [])
	
	# Defensive check to ensure JSON is structured correctly
	if optionTexts.size() != go_to_indices.size():
		printerr("Dialogue options and 'go to' indices do not match!")
		return
	for i in range(optionTexts.size()):
		var button = Button.new()
		button.text = optionTexts[i]
		var target_index = go_to_indices[i].to_int()
		button.pressed.connect(_on_option_selected.bind(target_index))
		optionsContainer.add_child(button)


func _on_option_selected(index : int):
	player.set_player_control(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_clear_options()
	currentState = states.PLAYING
	start_dialogue(nextDialogueID, index)


func _clear_options():
	options.visible = false
	for button in optionsContainer.get_children():
		button.queue_free()


func end_dialogue():
	dialogue_box.visible = false
	label.text = ""
	currentState = states.NOT_PLAYING
	_clear_options()
