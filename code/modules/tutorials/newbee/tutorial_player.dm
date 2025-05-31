/mob/new_player/verb/play_tutorial()
	set name = "Play Tutorial"
	set desc = "Launch the in-game tutorial!"
	set category = "Commands"
	set hidden = TRUE

	if (global.current_state < GAME_STATE_SETTING_UP)
		boutput(usr, SPAN_ALERT("The tutorial will launch when the game starts."))
		src.ready_tutorial = TRUE
		src.update_joinmenu()
	else if (global.current_state <= GAME_STATE_PLAYING)
		if (src.tutorial_loading)
			boutput(usr, SPAN_ALERT("The tutorial is loading, please be patient!"))
			return
		src.tutorial_loading = TRUE
		boutput(usr, SPAN_ALERT("Launching the tutorial!"))
		src.client?.tutorial = new(src)
		src.client?.tutorial.Start()
	else
		boutput(usr, SPAN_ALERT("It's too late to start the tutorial! Please try next round."))

/// Newbee Tutorial mob; no headset or PDA, does not spawn via jobs
/mob/living/carbon/human/tutorial
/mob/living/carbon/human/tutorial/New(loc, datum/appearanceHolder/AH_passthru, datum/preferences/init_preferences, ignore_randomizer=FALSE, role_for_traits)
	. = ..(loc, AH_passthru, init_preferences, ignore_randomizer, "tutorial")

	// force the player to resist to put out flames
	src.traitHolder.addTrait("burning", force_trait=TRUE)

	src.equip_new_if_possible(/obj/item/clothing/under/rank/assistant, SLOT_W_UNIFORM)
	src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)

	SPAWN(0)
		if (src.sims)
			for (var/motive in src.sims.motives)
				src.sims.removeMotive(motive)

/mob/living/carbon/human/tutorial/set_pulling(atom/movable/A)
	. = ..()
	if (src.client?.tutorial)
		src.client.tutorial.PerformSilentAction("set_pulling", A)

/mob/living/carbon/human/tutorial/remove_pulling()
	if (src.client?.tutorial)
		src.client.tutorial.PerformSilentAction("remove_pulling", src.pulling)
	. = ..()

/mob/living/carbon/human/tutorial/set_m_intent(intent)
	. = ..()
	if (src.client?.tutorial)
		src.client.tutorial.PerformSilentAction("m_intent", intent)

/mob/living/carbon/human/tutorial/contract_disease()
	return // no

/mob/living/carbon/human/tutorial/gib(give_medal, include_ejectables)
	if (src.client?.tutorial)
		src.death(TRUE) // don't actually blow us up, thanks
	else
		. = ..(give_medal, include_ejectables)

/mob/living/carbon/human/tutorial/death(gibbed)
	if (src.client?.tutorial)
		var/datum/tutorial_base/regional/newbee/current_tutorial = src.client.tutorial
		for(var/turf/T in landmarks[current_tutorial.checkpoint_landmark])
			if(current_tutorial.region.turf_in_region(T))
				src.set_loc(T)
				showswirl(T)
				break

		src.full_heal()
		boutput(src, SPAN_ALERT("Whoa, you almost died! Let's try that again..."))
	else
		. = ..(gibbed)

/mob/living/carbon/human/tutorial/verb/stop_newbee_tutorial()
	set name = "Stop Tutorial"
	if (!src.client.tutorial)
		boutput(src, SPAN_ALERT("You're not in a tutorial. It's real. IT'S ALL REAL."))
		return
	src.client.tutorial.Finish()
	src.client.tutorial = null
