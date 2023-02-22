/client/proc/gearspawn_traitor()
	set category = "Commands"
	set name = "Call Syndicate"
	set desc="Teleports useful items to your location."

	if (usr.stat || !isliving(usr) || isintangible(usr))
		usr.show_text("You can't use this command right now.", "red")
		return

	var/uplink_path = get_uplink_type(usr, /obj/item/uplink/syndicate)
	var/obj/item/uplink/syndicate/U = new uplink_path(usr.loc)
	if (!usr.put_in_hand(U))
		U.set_loc(get_turf(usr))
		usr.show_text("<h3>Uplink spawned. You can find it on the floor at your current location.</h3>", "blue")
	else
		usr.show_text("<h3>Uplink spawned. You can find it in your active hand.</h3>", "blue")

	if (usr.mind && istype(usr.mind))
		U.lock_code_autogenerate = 1
		U.setup(usr.mind)
		usr.show_text("<h3>The password to your uplink is '[U.lock_code]'.</h3>", "blue")
		usr.mind.store_memory("<B>Uplink password:</B> [U.lock_code].")

	usr.verbs -= /client/proc/gearspawn_traitor

	return

// Remove when omnitraitors are datumised.
/client/proc/gearspawn_wizard()
	set category = "Commands"
	set name = "Call Wizards"
	set desc="Teleports useful items to your location."

	if (usr.stat || !isliving(usr) || isintangible(usr))
		usr.show_text("You can't use this command right now.", "red")
		return

	if (!ishuman(usr))
		boutput(usr, "<span class='alert'>You must be a human to use this!</span>")
		return

	var/mob/living/carbon/human/H = usr

	equip_wizard(H, 1)

	usr.verbs -= /client/proc/gearspawn_wizard

	return

/proc/equip_traitor(mob/living/carbon/human/traitor_mob)
	if (!(traitor_mob && ishuman(traitor_mob)))
		return

	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/assday))
		boutput(traitor_mob, "The Syndicate have clearly forgotten to give you a Syndicate Uplink. Lazy idiots.")
		traitor_mob.show_antag_popup("traitorhard")
		return

	var/freq = null
	var/pda_pass = null

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda2))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.r_store, /obj/item/device/pda2))
		R = traitor_mob.r_store
		loc = "In your pocket"
	if (!R && istype(traitor_mob.l_store, /obj/item/device/pda2))
		R = traitor_mob.l_store
		loc = "In your pocket"
	if (!R && istype(traitor_mob.ears, /obj/item/device/radio))
		R = traitor_mob.ears
		loc = "on your head"
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.l_hand, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.l_hand
		var/list/L = S.get_contents()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.r_hand
		var/list/L = S.get_contents()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.back
		var/list/L = S.get_contents()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your backpack"
			break
		if(!R)
			R = new /obj/item/device/radio/headset(traitor_mob)
			loc = "in the [S.name] in your backpack"
			// Everything else failed and there's no room in the backpack either, oh no.
			// I mean, we can't just drop a super-obvious uplink onto the floor. Hands might be full, too (Convair880).
			if (traitor_mob.equip_if_possible(R, traitor_mob.slot_in_backpack) == 0)
				qdel(R)
				traitor_mob.verbs += /client/proc/gearspawn_traitor
				traitor_mob.show_antag_popup("traitorradio")
				return
	if (!R)
		traitor_mob.verbs += /client/proc/gearspawn_traitor
		traitor_mob.show_antag_popup("traitorradio")
	else
		if (!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)) && !(traitor_mob.mind && traitor_mob.mind.special_role == "spy"))
			traitor_mob.show_antag_popup("traitorpda")

		if (istype(R, /obj/item/device/radio))
			var/obj/item/device/radio/RR = R
			var/uplink_path = get_uplink_type(traitor_mob, /obj/item/uplink/integrated/radio)
			var/obj/item/uplink/integrated/radio/T = new uplink_path(RR)
			T.setup(traitor_mob.mind, RR)
			freq = RR.traitor_frequency

			boutput(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [RR.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([RR.name] [loc]).")

		else if (istype(R, /obj/item/device/pda2))
			var/obj/item/device/pda2/P = R
			var/uplink_path = get_uplink_type(traitor_mob, /obj/item/uplink/integrated/pda)
			var/obj/item/uplink/integrated/pda/T = new uplink_path(P)
			T.setup(traitor_mob.mind, P)
			pda_pass = T.lock_code

			boutput(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [P.name] [loc]. Simply enter the code \"[pda_pass]\" into the ring message select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Set your ring message to:</B> [pda_pass] (In the Messenger menu in the [P.name] [loc]).")

		else
			var/uplink_path = get_uplink_type(traitor_mob, /obj/item/uplink/syndicate)
			var/obj/item/uplink/syndicate/T = new uplink_path(get_turf(traitor_mob))
			T.lock_code_autogenerate = 1
			T.setup(traitor_mob.mind, null)
			pda_pass = T.lock_code
			traitor_mob.put_in_hand_or_drop(T)

			boutput(traitor_mob, "The Syndicate have <s>cunningly</s> disguised a Syndicate Uplink as [T.name]. Simply enter the code \"[pda_pass]\" into the device to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink password:</B> [pda_pass].")

/proc/alive_player_count()
	. = 0
	for(var/client/C)
		var/mob/M = C.mob
		if(!M || istype(M, /mob/new_player))
			continue
		if (!isdead(M) && isliving(M))
			.++

/// returns a decimal representing the percentage of alive crew that are also antags
/proc/get_alive_antags_percentage()
	var/alive = alive_player_count()
	var/alive_antags = ticker.mode.traitors.len + length(ticker.mode.Agimmicks)

	for (var/datum/mind/antag in ticker.mode.traitors)
		var/mob/M = antag.current
		if (!M) continue
		if (!M.client || isdead(M))
			alive_antags--
	for (var/datum/mind/antag in ticker.mode.Agimmicks)
		var/mob/M = antag.current
		if (!M) continue
		if (!M.client || isdead(M))
			alive_antags--

	if (!alive)
		return 0
	else
		return (alive_antags / alive)

/// returns a decimal representing the percentage of dead crew (non-observers) to all crew
/proc/get_dead_crew_percentage()
	var/all = 0
	var/dead = 0
	var/observer = 0

	for(var/client/C)
		var/mob/M = C.mob
		if(!M || isnewplayer(M)) continue
		if (isdead(M) && !isliving(M))
			dead++
			if (M.mind?.get_player()?.joined_observer)
				observer++
		all++

	if (!all)
		return 0
	else
		return ((dead - observer) / all)

/// Associative list of role defines and their respective client preferences.
var/list/roles_to_prefs = list(
	ROLE_TRAITOR = "be_traitor",
	ROLE_SPY_THIEF = "be_spy",
	ROLE_NUKEOP = "be_syndicate",
	ROLE_VAMPIRE = "be_vampire",
	ROLE_GANG_LEADER = "be_gangleader",
	ROLE_WIZARD = "be_wizard",
	ROLE_CHANGELING = "be_changeling",
	ROLE_WEREWOLF = "be_werewolf",
	ROLE_BLOB = "be_blob",
	ROLE_WRAITH = "be_wraith",
	ROLE_HEAD_REV = "be_revhead",
	ROLE_CONSPIRATOR = "be_conspirator",
	ROLE_ARCFIEND = "be_arcfiend",
	ROLE_FLOCKMIND = "be_flock",
	ROLE_SALVAGER = "be_salvager",
	ROLE_MISC = "be_misc"
	)

/**
  * Return the name of a preference variable for the given role define.
  *
  * Arguments:
  * * role - role to return a client preference for.
  */
/proc/get_preference_for_role(var/role)
	return roles_to_prefs[role]


/**
  * Returns a path of a (presumably) valid uplink dependent on the user's mind.
  *
  * Arguments:
  * * target - the mob that will own the uplink.
  *	* uplink - the path of the uplink type that you wish to spawn
  */
/proc/get_uplink_type(mob/target, obj/item/uplink/uplink)
	var/added_text
	switch(target?.mind?.special_role)
		if(ROLE_TRAITOR)
			added_text = "traitor"
		if(ROLE_SPY_THIEF) //Uses its own proc to create it, but leaving this here in case a refactor of it comes by
			added_text = "spy_thief"
		if("spy")
			added_text = "spy"
		if(ROLE_HEAD_REV)
			added_text = "rev"
		if(ROLE_NUKEOP, ROLE_NUKEOP_COMMANDER)
			added_text = "nukeop"
		if(ROLE_OMNITRAITOR)
			added_text = "omni"
	return text2path("[uplink]/[added_text]")
