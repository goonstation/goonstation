/datum/listen_module/effect/sims
	id = LISTEN_EFFECT_SIMS_SOCIAL_MOTIVE

/datum/listen_module/effect/sims/process(datum/say_message/message)
	var/mob/living/carbon/human/H = src.parent_tree.listener_parent
	if (!istype(H) || !H.sims || !ismob(message.original_speaker) || (message.original_speaker == H))
		return

	H.sims.affectMotive("social", 5)
