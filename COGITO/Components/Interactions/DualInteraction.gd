class_name DualInteraction
extends InteractionComponent

signal is_being_held(time_left:float)

signal on_quick_press(player_interaction_component:PlayerInteractionComponent)
signal on_hold_complete(player_interaction_component:PlayerInteractionComponent)

@export var hold_time : float = 3.0

@onready var parent_node = get_parent() #Grabbing reference to door
@onready var hold_timer: Timer = $HoldTimer
@onready var hold_ui: Control = $HoldUi
@onready var progress_bar: ProgressBar = $HoldUi/ProgressBar

var is_holding : bool = false
var player_interaction_component


func _ready() -> void:
	hold_ui.hide()
	hold_timer.timeout.connect(_on_hold_complete)
	hold_timer.wait_time = hold_time
	progress_bar.value = hold_timer.time_left / hold_time * 100


func interact(_player_interaction_component):
	player_interaction_component = _player_interaction_component
	if !is_holding:
		is_holding = true
		hold_ui.show()
		hold_timer.start()


func _on_object_state_change(_interaction_text: String):
	interaction_text = _interaction_text


func _process(_delta: float) -> void:
	if is_holding:
		is_being_held.emit(hold_timer.time_left)
		progress_bar.value = hold_timer.time_left / hold_time * 100
		
		var interaction_distance = (parent_node.global_position - player_interaction_component.global_position).length()
		if interaction_distance >= player_interaction_component.interaction_raycast.target_position.length() :
			hold_timer.stop()
			hold_ui.hide()
			is_holding = false


func _input(event):
	if is_holding and event.is_action_released(input_map_action):
		hold_timer.stop()
		hold_ui.hide()
		is_holding = false
		on_quick_press.emit(player_interaction_component)
		


func _on_hold_complete():
	hold_timer.stop()
	hold_ui.hide()
	is_holding = false
	on_hold_complete.emit(player_interaction_component)
