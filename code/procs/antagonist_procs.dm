/client/proc/gearspawn_traitor()
	set category = "Commands"
	set name = "Call Syndicate"
	set desc="Teleports useful items to your location."

	if (usr.stat || !isliving(usr) || isintangible(usr))
		usr.show_text("You can't use this command right now.", "red")
		return

	var/obj/item/uplink/syndicate/U = new(usr.loc)
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

	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/assday))
		boutput(traitor_mob, "The Syndicate have clearly forgotten to give you a Syndicate Uplink. Lazy idiots.")
		SHOW_TRAITOR_HARDMODE_TIPS(traitor_mob)
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
				SHOW_TRAITOR_RADIO_TIPS(traitor_mob)
				return
	if (!R)
		traitor_mob.verbs += /client/proc/gearspawn_traitor
		SHOW_TRAITOR_RADIO_TIPS(traitor_mob)
	else
		if (!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)) && !(traitor_mob.mind && traitor_mob.mind.special_role == "spy"))
			SHOW_TRAITOR_PDA_TIPS(traitor_mob)

		if (istype(R, /obj/item/device/radio))
			var/obj/item/device/radio/RR = R
			var/obj/item/uplink/integrated/radio/T = new /obj/item/uplink/integrated/radio(RR)
			T.setup(traitor_mob.mind, RR)
			freq = RR.traitor_frequency

			boutput(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [RR.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([RR.name] [loc]).")

		else if (istype(R, /obj/item/device/pda2))
			var/obj/item/device/pda2/P = R
			var/obj/item/uplink/integrated/pda/T = new /obj/item/uplink/integrated/pda(P)
			T.setup(traitor_mob.mind, P)
			pda_pass = T.lock_code

			boutput(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [P.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Set your ringtone to:</B> [pda_pass] (In the Messenger menu in the [P.name] [loc]).")

		else
			var/obj/item/uplink/syndicate/T = new(get_turf(traitor_mob))
			T.lock_code_autogenerate = 1
			T.setup(traitor_mob.mind, null)
			pda_pass = T.lock_code
			traitor_mob.put_in_hand_or_drop(T)

			boutput(traitor_mob, "The Syndicate have <s>cunningly</s> disguised a Syndicate Uplink as [T.name]. Simply enter the code \"[pda_pass]\" into the device to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink password:</B> [pda_pass].")


/proc/equip_spy_theft(mob/living/carbon/human/traitor_mob)
	if (!(traitor_mob && ishuman(traitor_mob)))
		return

	if (!traitor_mob.r_store)
		traitor_mob.equip_if_possible(new /obj/item/device/flash(traitor_mob), traitor_mob.slot_r_store)
	else if (!traitor_mob.l_store)
		traitor_mob.equip_if_possible(new /obj/item/device/flash(traitor_mob), traitor_mob.slot_l_store)
	else if (istype(traitor_mob.back, /obj/item/storage/) && traitor_mob.back.contents.len < 7)
		traitor_mob.equip_if_possible(new /obj/item/device/flash(traitor_mob), traitor_mob.slot_in_backpack)
	else
		var/obj/F2 = new /obj/item/device/flash(get_turf(traitor_mob))
		traitor_mob.put_in_hand_or_drop(F2)

	var/pda_pass = null

	//find a PDA, hide the uplink inside
	var/loc = ""
	var/obj/item/device/R = null
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda2))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.r_store, /obj/item/device/pda2))
		R = traitor_mob.r_store
		loc = "In your pocket"
	if (!R && istype(traitor_mob.l_store, /obj/item/device/pda2))
		R = traitor_mob.l_store
		loc = "In your pocket"
	if (!R && istype(traitor_mob.l_hand, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.l_hand
		var/list/L = S.get_contents()
		for (var/obj/item/device/pda2/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.r_hand
		var/list/L = S.get_contents()
		for (var/obj/item/device/pda2/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/storage))
		var/obj/item/storage/S = traitor_mob.back
		var/list/L = S.get_contents()
		for (var/obj/item/device/pda2/foo in L)
			R = foo
			loc = "in the [S.name] in your backpack"
			break

	if (!R) //They have no PDA. Make one!
		R = new /obj/item/device/pda2(traitor_mob)
		loc = "in your backpack"
		if (traitor_mob.equip_if_possible(R, traitor_mob.slot_in_backpack) == 0)
			loc = "on the floor"
			R.set_loc(get_turf(traitor_mob))

	if (istype(R, /obj/item/device/pda2))
		var/obj/item/device/pda2/P = R
		var/obj/item/uplink/integrated/pda/spy/T = new /obj/item/uplink/integrated/pda/spy(P)
		T.setup(traitor_mob.mind, P)
		pda_pass = T.lock_code

		SHOW_SPY_THIEF_TIPS(traitor_mob)
		boutput(traitor_mob, "The Syndicate have cunningly disguised a Spy Uplink as your [P.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
		traitor_mob.mind.store_memory("<B>Set your ringtone to:</B> [pda_pass] (In the Messenger menu in the [P.name] [loc]).")
	else
		boutput(traitor_mob, "Something is BUGGED and we couldn't find you a PDA. Tell a coder.")


/proc/equip_syndicate(mob/living/carbon/human/synd_mob, var/leader = 0)
	if (!ishuman(synd_mob))
		return

	if(leader == 1)
		synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/commissar_cap(synd_mob), synd_mob.slot_head)
		synd_mob.equip_if_possible(new /obj/item/clothing/suit/space/syndicate/commissar_greatcoat(synd_mob), synd_mob.slot_wear_suit)
		synd_mob.equip_if_possible(new /obj/item/device/radio/headset/syndicate/leader(synd_mob), synd_mob.slot_ears)
		synd_mob.equip_if_possible(new /obj/item/katana_sheath/nukeop(synd_mob), synd_mob.slot_l_hand)
	else
		synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/swat(synd_mob), synd_mob.slot_head)
		synd_mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(synd_mob), synd_mob.slot_wear_suit)
		synd_mob.equip_if_possible(new /obj/item/device/radio/headset/syndicate(synd_mob), synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/swat(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)
	synd_mob.equip_if_possible(new /obj/item/storage/backpack/syndie/tactical(synd_mob), synd_mob.slot_back)
	//synd_mob.equip_if_possible(new /obj/item/ammo/bullets/a357(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/reagent_containers/pill/tox(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/remote/syndicate_teleporter(synd_mob), synd_mob.slot_l_store)
	//synd_mob.equip_if_possible(new /obj/item/gun/kinetic/revolver(synd_mob), synd_mob.slot_belt)
	synd_mob.equip_if_possible(new /obj/item/requisition_token/syndicate(synd_mob), synd_mob.slot_r_store)
/*
	var/obj/item/uplink/syndicate/U = new /obj/item/uplink/syndicate/alternate(synd_mob)
	if (synd_mob.mind && istype(synd_mob.mind))
		U.setup(synd_mob.mind)
	synd_mob.equip_if_possible(U, synd_mob.slot_r_store)
*/

	var/obj/item/card/id/syndicate/I = new /obj/item/card/id/syndicate(synd_mob) // for whatever reason, this is neccessary
	I.icon_state = "id"
	I.icon = 'icons/obj/items/card.dmi'
	synd_mob.equip_if_possible(I, synd_mob.slot_wear_id)

	var/obj/item/implant/microbomb/M = new /obj/item/implant/microbomb(synd_mob)
	M.implanted = 1
	synd_mob.implant.Add(M)
	M.implanted(synd_mob)

	var/the_frequency = R_FREQ_SYNDICATE
	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/nuclear))
		var/datum/game_mode/nuclear/N = ticker.mode
		the_frequency = N.agent_radiofreq

	for (var/obj/item/device/radio/headset/R in synd_mob.contents)
		R.set_secure_frequency("h", the_frequency)

		R.secure_classes = list(RADIOCL_SYNDICATE)
		R.protected_radio = 1 // Ops can spawn with the deaf trait.
		R.frequency = the_frequency // let's see if this stops rounds from being ruined every fucking time

	return
