extends Node

const TRACK_SIGNAL_TO_NOISE := "signal_to_noise"
const TRACK_DIGITAL_SUNSET := "digital_sunset"
const TRACK_VOLATILE_REACTION := "volatile_reaction"

const TRACK_PATHS := {
	TRACK_SIGNAL_TO_NOISE: "res://Assets/audio/sb_signaltonoise.mp3",
	TRACK_DIGITAL_SUNSET: "res://Assets/audio/White_Bat_Audio_by_Karl_Casey_-_Digital_Sunset_(mp3.pm).mp3",
	TRACK_VOLATILE_REACTION: "res://Assets/audio/Volatile%20Reaction.mp3"
}

var _player: AudioStreamPlayer
var _current_track_id := ""

func _ready():
	_player = AudioStreamPlayer.new()
	_player.name = "BackgroundMusicPlayer"
	_player.bus = "Master"
	_player.autoplay = false
	add_child(_player)

func play_track(track_id: String, force_restart: bool = false):
	if not TRACK_PATHS.has(track_id):
		push_warning("MusicManager: unknown track id '" + track_id + "'")
		return

	if not force_restart and _current_track_id == track_id and _player.playing:
		return

	var stream_path := String(TRACK_PATHS[track_id])
	var stream := load(stream_path)
	if stream == null:
		push_warning("MusicManager: failed to load " + stream_path)
		return

	_current_track_id = track_id
	_player.stream = stream
	_player.play()

func stop_music():
	_player.stop()
	_current_track_id = ""

func get_current_track_id() -> String:
	return _current_track_id

func get_music_credits_text() -> String:
	return "Signal to Noise - Scott Buckley (CC-BY 4.0)\nDigital Sunset - Music by Karl Casey @ White Bat Audio\nVolatile Reaction - Kevin MacLeod (CC-BY 4.0)"
