extends Node

@onready var intro_player: AudioStreamPlayer = $"ASP Snare Intro"
@onready var loop_player: AudioStreamPlayer = $"ASP Main Funk Loop"

func _ready():
	# Connect intro finished signal to start loop
	intro_player.finished.connect(_on_intro_finished)
	
	# Set loop to repeat indefinitely on the stream, not the player
	if loop_player.stream is AudioStreamWAV:
		loop_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif loop_player.stream is AudioStreamMP3:
		loop_player.stream.loop = true
	elif loop_player.stream.has_method("set_loop"):
		loop_player.stream.loop = true
	
	# Start playing music immediately
	play_music()

func _on_intro_finished():
	"""Called when snare intro finishes"""
	loop_player.play()

func play_music():
	"""Start the music with intro followed by loop"""
	intro_player.play()

func stop_music():
	"""Stop both audio players"""
	intro_player.stop()
	loop_player.stop()
