/datum/game_mode/waldo
	name = "waldo"
	config_tag = "waldo"

	var/list/datum/mind/waldos = list()
	var/const/waldos_possible = 3
	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/waldo/announce()
	boutput(world, "<B>The current game mode is - Waldo!</B>")
	boutput(world, "<B><span class='alert'>A man named Waldo</span> is likely to be somewhere on the station. You must find him (And beware of any of his compatriots!)</B>")

/datum/game_mode/waldo/pre_setup()
	var/list/possible_waldos = get_possible_enemies(ROLE_MISC, 1)

	if(possible_waldos.len < 1)
		return 0

	var/num_players = 0
	for(var/mob/new_player/player in mobs)
		if (player.client && player.ready) num_players++

	var/num_waldos = clamp(round(num_players / 6), 1, waldos_possible)

	var/list/chosen_waldos = antagWeighter.choose(pool = possible_waldos, role = "waldo", amount = num_waldos, recordChosen = 1)
	for (var/datum/mind/waldo in chosen_waldos)
		waldos += waldo
		waldo.assigned_role = "MODE" //So they aren't chosen for other jobs.
		possible_waldos.Remove(waldo)

	return 1

/datum/game_mode/waldo/post_setup()
	var/num_waldos = length(waldos)
	for(var/turf/T in landmarks[LANDMARK_TELEPORT_SCROLL])
		for(var/scrollcount in 1 to num_waldos)
			new /obj/item/teleportation_scroll(T)
	var/k = 1
	for(var/datum/mind/waldo in waldos)
		if(!waldo || !istype(waldo))
			waldos.Remove(waldo)
			continue
		if(istype(waldo))
			switch(k)
				if(1)
					waldo.special_role = "waldo"
				if(2)
					waldo.special_role = "odlaw"
				if(3)
					waldo.special_role = ROLE_WIZARD
			waldo.current.resistances += list(/datum/ailment/disease/dnaspread, /datum/ailment/disease/clowning_around, /datum/ailment/disease/cluwneing_around, /datum/ailment/disease/enobola, /datum/ailment/disease/robotic_transformation)
			if(!job_start_locations["wizard"])
				boutput(waldo.current, "<B><span class='alert'>A starting location for you could not be found, please report this bug!</span></B>")
			else
				waldo.current.set_loc(pick(job_start_locations["wizard"]))
			if(waldo.special_role in list("odlaw", ROLE_WIZARD))
				switch(rand(1,100))
					if(1 to 30)
						var/datum/objective/assassinate/kill_objective = new
						kill_objective.owner = waldo
						kill_objective.find_target()
						waldo.objectives += kill_objective
						var/datum/objective/escape/escape_objective = new
						escape_objective.owner = waldo
						waldo.objectives += escape_objective
					if(31 to 60)
						var/datum/objective/force_evac_time/evac_objective = new
						evac_objective.owner = waldo
						waldo.objectives += evac_objective
						var/datum/objective/steal/steal_objective = new
						steal_objective.owner = waldo
						steal_objective.find_target()
						waldo.objectives += steal_objective
						var/datum/objective/escape/escape_objective = new
						escape_objective.owner = waldo
						waldo.objectives += escape_objective
					if(61 to 85)
						var/datum/objective/assassinate/kill_objective = new
						kill_objective.owner = waldo
						kill_objective.find_target()
						waldo.objectives += kill_objective
						var/datum/objective/steal/steal_objective = new
						steal_objective.owner = waldo
						steal_objective.find_target()
						waldo.objectives += steal_objective
						var/datum/objective/survive/survive_objective = new
						survive_objective.owner = waldo
						waldo.objectives += survive_objective
					else
						var/datum/objective/hijack_group/hijack_objective = new
						hijack_objective.owner = waldo
						hijack_objective.accomplices = waldos - waldo
						waldo.objectives += hijack_objective
			else
				var/datum/objective/stealth/stealth_objective = new
				stealth_objective.owner = waldo
				stealth_objective.get_score_count()
				stealth_objective.safe_minds = waldos - waldo
				waldo.objectives += stealth_objective
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = waldo
				waldo.objectives += escape_objective
			switch(waldo.special_role)
				if("waldo")
					boutput(waldo.current, "<B><span class='alert'>You are Waldo!</span></B>")
					waldo.current.real_name = "Waldo"
				if("odlaw")
					boutput(waldo.current, "<B><span class='alert'>You are Odlaw!</span></B>")
					waldo.current.real_name = "Odlaw"
				if(ROLE_WIZARD)
					boutput(waldo.current, "<B><span class='alert'>You are Wizard Whitebeard!</span></B>")
					waldo.current.real_name = "Wizard Whitebeard"
			equip_waldo(waldo.current)
			boutput(waldo.current, "<B>You have come to [station_name()] to carry out the following tasks:</B>")

			var/obj_count = 1
			for(var/datum/objective/objective in waldo.objectives)
				boutput(waldo.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
				obj_count++

			if(waldo.special_role == "waldo")
				boutput(waldo.current, "<span class='alert'><B><font size=3>WARNING: Being away from the station (ie. in space) will decrement your stealth points! Stay alive on the station!</font></B></span>")
			k++
//			var/I = image(antag_wizard, loc = waldo.current)
//			waldo.current.client.images += I
//			waldo.current << browse('waldo.jpg',"window=some;titlebar=1;size=550x400;can_minimize=0;can_resize=0")


	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/waldo/proc/equip_waldo(mob/living/carbon/human/waldo_mob)
	if (!istype(waldo_mob))
		return
	var/datum/mind/waldo_mind = waldo_mob.mind
	if(waldo_mind)
		switch(waldo_mind.special_role)
			if("waldo")
				waldo_mob.verbs += /client/proc/waldo_decoys
				waldo_mob.equip_if_possible(new /obj/item/clothing/shoes/brown(waldo_mob), waldo_mob.slot_shoes)
				waldo_mob.equip_if_possible(new /obj/item/clothing/under/waldo(waldo_mob), waldo_mob.slot_w_uniform)
				waldo_mob.equip_if_possible(new /obj/item/clothing/head/waldohat(waldo_mob), waldo_mob.slot_head)
				waldo_mob.equip_if_possible(new /obj/item/device/pda2/syndicate(waldo_mob), waldo_mob.slot_belt)
				waldo_mob.w_uniform.cant_self_remove = 1
				waldo_mob.head.cant_self_remove = 1
				waldo_mob.w_uniform.cant_other_remove = 1
				waldo_mob.head.cant_other_remove = 1


			if("odlaw")
				waldo_mob.equip_if_possible(new /obj/item/clothing/shoes/black(waldo_mob), waldo_mob.slot_shoes)
				waldo_mob.equip_if_possible(new /obj/item/clothing/under/odlaw(waldo_mob), waldo_mob.slot_w_uniform)
				waldo_mob.equip_if_possible(new /obj/item/clothing/head/odlawhat(waldo_mob), waldo_mob.slot_head)
				waldo_mob.equip_if_possible(new /obj/item/device/pda2/syndicate(waldo_mob), waldo_mob.slot_belt)
				waldo_mob.w_uniform.cant_self_remove = 1
				waldo_mob.head.cant_self_remove = 1
				waldo_mob.w_uniform.cant_other_remove = 1
				waldo_mob.head.cant_other_remove = 1
				equip_traitor(waldo_mob)

			if(ROLE_WIZARD)
				waldo_mob.verbs += /client/proc/invisibility
				waldo_mob.verbs += /client/proc/mass_teleport

				var/freq = 1441
				var/list/freqlist = list()
				while (freq <= 1489)
					if (freq < 1451 || freq > 1459)
						freqlist += freq
					freq += 2
					if ((freq % 2) == 0)
						freq += 1
				freq = freqlist[rand(1, freqlist.len)]
				// generate a passcode if the uplink is hidden in a PDA
				var/pda_pass = "[rand(100,999)] [pick("Morgan","Circe","Prospero","Merlin")]"

				waldo_mob.equip_if_possible(new /obj/item/clothing/under/color/white(waldo_mob), waldo_mob.slot_w_uniform)
				waldo_mob.equip_if_possible(new /obj/item/clothing/suit/wizrobe(waldo_mob), waldo_mob.slot_wear_suit)
				waldo_mob.equip_if_possible(new /obj/item/clothing/head/wizard(waldo_mob), waldo_mob.slot_head)
				waldo_mob.equip_if_possible(new /obj/item/clothing/shoes/sandal/wizard(waldo_mob), waldo_mob.slot_shoes)
				waldo_mob.equip_if_possible(new /obj/item/staff(waldo_mob), waldo_mob.slot_r_hand)
				waldo_mob.equip_if_possible(new /obj/item/device/pda2/syndicate(waldo_mob), waldo_mob.slot_belt)

				var/loc_text = ""
				var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
				if (!R && istype(waldo_mob.belt, /obj/item/device/pda2))
					R = waldo_mob.belt
					loc_text = "on your belt"
				if (!R && istype(waldo_mob.l_hand, /obj/item/storage))
					var/obj/item/storage/S = waldo_mob.l_hand
					var/list/L = S.return_inv()
					for (var/obj/item/device/radio/foo in L)
						R = foo
						loc_text = "in the [S.name] in your left hand"
						break
				if (!R && istype(waldo_mob.r_hand, /obj/item/storage))
					var/obj/item/storage/S = waldo_mob.r_hand
					var/list/L = S.return_inv()
					for (var/obj/item/device/radio/foo in L)
						R = foo
						loc_text = "in the [S.name] in your right hand"
						break
				if (!R && istype(waldo_mob.back, /obj/item/storage))
					var/obj/item/storage/S = waldo_mob.back
					var/list/L = S.return_inv()
					for (var/obj/item/device/radio/foo in L)
						R = foo
						loc_text = "in the [S.name] on your back"
						break
					if(!R)
						R = new /obj/item/device/radio/headset(waldo_mob)
						loc_text = "in the [S.name] on your back"
						waldo_mob.equip_if_possible(R, waldo_mob.slot_in_backpack)
				if (!R && waldo_mob.w_uniform && istype(waldo_mob.belt, /obj/item/device/radio))
					R = waldo_mob.belt
					loc_text = "on your belt"
				if (!R && istype(waldo_mob.ears, /obj/item/device/radio))
					R = waldo_mob.ears
					loc_text = "on your head"
				if (!R)
					boutput(waldo_mob, "Unfortunately, the Space Wizards Federation wasn't able to get you a radio.")
				else
					if (istype(R, /obj/item/device/radio))
						var/obj/item/SWF_uplink/T = new /obj/item/SWF_uplink(R)
						R:traitorradio = T
						R:traitor_frequency = freq
						T.name = R.name
						T.icon_state = R.icon_state
						T.origradio = R
						boutput(waldo_mob, "The Space Waldos Federation have cunningly disguised a spell book as your [R.name] [loc_text]. Simply dial the frequency [format_frequency(freq)] to unlock it's hidden features.")
						waldo_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc_text]).")
					else if (istype(R, /obj/item/device/pda2))
						var/obj/item/uplink/integrated/SWF/T = new /obj/item/uplink/integrated/SWF(R)
						R:uplink = T
						T.lock_code = pda_pass
						T.hostpda = R
						boutput(waldo_mob, "The Space Waldos Federation have cunningly enchanted a spellbook into your PDA [loc_text]. Simply enter the code \"[pda_pass]\" into the ring message select to unlock its hidden features.")
						waldo_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc_text]).")
		waldo_mob.equip_if_possible(new /obj/item/device/radio/headset/syndicate(waldo_mob), waldo_mob.slot_ears)
		waldo_mob.equip_if_possible(new /obj/item/card/id/syndicate(waldo_mob), waldo_mob.slot_wear_id)
		waldo_mob.equip_if_possible(new /obj/item/storage/backpack(waldo_mob), waldo_mob.slot_back)

		waldo_mob.wear_id.registered = waldo_mob.real_name
		waldo_mob.wear_id.assignment = "None"
		waldo_mob.wear_id.name = "[waldo_mob.wear_id.registered]'s ID Card"
		waldo_mob.wear_id.access = get_access("Assistant")


/datum/game_mode/waldo/send_intercept()
	..(src.waldos)

/datum/game_mode/waldo/declare_completion()
	var/wizcount = 0
	var/wizdeathcount = 0
	for (var/datum/mind/W in waldos)
		wizcount++
		if(!W.current || isdead(W.current)) wizdeathcount++
	if (wizcount == wizdeathcount)
		if (wizcount >= 2) boutput(world, "<span class='alert'><FONT size=3><B>Waldo and friends have been killed by the crew!</B></FONT></span>")
		else boutput(world, "<span class='alert'><FONT size=3><B>Waldo has been killed by the crew!</B></FONT></span>")
	else
		boutput(world, "<span class='alert'><font size=3><b>Waldo and friends have survived their stay at [station_name()]!</b></font></span>")

	var/waldo_name
#ifdef DATALOGGER
	var/waldowin = 1
#endif
	for (var/datum/mind/W in waldos)
		if(W.current)
			waldo_name = "[W.current.real_name] (played by [W.key])"
		else
			waldo_name = "[W.key] (character destroyed)"
		boutput(world, "<B>[waldo_name]</B>")
		var/count = 1


		for(var/datum/objective/objective in W.objectives)
			if(objective.check_completion())
				boutput(world, "<B>Objective #[count]</B>: [objective.explanation_text] <span class='success'><B>Success</B></span>")
			else
				boutput(world, "<B>Objective #[count]</B>: [objective.explanation_text] <span class='alert'>Failed</span>")
#ifdef DATALOGGER
				waldowin = 0
#endif
			count++
#ifdef DATALOGGER
	if(waldowin)
		game_stats.Increment("traitorwin")
	else
		game_stats.Increment("traitorloss")
#endif


/datum/game_mode/waldo/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/living/player in mobs)
		if (player.client)
			mobs += player
	return mobs

/datum/game_mode/waldo/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/mob/living/player in mobs)
		if (player.client && (player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)

datum/game_mode/waldo/check_finished()
	var/wizcount = 0
	var/wizdeathcount = 0
	for (var/datum/mind/W in waldos)
		wizcount++
		if(!W.current || isdead(W.current)) wizdeathcount++

	if (wizcount == wizdeathcount) return 1
	else return ..()
