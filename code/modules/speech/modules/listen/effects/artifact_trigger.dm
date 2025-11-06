/datum/listen_module/effect/artifact_trigger
	id = LISTEN_EFFECT_ARTIFACT_TRIGGER

/datum/listen_module/effect/artifact_trigger/process(datum/say_message/message)
	var/obj/O = src.parent_tree.listener_parent
	if (!istype(O) || O.artifact.activated)
		return

	if (isghostcritter(message.original_speaker))
		return

	var/datum/artifact_trigger/language/trigger = locate(/datum/artifact_trigger/language) in O.artifact.triggers
	if (!trigger || ON_COOLDOWN(O, "speech_act_cd", 2 SECONDS))
		return

	var/result = trigger.speech_act(message.original_content)
	switch (result)
		if (null)
			return
		if ("error")
			O.visible_message("[O] gives a <b>dull</b> chime.", "[O] gives a <b>dull</b> chime.")
		if ("hint")
			O.visible_message("<b>[O]</b> [O.artifact.hint_text]", "<b>[O]</b> [O.artifact.hint_text]")
		if ("correct")
			O.ArtifactStimulus("language", 1)
		else
			O.visible_message("[O] [result]", "[O] [result]")
