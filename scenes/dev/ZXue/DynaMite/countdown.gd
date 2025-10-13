extends State

var dynamite : Dynamite

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	#most of this is taken over by the CountdownTimer's countdown. see the connection for more info.
	'''
	TODO:
		no BM yet, so remember to put this in:
			$"../..".breakMeter *= $"../../CountdownTimer".time_left / $"../..".COUNTDOWN
		to gradually reduce its BM during the countdown stage.
	'''
	
	
	if(dynamite._hp <= 0):
		finished.emit("dead")
	'''
	TODO:
		I cannot implement the breaking here as I can't seem to be able to find break meter in entity.gd.
		However, remember that when I eventually get to do it here,
		do NOT enter broken state.
		just stagger and recover.
	'''

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	dynamite = owner as Dynamite
	#basically, start countdown.
	dynamite.set_movement_target(dynamite.global_position)
	dynamite.get_node("CountdownTimer").start(dynamite.COUNTDOWN)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit finished.
func end() -> void:
	trigger_finished.emit("dead")
	
## Called on state exit
func exit() -> void:
	pass

#when countdown ends
func _on_countdown_timer_timeout() -> void:
	if (dynamite.global_position.distance_to(dynamite.playerRef.global_position) < dynamite.attack_radius):
		dynamite.playerRef.try_damage(dynamite.DAMAGE)
	trigger_finished.emit("dead")


func _on_dyna_mite_explode_start() -> void:
	pass # Replace with function body.
