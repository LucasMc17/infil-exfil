class_name StaticAudioMachine
extends AudioStreamPlayer

@export var audio_list : Dictionary[String, AudioStream]

func play_audio(audio_name : String) -> void:
	var audio : AudioStream = audio_list.get(audio_name)
	if audio:
		stop()
		stream = audio
		play()