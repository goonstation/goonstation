/mob/living/carbon/human/tdummy
	real_name = "Target Dummy"
	var/shutup = FALSE
	var/stam_monitor

	New()
		. = ..()
		src.stam_monitor = new /obj/machinery/maptext_monitor/stamina(src)
		src.AddComponent(/datum/component/health_maptext)
		src.ensure_speech_tree().AddSpeechModifier(SPEECH_MODIFIER_TEST_DUMMY)

	disposing()
		qdel(src.stam_monitor)
		src.stam_monitor = null
		. = ..()
