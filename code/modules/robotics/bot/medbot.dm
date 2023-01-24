//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY
#define MEDBOT_MOVE_SPEED 6
#define MEDBOT_LASTPATIENT_COOLDOWN "medbot_anti_patient_clinginess"
#define MEDBOT_POINT_COOLDOWN "medbot_pointing_antirudeness"

/obj/machinery/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/obj/bots/medbots.dmi'
	icon_state = "medibot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	luminosity = 2
	req_access = list(access_medical)
	access_lookup = "Medical Doctor"
	flags = NOSPLASH
	on = 1
	health = 20
	locked = 1
	bot_move_delay = MEDBOT_MOVE_SPEED

	var/obj/item/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null // options are brute1/2, burn1/2, toxin1/2, brain1/2, O21/2/3/4, berserk1/2/3, and psyche
	var/mob/living/carbon/patient = null
	var/oldloc = null
	var/static/image/medbot_overlays = image('icons/obj/bots/medbots.dmi', icon_state = "blank")
	var/last_found = 0
	/// Time after injecting someone before they'll try to inject them again. Encourages them to spread the love (and poison). Hitting the bot overrides the cooldown
	var/last_patient_cooldown = 5 SECONDS
	var/point_cooldown = 10 SECONDS //Don't spam your pointer-finger
	var/currently_healing = 0
	var/injection_amount = 10 //How much reagent do we inject at a time?
	var/heal_threshold = 15 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "saline"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "saline"
	var/treatment_tox = "anti_rad"
	var/treatment_virus = "spaceacillin"
	/// the stuff the bot injects when emagged
	var/list/dangerous_stuff = list()
	/// Set this to make the bot only inject all this crap
	var/list/override_reagent = list()
	/// They'll stop stop injecting that crap if the patient has the per-inject amount
	var/override_reagent_limit_mult = 0.9
	var/terrifying = 0 // for making the medbots all super fucked up
	/// List of drugs that terrifying derelist bots will inject
	var/static/list/terrifying_meds = list("formaldehyde" = 15,
																				"ketamine" = 25,
																				"pancuronium" = 5,
																				"haloperidol" = 15,
																				"morphine" = 20,
																				"cold_medicine" = 40,
																				"simethicone" = 10,
																				"sulfonal" = 5, /* its an oldetimey sedative */
																				"atropine" = 10,
																				"methamphetamine" = 30,
																				"ethanol" = 20, /* rubbing alcohol */
																				"ether" = 10,
																				"chlorine" = 10, /* disinfectant */
																				"mercury" = 5)

/obj/machinery/bot/medbot/no_camera
	no_camera = 1

/obj/machinery/bot/medbot/mysterious
	name = "Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "berserk"

/obj/machinery/bot/medbot/terrifying
	name = "Medibot"
	desc = "You don't recognize this model."
	icon = 'icons/misc/evilreaverstation.dmi'
	health = 50
	density = 1
	emagged = 1
	terrifying = 1
	anchored = 1 // don't drag it into space goddamn jerks
	no_camera = 1
	last_patient_cooldown = 5 SECONDS // There's usually only one target anyway, and we want to mess them up right good

/obj/machinery/bot/medbot/head_surgeon
	name = "Medibot - 'Head Surgeon'"
	desc = "The HS sure looks different today! Maybe he got a haircut?"
	skin = "hs"
	treatment_oxy = "perfluorodecalin"
	access_lookup = "Head Surgeon"
	text2speech = 1

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_HEAD_SURGEON)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_HEAD_SURGEON)
		. = ..()

/obj/machinery/bot/medbot/hippocrates
	name = "Hippocrates The Cleric"
	desc = "A mage practicing in the art of healing magic. He's not very good but he's enthusiastic."
	skin = "wizard"

/obj/machinery/bot/medbot/head_surgeon/no_camera
	no_camera = 1

/obj/machinery/bot/medbot/psyche
	name = "Psychedelic Medibot"
	desc = "He's high on a hell of a lot more than life!"
	skin = "psyche"
	treatment_brute = "LSD"
	treatment_oxy = "psilocybin"
	treatment_fire = "LSD"
	treatment_tox = "psilocybin"
	treatment_virus = "loose screws"
	no_camera = 1

/obj/machinery/bot/medbot/homeopath
	name = "Hollistic Medibot"
	desc = "Finally a Medibot that can practice chiropractic!"
	skin = "psyche"
	color = "#88FFAA"
	treatment_brute = "CBD"
	treatment_oxy = "THC"
	treatment_fire = "LSD"
	treatment_tox = "hugs"
	treatment_virus = "chickensoup"
	no_camera = 1

/obj/machinery/bot/medbot/medass
	name = "MedicalAssistant"
	desc = "A little medical robot. This one looks very busy."
	skin = "medicalassistant"
	no_camera = 1

/obj/item/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/bots/medbots.dmi'
	icon_state = "medskin-firstaid"
	item_state = "firstaid"
	pixel_y = 4 // so we don't have to have two sets of the skin sprites, we're just gunna bump this up a bit
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null // same as the bots themselves: options are brute1/2, burn1/2, toxin1/2, brain1/2, O21/2/3/4, berserk1/2/3, and psyche
	w_class = W_CLASS_NORMAL

/obj/item/firstaid_arm_assembly/New()
	..()
	SPAWN(0.5 SECONDS)
		if (src.skin)
			src.overlays += "medskin-[src.skin]"
			src.overlays += "medibot-arm"

/obj/machinery/bot/medbot/update_icon(var/stun = 0, var/heal = 0)
	UpdateOverlays(null, "medbot_overlays")
	medbot_overlays.overlays.len = 0

	if (src.terrifying)
		src.icon_state = "medibot[src.on]"
		if (stun)
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibota")
		if (heal)
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibots")
		return

	else
		src.icon_state = "medibot"
		if (src.skin)
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medskin-[src.skin]")
		medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-scanner")
		if (heal)
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-arm-syringe")
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-light-flash")
		else
			medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-arm")
			if (stun)
				medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-light-stun")
			else
				medbot_overlays.overlays += image('icons/obj/bots/medbots.dmi', icon_state = "medibot-light[src.on]")
		/*
		if (emagged)
			src.overlays += "medibot-spark"
		*/
	UpdateOverlays(medbot_overlays, "medbot_overlays")
	return

/obj/machinery/bot/medbot/New()
	..()
	add_simple_light("medbot", list(220, 220, 255, 0.5*255))
	SPAWN(0.5 SECONDS)
		if (src)
			src.UpdateIcon()
	return

/obj/machinery/bot/medbot/attack_ai(mob/user as mob)
	return toggle_power()

/obj/machinery/bot/medbot/attack_hand(mob/user, params)
	if (src.terrifying)
		return

	var/dat
	dat += "<TT><B>Automatic Medical Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Beaker: "
	if (src.reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[src.reagent_glass.reagents.total_volume]/[src.reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]"
	if (!src.locked)
		dat += "<hr><TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[src.heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[src.injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[src.use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

	if (user.client?.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Medibot v1.0 controls",
			"content" = dat,
			"size" = "260xauto"
		))

	return

/obj/machinery/bot/medbot/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		src.toggle_power()

	else if ((href_list["adj_threshold"]) && (!src.locked))
		var/adjust_num = text2num_safe(href_list["adj_threshold"])
		src.heal_threshold += adjust_num
		if (src.heal_threshold < 5)
			src.heal_threshold = 5
		if (src.heal_threshold > 75)
			src.heal_threshold = 75

	else if ((href_list["adj_inject"]) && (!src.locked))
		var/adjust_num = text2num_safe(href_list["adj_inject"])
		src.injection_amount += adjust_num
		if (src.injection_amount < 5)
			src.injection_amount = 5
		if (src.injection_amount > 15)
			src.injection_amount = 15

	else if ((href_list["use_beaker"]) && (!src.locked))
		src.use_beaker = !src.use_beaker

	else if (href_list["eject"] && (!isnull(src.reagent_glass)))
		if (!src.locked)
			src.reagent_glass.set_loc(get_turf(src))
			usr.put_in_hand_or_eject(src.reagent_glass) // try to eject it into the users hand, if we can
			src.reagent_glass = null
		else
			boutput(usr, "You cannot eject the beaker because the panel is locked!")

	src.updateUsrDialog()
	return

/obj/machinery/bot/medbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='alert'>You short out [src]'s reagent synthesis circuits.</span>")
		src.KillPathAndGiveUp(1)
		ON_COOLDOWN(src, "[MEDBOT_LASTPATIENT_COOLDOWN]-[ckey(user?.name)]", src.last_patient_cooldown * 10) // basically ignore the emagger for a long while. Till someone hits it!
		src.emagged = 1
		src.on = 1
		src.UpdateIcon()
		src.pick_poison()
		logTheThing(LOG_STATION, user, "emagged a [src] at [log_loc(src)].")
		return 1
	return 0


/obj/machinery/bot/medbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s reagent synthesis circuits.", "blue")
	src.emagged = 0
	src.KillPathAndGiveUp(1)
	src.UpdateIcon()
	return 1

/obj/machinery/bot/medbot/attackby(obj/item/W, mob/user)
	//if (istype(W, /obj/item/card/emag)) // this gets to stay here because it is a good story
		/*
		I caught a fish once, real little feller, it was.
		As I was preparing to throw it back into the lake this gray cat came up to me.
		Without a sound he stands on his hind legs next to me, silently watching what I'm doing.
		He stands like that for several minutes, looking at the fish, then at me, then back at the fish
		Eventually I gave him the fish.
		He followed me home.
		Good catte.

		Also the override is here so you don't thwap the bot with the emag
		*/
		//return
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			src.updateUsrDialog()
		else
			boutput(user, "<span class='alert'>Access denied.</span>")

	else if (isscrewingtool(W))
		if (src.health < initial(src.health))
			src.health = initial(src.health)
			src.visible_message("<span class='notice'>[user] repairs [src]!</span>", "<span class='notice'>You repair [src].</span>")

	else if (istype(W, /obj/item/reagent_containers/glass))
		if (src.locked)
			boutput(user, "You cannot insert a beaker because the panel is locked!")
			return
		if (!isnull(src.reagent_glass))
			boutput(user, "There is already a beaker loaded!")
			return

		user.drop_item()
		W.set_loc(src)
		src.reagent_glass = W
		boutput(user, "You insert [W].")
		src.updateUsrDialog()
		return

	else
		switch(W.hit_type)
			if (DAMAGE_BURN)
				src.health -= W.force * 0.75
			else
				src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()
		else if (W.force)
			src.cooldowns = list() // Mainly applies to hostile bots
			step_to(src, (get_step_away(src,user)))
			src.KillPathAndGiveUp(1)
			if(ishuman(user))
				src.patient = user
			src.process() // slap the good doctor into healing you, good idea
		..()

/obj/machinery/bot/medbot/process()
	. = ..()
	if (!src.on)
		src.stunned = 0
		return

	if (src.stunned)
		src.UpdateIcon(/*stun*/ 1)
		src.stunned--

		src.KillPathAndGiveUp(1)

		if(src.stunned <= 0)
			src.stunned = 0
			src.UpdateIcon()
		return

	if (src.frustration > 8)
		src.KillPathAndGiveUp(1)

	if (!src.patient)
		if(prob(1))
			var/message = pick("Radar, put a mask on!","I'm a doctor.","There's always a catch, and it's the best there is.",\
			"I knew it, I should've been a plastic surgeon.",\
			"What kind of medbay is this? Everyone's dropping like dead flies.","Delicious!")
			src.speak(message)
		src.seek_patient()

	if (src.patient)
		if(IN_RANGE(src,src.patient,1))
			src.KillPathAndGiveUp(0)
			src.medicate_patient(src.patient)
			return
		else if(IN_RANGE(src,src.patient,10))
			src.KillPathAndGiveUp(0)
			navigate_to(get_turf(src.patient), MEDBOT_MOVE_SPEED, max_dist = 10)
		else
			src.KillPathAndGiveUp(1)

	if(src.frustration >= 8)
		src.KillPathAndGiveUp(1)

/obj/machinery/bot/medbot/proc/seek_patient()
	if(src.currently_healing)
		return // busybusy

	for_by_tcl(C, /mob/living/carbon) //Time to find a patient!
		if(!IN_RANGE(src, C, 7))
			continue

		if ((isdead(C)) || !ishuman(C))
			continue

		if (C.loc && !isturf(C.loc)) // don't stab people while they're still in the cloner, wait till they're out first!
			continue

		if (src.assess_patient(C))
			src.patient = C
			src.doing_something = 1
			if (!ON_COOLDOWN(src, "[MEDBOT_POINT_COOLDOWN]-[ckey(src.patient?.name)]", src.point_cooldown)) //Don't spam these messages!
				src.point(src.patient, 1)
				var/message = pick("Hey, you! Hold on, I'm coming.","Wait! I want to help!","You appear to be injured!","Don't worry, I'm trained for this!")
				src.speak(message)

			if(IN_RANGE(src,src.patient,1))
				src.KillPathAndGiveUp(0)
				return
			else
				src.KillPathAndGiveUp(0)
				navigate_to(get_turf(src.patient), MEDBOT_MOVE_SPEED, max_dist = 10)
				return
		else
			continue

/obj/machinery/bot/medbot/proc/pick_poison()
	src.dangerous_stuff = list()
	switch(rand(1, 100))/* - what's deadly is this nonsense factory you call code!
		if(1 to 5) // deadly deadly poison
			src.audible_message("[src] makes an ominous buzzing noise!")
			src.dangerous_stuff[pick_string("chemistry_tools.txt", "traitor_poison_bottle")] = 1 // they're pretty deadly
			*/
		if(11 to 50) // obnoxious but also pretty deadly poison
			src.audible_message("[src] makes a trippy buzzing noise!")
			var/primaries = rand(1,3)
			var/adulterants = rand(2,4)
			var/adulterants_safe = rand(2,4)
			for(var/i in 1 to (primaries + adulterants + adulterants_safe))
				if(primaries >= 1)
					src.dangerous_stuff[pick_string("chemistry_tools.txt", "CYBERPUNK_drug_primaries")] += 3
					primaries--
					continue
				if(adulterants >= 1)
					src.dangerous_stuff[pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants")] += 3
					adulterants--
					continue
				if(adulterants_safe >= 1)
					src.dangerous_stuff[pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants_safe")] += 3
					adulterants_safe--
					continue
		else // annoying knockout stun poisons
			src.audible_message("[src] makes an awful buzzing noise!")
			src.dangerous_stuff["pancuronium"] = 10

/obj/machinery/bot/medbot/proc/toggle_power()
	src.on = !src.on
	if (src.on)
		add_simple_light("medbot", list(220, 220, 255, 0.5*255))
	else
		remove_simple_light("medbot")
	src.KillPathAndGiveUp(1)
	src.UpdateIcon()
	src.updateUsrDialog()
	return

/obj/machinery/bot/medbot/proc/assess_patient(mob/living/carbon/C as mob)
	//Time to see if they need medical help!
	if(GET_COOLDOWN(src, "[MEDBOT_LASTPATIENT_COOLDOWN]-[ckey(C.name)]"))
		return 0 // Give them some time to heal!

	if(isdead(C))
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(src.emagged || src.terrifying) //Everyone needs our medicine. (Our medicine is toxins)
		if(is_incapacitated(C))
			return 0
		else
			return 1

	var/brute = C.get_brute_damage()
	var/burn = C.get_burn_damage()
	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((src.reagent_glass) && (src.use_beaker) && ((brute >= heal_threshold) || (burn >= heal_threshold) || (C.get_toxin_damage() >= heal_threshold) || (C.get_oxygen_deprivation() >= (heal_threshold + 15))))
		for(var/current_id in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(current_id))
				return 1
			continue

	//They're injured enough for it!
	if((brute >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((C.get_oxygen_deprivation() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(src.treatment_oxy)))
		return 1

	if((burn >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_fire)))
		return 1

	if((C.get_toxin_damage() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_tox)))
		return 1

	for(var/datum/ailment_data/disease/am in C.ailments)
		if((am.stage > 1) || (am.spread == "Airborne"))
			if (!C.reagents.has_reagent(src.treatment_virus))
				return 1 //STOP DISEASE FOREVER

	return 0

/obj/machinery/bot/medbot/proc/medicate_patient(mob/living/carbon/C as mob)
	if(!src.on || src.currently_healing)
		return FALSE

	if(!istype(C))
		src.KillPathAndGiveUp(1)
		return FALSE

	if(isdead(C))
		var/death_message = pick("No! NO!","Live, damnit! LIVE!","I...I've never lost a patient before. Not today, I mean.")
		src.speak(death_message)
		src.KillPathAndGiveUp(1)
		return FALSE

	if (C.loc && !isturf(C.loc)) // don't stab people while they're still in the cloner, wait till they're out first!
		var/missing_message = pick("Wait, where'd [he_or_she(C)] go?","That's okay, I'll just wait here until you're ready.")
		src.speak(missing_message)
		src.KillPathAndGiveUp(1)
		return FALSE

	var/list/reagent_id = list()
	var/brute = C.get_brute_damage()
	var/burn = C.get_burn_damage()

	if(length(src.override_reagent))
		var/reag_id = pick(src.override_reagent)
		if(!C.reagents.has_reagent(reag_id, src.override_reagent[reag_id] * src.override_reagent_limit_mult))
			reagent_id = src.override_reagent

	else
		//Use whatever is inside the loaded beaker. If there is one.
		if ((src.use_beaker) && (src.reagent_glass) && (src.reagent_glass.reagents.total_volume))
			reagent_id = "internal_beaker"

		if(src.terrifying)
			if(!is_incapacitated(C))
				for(var/i in 1 to rand(1,4))
					var/badmed_id = pick(src.terrifying_meds)
					reagent_id[badmed_id] += rand(1, src.terrifying_meds[badmed_id])

		else if (src.emagged) //Emagged! Time to poison everybody.
			if(!is_incapacitated(C))
				var/reag_check = pick(src.dangerous_stuff)
				if(!C.reagents.has_reagent(reag_check, src.dangerous_stuff[reag_check] * 1.5)) // *shrug* two-ish doses of our poison, on average
					reagent_id = src.dangerous_stuff

		else
			if (length(reagent_id) < 1)
				if (brute >= heal_threshold)
					if(!C.reagents.has_reagent(src.treatment_brute))
						reagent_id[src.treatment_brute] = 15
				if (burn >= heal_threshold)
					if(!C.reagents.has_reagent(src.treatment_fire))
						reagent_id[src.treatment_fire] = 15
				if (C.get_toxin_damage() >= heal_threshold)
					if(!C.reagents.has_reagent(src.treatment_tox))
						reagent_id[src.treatment_tox] = 15
				if(!C.reagents.has_reagent(src.treatment_virus))
					reagent_id[src.treatment_virus] = 15
				if (C.get_oxygen_deprivation() >= (15 + heal_threshold))
					if(!C.reagents.has_reagent(src.treatment_oxy))
						reagent_id[src.treatment_oxy] = 15

	if (length(reagent_id) < 1) //If they don't need any of that they're probably cured!
		var/message = pick("All patched up!","An apple a day keeps me away.","Feel better soon!")
		src.speak(message)
		src.KillPathAndGiveUp(1)
		return FALSE
	else if(!actions.hasAction(src, "medbot_inject"))
		src.KillPathAndGiveUp(0)
		actions.start(new/datum/action/bar/icon/medbot_inject(src, reagent_id), src)
		return TRUE

/obj/machinery/bot/medbot/DoWhileMoving()
	. = ..()
	if (src.patient && IN_RANGE(src,src.patient,1))
		return TRUE

/obj/machinery/bot/medbot/KillPathAndGiveUp(var/give_up)
	. = ..()
	src.currently_healing = 0
	src.oldloc = null
	src.path = null
	if(give_up)
		if(istype(src.patient))
			ON_COOLDOWN(src, "[MEDBOT_LASTPATIENT_COOLDOWN]-[ckey(src.patient?.name)]", src.last_patient_cooldown)
		src.patient = null

/datum/action/bar/icon/medbot_inject
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "medbot_inject"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "syringe_15"
	var/obj/machinery/bot/medbot/master
	var/list/reagent_id
	var/did_spooky = 0

	New(var/the_bot, var/list/reagentid)
		src.master = the_bot
		src.reagent_id = reagentid
		if(master.terrifying)
			duration = 2 SECONDS
			REMOVE_FLAG(interrupt_flags, INTERRUPT_MOVE)
		..()

	onUpdate()
		..()
		if (src.fail_check())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (master.terrifying)
			if(!(BOUNDS_DIST(master, master.patient) == 0) && !master.moving)
				master.navigate_to(get_turf(master.patient), MEDBOT_MOVE_SPEED, 1, 10)
			if(!src.did_spooky && prob(10))
				if (prob(20))
					var/message = pick("It will be okay.","You're okay.", "Everything will be alright,","Please remain calm.",\
					"Please calm down, sir.","You need to calm down.","CODE BLUE.","You're going to be just fine.","Hold stIll.",\
					"Sedating patient.","ALERT.","I think we're losing them...","You're only hurting yourself.",\
					"MEM ERR BLK 0  ADDR 30FC500 HAS 010F NOT 0000","MEM ERR BLK 3  ADDR 55005FF HAS 020A NOT FF00",\
					"ERROR: Missing or corrupted resource filEs. Plea_-se contact a syst*m administrator.","ERROR: Corrupted kernel. Ple- - a",\
					"This will all be over soon.")
					master.speak(message)
				else
					master.visible_message("<b>[master] [pick("freaks out","glitches out","tweaks out", "malfunctions", "twitches")]!</b>")
					var/glitchsound = pick('sound/machines/romhack1.ogg', 'sound/machines/romhack2.ogg', 'sound/machines/romhack3.ogg',\
					'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')
					playsound(master.loc, glitchsound, 50, 1)
					// let's grustle a bit
					SPAWN(1 DECI SECOND)
						master.pixel_x += rand(-2,2)
						master.pixel_y += rand(-2,2)
						sleep(0.1 SECONDS)
						master.pixel_x += rand(-2,2)
						master.pixel_y += rand(-2,2)
						sleep(0.1 SECONDS)
						master.pixel_x += rand(-2,2)
						master.pixel_y += rand(-2,2)
						sleep(0.1 SECONDS)
						master.pixel_x = 0
						master.pixel_y = 0
					hit_twitch(master)
				src.did_spooky = 1

	onStart()
		..()
		if (src.fail_check())
			interrupt(INTERRUPT_ALWAYS)
			return

		attack_twitch(master)
		master.currently_healing = 1
		master.UpdateIcon(/*stun*/ 0, /*heal*/ 1)
		master.visible_message("<span class='alert'><B>[master] is trying to inject [master.patient]!</B></span>")

	onInterrupt()
		. = ..()
		master.KillPathAndGiveUp()
		master.UpdateIcon()

	onEnd()
		..()
		if ((BOUNDS_DIST(master, master.patient) == 0) && (master.on))
			if ((reagent_id == "internal_beaker") && (master.reagent_glass) && (master.reagent_glass.reagents.total_volume))
				master.reagent_glass.reagents.trans_to(master.patient,master.injection_amount) //Inject from beaker instead.
				master.reagent_glass.reagents.reaction(master.patient, 2, master.injection_amount)
			else
				for(var/reagent in reagent_id)
					master.patient.reagents.add_reagent(reagent, reagent_id[reagent])

			master.visible_message("<span class='alert'><B>[master] injects [master.patient] with the syringe!</B></span>")

		else if(master.terrifying)
			var/list/sput_words = list()
			var/datum/reagents/sput = new/datum/reagents(1)
			for(var/reagent in reagent_id)
				sput.maximum_volume += round(reagent_id[reagent] / length(reagent_id))
				sput.add_reagent(reagent, round(reagent_id[reagent] / length(reagent_id)))
				sput_words += reagent_id_to_name(reagent)
			smoke_reaction(sput, 1, get_turf(master))
			master.visible_message("<span class='alert'>A shower of [english_list(sput_words)] shoots out of [master]'s hypospray!</span>")
		playsound(master, 'sound/items/hypo.ogg', 80, 0)

		master.KillPathAndGiveUp() // Don't discard the patient just yet, maybe they need more healing!
		master.UpdateIcon()

	proc/fail_check()
		if(!master.on)
			return TRUE
		if(!istype(master.patient))
			return TRUE
		if(!master.terrifying && !(BOUNDS_DIST(master, master.patient) == 0))
			return TRUE

// copied from transposed scientists

#define fontSizeMax 3
#define fontSizeMin -3

/obj/machinery/bot/medbot/terrifying/speak(var/message)
	if ((!src.on) || (!message))
		return

	var/list/audience = hearers(src, null)
	if (!audience || !length(audience))
		return

	var/fontSize = 1
	var/fontIncreasing = 1
	var/messageLen = length(message)
	var/processedMessage = ""

	for (var/i = 1, i <= messageLen, i++)
		processedMessage += "<font size=[fontSize]>[copytext(message, i, i+1)]</font>"
		if (fontIncreasing)
			fontSize = min(fontSize+1, fontSizeMax)
			if (fontSize >= fontSizeMax)
				fontIncreasing = 0
		else
			fontSize = max(fontSize-1, fontSizeMin)
			if (fontSize <= fontSizeMin)
				fontIncreasing = 1

	message = processedMessage

	..()

#undef fontSizeMax
#undef fontSizeMin

/obj/machinery/bot/medbot/bullet_act(var/obj/projectile/P)
	..()
	if (src && (P && istype(P) && P.proj_data.damage_type == D_ENERGY))
		src.stunned += 5
		if (src.stunned > 15)
			src.stunned = 15
	return

/obj/machinery/bot/medbot/ex_act(severity)
	switch(severity)
		if(1)
			src.explode()
			return
		if(2)
			src.health -= 15
			if (src.health <= 0)
				src.explode()
			return
	return

/obj/machinery/bot/medbot/emp_act()
	..()
	if(!src.emagged && prob(75))
		src.emagged = 1
		src.on = 1
		src.pick_poison()
	else
		src.explode()
	return

/obj/machinery/bot/medbot/meteorhit()
	src.explode()
	return

/obj/machinery/bot/medbot/blob_act(var/power)
	if(prob(25 * power / 20))
		src.explode()
	return

/obj/machinery/bot/medbot/gib()
	return src.explode()

/obj/machinery/bot/medbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.audible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/storage/firstaid(Tsec)

	new /obj/item/device/prox_sensor(Tsec)

	new /obj/item/device/analyzer/healthanalyzer(Tsec)

	if(src.reagent_glass)
		src.reagent_glass.set_loc(Tsec)
		src.reagent_glass = null

	if (prob(50))
		new /obj/item/parts/robot_parts/arm/left/standard(Tsec)

	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return

/*
 *	Medbot Assembly -- Can be made out of all three medkits.
 */

/obj/item/storage/firstaid/attackby(var/obj/item/parts/robot_parts/S, mob/user as mob)
	if (!istype(S, /obj/item/parts/robot_parts/arm/))
		if (src.contents.len >= 7)
			return
		if ((S.w_class >= W_CLASS_SMALL || istype(S, /obj/item/storage)))
			if (!istype(S,/obj/item/storage/pill_bottle))
				boutput(user, "<span class='alert'>[S] won't fit into [src]!</span>")
				return
		..()
		return

	if (src.contents.len >= 1)
		boutput(user, "<span class='alert'>You need to empty [src] out first!</span>")
		return
	else
		var/obj/item/firstaid_arm_assembly/A = new /obj/item/firstaid_arm_assembly
		if (src.icon_state != "firstaid") // fart
			A.skin = src.icon_state // farto
/* all of this is kinda needlessly complicated imo
		if (istype(src, /obj/item/storage/firstaid/fire))
			A.skin = "ointment"
		else if (istype(src, /obj/item/storage/firstaid/toxin))
			A.skin = "tox"
		else if (istype(src, /obj/item/storage/firstaid/oxygen))
			A.skin = "o2"
		else if (istype(src, /obj/item/storage/firstaid/brain))
			A.skin = "red"
		else if (istype(src, /obj/item/storage/firstaid/brute))
			A.skin = "brute"
*/
		user.u_equip(S)
		user.put_in_hand_or_drop(A)
		boutput(user, "You add the robot arm to the first aid kit!")
		qdel(S)
		qdel(src)

/obj/item/firstaid_arm_assembly/attackby(obj/item/W, mob/user)
	if ((istype(W, /obj/item/device/analyzer/healthanalyzer)) && (!src.build_step))
		src.build_step++
		boutput(user, "You add the health sensor to [src]!")
		src.name = "First aid/robot arm/health analyzer assembly"
		src.overlays += "medibot-scanner"
		qdel(W)

	else if ((istype(W, /obj/item/device/prox_sensor)) && (src.build_step == 1))
		src.build_step++
		boutput(user, "You complete the Medibot! Beep boop.")
		var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot
		S.skin = src.skin
		S.set_loc(get_turf(src))
		S.name = src.created_name
		qdel(W)
		qdel(src)

	else if (istype(W, /obj/item/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as null|text
		if (!t)
			return
		if(t && t != src.name && t != src.created_name)
			phrase_log.log_phrase("bot-med", t)
		t = strip_html(replacetext(t, "'",""))
		t = copytext(t, 1, 45)
		if (!t)
			return
		if (!in_interact_range(src, user) && src.loc != user)
			return

		src.created_name = t

#undef MEDBOT_MOVE_SPEED
