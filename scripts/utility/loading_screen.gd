extends Control

@export var ANIM_TIME: float = 0.7
@export var FINISH_LOAD_WAIT_TIME: float = 0.5
@export var BAR_ANIMATION_EASE_CURVE: Curve # Should be a 0 to 1 easing curve.

@onready var bar = $Center/VBox/Bar
@onready var text = $Center/VBox/Percent
@onready var tooltip = $MarginContainer/Tooltip

var next_scene: String
var progress_arr: Array[float]
var progress: float
var old_progress: float
var anim_step: float
var loading_status: int
var done_wait: float
var done: bool
	
func _process(delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(next_scene, progress_arr)
	if progress_arr[0] * 100 != progress: # On load status update, reset anim_step and update progress
		old_progress = bar.value
		progress = progress_arr[0] * 100
		anim_step = 0
	if anim_step < 1:
		anim_step += delta / ANIM_TIME
	bar.value = old_progress + \
			BAR_ANIMATION_EASE_CURVE.sample(clamp(anim_step, 0, 1)) * (progress-old_progress) # Curve to ease bar animation to current load progress
	text.text = str(roundf(bar.value*100)/100) + "%"
	
	## Checks if loading animation is done, then artificially waits.
	if done_wait > FINISH_LOAD_WAIT_TIME:
		# adds the new scene as a child of main_scene rather than changing the whole tree
		var loaded_scene = ResourceLoader.load_threaded_get(next_scene).instantiate()
		GameManager.main_scene.add_child(loaded_scene)
		GameManager.current_level = loaded_scene
		print_rich("[color=dark_gray]Loaded level: ", next_scene)
		
		#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
		self.free() # TODO Maybe just Hide?
		return
	if done:
		if bar.value >= 100:
			done_wait += delta
		return
		
	## Checks loading status from ResourceLoader
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			done = true
			done_wait = 0
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Error")
			# TODO Return to Menu?
	
## Called from some scene manager to trigger the loading screen functions
func change_scene(next: String) -> void:
	next_scene = next
	tooltip.text = tooltips[randi() % tooltips.size()]
	done = false
	bar.value = 0
	old_progress = 0
	anim_step = 0
	text.text = str(0) + "%"
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	set_process(true)
	if not ResourceLoader.has_cached(next_scene):
		ResourceLoader.load_threaded_request(next_scene)
	
## List of loading screen tips
const tooltips: Array[String] = [
	"To reach the arduous star",
	"In times both dark and bright",
	"Seek the shine of the distant tree",
	"For the one who bears the world"
	]
