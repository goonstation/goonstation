
/// Record initial cyborg module selection
/datum/eventRecord/CyborgModuleSelection
	eventType = "cyborg_module_selection"
	body = /datum/eventRecordBody/TracksPlayer/CyborgModuleSelection

	send(
		player_id,
		module,
		borg_type
	)
		. = ..(args)

	buildAndSend(mob/living/silicon/robot/R, mod)
		if (!istype(R))
			return


		var/type
		if(R.syndicate)
			type = "syndicate"
		else if(istype(R.part_head.brain, /obj/item/organ/brain/latejoin))
			type = "latejoin"
		else if(HAS_ATOM_PROPERTY(R, PROP_ATOM_ROUNDSTART_BORG))
			type = "roundstart"
		else
			type = "constructed/other"

		src.send(
			R.mind.get_player().id,
			mod,
			type
		)
