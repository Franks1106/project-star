@abstract
@icon("uid://cwpe5paiqd48f")
class_name State extends Node

signal entered
signal trigger_finished(state: String, next_state: String, data: Dictionary)
signal finished # Emitted by state manager after trigger_finished but before exit()

## Called on state machine process
@abstract
func update(_delta: float) -> void

## Called on state machine physics process
@abstract
func physics_update(_delta: float) -> void

## Called on state enter. Make sure to emit entered.
@abstract
func enter(_prev_state: String, _data := {}) -> void

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
@abstract
func end() -> void
	
## Called on state exit
@abstract
func exit() -> void
