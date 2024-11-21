/datum/listen_module/effect/prototype_maptext
	id = LISTEN_EFFECT_PROTOTYPE_MAPTEXT

/datum/listen_module/effect/prototype_maptext/process(datum/say_message/message)
	new /obj/maptext_junk/speech(message.speaker, msg = message.content)
