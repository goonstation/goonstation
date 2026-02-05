TYPEINFO(/obj/machinery/clonepod)
	mats = list("metal" = 35,
				"honey" = 5)
/obj/machinery/clonepod
	anchored = ANCHORED
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0_lowmeat"
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	var/meat_used_per_tick = DEFAULT_MEAT_USED_PER_TICK
	var/mob/living/carbon/human/occupant
	var/heal_level = 10 //The clone is released once its health^W damage (maxHP - HP) reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 // Are we cloning an actual person now?
	var/time_started = 0 // When did we start cloning the actual person?
	var/operating = 0 // Are we creating a new body?
	var/eject_wait = 0 // How long do we wait until we eject them?
	var/previous_heal = 0
	var/portable = 0 //Are we part of a port-a-clone?
	var/id = null
	var/emagged = FALSE

	var/clonehack = 0 //Is a traitor mindhacking the clones?
	var/datum/mind/implant_hacker = null // Who controls the clones?
	var/is_speedy = 0 // Speed module installed?
	var/is_efficient = 0 // Efficiency module installed?

	var/gen_bonus = 1 //Normal generation speed
	var/speed_bonus = DEFAULT_SPEED_BONUS // Multiplier that can be modified by modules
	var/auto_mode = 1
	var/auto_delay = 10

	power_usage = 200

	var/failed_tick_counter = 0 // goes up while someone is stuck in there and there's not enough meat to clone them, after so many ticks they'll get dumped out

	var/message = null
	var/list/mailgroups
	var/net_id = null
	var/pdafrequency = FREQ_PDA

	var/datum/light/light

	var/meat_level = MAXIMUM_MEAT_LEVEL / 4
	///Total meat used to grow the current clone
	var/meat_used

	var/static/list/clonepod_accepted_reagents = list("blood"=0.5,"synthflesh"=1,"beff"=0.75,"pepperoni"=0.5,"meat_slurry"=1,"bloodc"=0.5)

	// Copied from manufacturer.dm, except -- get this -- used for functioning, not MALfunctioning. wow.
	var/static/list/sounds_function = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg')

	var/perfect_clone = FALSE		//if TRUE, then clones always keep normal name and receive no health debuffs

	New()
		..()
		req_access = list(access_medical_lockers) //For premature unlocking.
		mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH)

		src.create_reagents(100)

		src.UpdateIcon()
		genResearch.clonepods.Add(src) //This will be used for genetics bonuses when cloning

		light = new /datum/light/point
		light.set_brightness(1)
		light.set_color(1.0,0.1,0.1)
		light.set_height(0.75)
		light.attach(src)

		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, "pda", FREQ_PDA)


	disposing()
		message_ghosts("<b>[src]</b> has been destroyed at [log_loc(src, ghostjump=TRUE)].")
		mailgroups.len = 0
		genResearch?.clonepods?.Remove(src) //Bye bye
		connected?.linked_pods -= src
		if(connected?.scanner?.pods)
			connected?.scanner?.pods -= src
		connected = null
		occupant?.set_loc(get_turf(src.loc))
		occupant = null
		..()

	was_deconstructed_to_frame(mob/user)
		. = ..()
		connected?.linked_pods -= src
		if(connected?.scanner?.pods)
			connected?.scanner?.pods -= src
		connected = null

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		meat_level = 0 // no meat for those built from frames

		for (var/obj/machinery/computer/cloning/C in orange(4, src))
			if (length(C.linked_pods) < C.max_pods)
				C.linked_pods += src
				if(C.scanner?.pods)
					C.scanner?.pods += src
				src.connected = C
				break

	proc/send_pda_message(var/msg)
		if (!msg && src.message)
			msg = src.message
		else if (!msg)
			return

		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = "CLONEPOD-MAILBOT"
		newsignal.data["message"] = "[msg]"

		newsignal.data["address_1"] = "00000000"
		if(src.clonehack)
			newsignal.data["group"] = list(MGA_SYNDICATE)
		else
			newsignal.data["group"] = mailgroups + MGA_CLONER
		newsignal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "pda")

	attack_hand(mob/user)
		interact_particle(user, src)
		src.examine(user)

	get_desc(dist, mob/user)
		. = ""
		if ((!isnull(src.occupant)) && (!isdead(src.occupant)))
			//var/completion = (100 * ((src.occupant.health + 100) / (src.heal_level + 100)))
			. += "<br>Currently [!src.attempting ? "preparing a new body" : "cloning [src.occupant]"]. [src.get_progress()]% complete."

		var/meat_pct = round( 100 * (src.meat_level / MAXIMUM_MEAT_LEVEL) )

		if (src.meat_level <= 1)
			. += "<br>[SPAN_ALERT("Alert: Biomatter reserves depleted.")]"
		else if (src.meat_level <= MEAT_LOW_LEVEL)
			. += "<br>[SPAN_ALERT("Alert: Biomatter reserves are low ([meat_pct]% full).")]"
		else
			. += "<br>Biomatter reserves are [meat_pct]% full."

	is_open_container()
		return 2

	update_icon()
		if (src.portable) // no need here
			return
		if (src.mess)
			src.icon_state = "pod_g"
		else
			src.icon_state = "pod_[src.occupant ? "1" : "0"][src.meat_level ? "" : "_lowmeat"][src.clonehack ? "_mindhack" : "" ][src.connected?.mindwipe ? "_mindwipe" : ""]"


	proc/start_clone(force = 0)
		// Returns 1 if we started a clone or 0 if we couldn't due to meat reasons

		// Reset the time until the next automatic start.
		src.auto_delay = initial(src.auto_delay)

		if (src.occupant)
			// If we already have an occupant then we don't really need to start it, do we?
			return 1
		if ((force && src.meat_level < MEAT_NEEDED_TO_CLONE) || (!force && src.meat_level < initial(meat_level)))
			// Don't actually start cloning if we don't have enough meat.
			// For forced clones, this is the minimum needed to start (as usual)
			// For auto-generated clones, it's the initial meat level (25%)
			// Reason? Mostly just keeping it from beeping about low biomatter...
			return 0

		// Create a new human and grow it while we wait for a mind
		src.occupant = new /mob/living/carbon/human/clone(src)
		src.UpdateIcon()

		//Get the clone body ready. They start out with a bunch of damage right off.
		// changing this to takedamage which should hopefully apply it right away
		// SPAWN(0.5 SECONDS) //Organs may not exist yet if we call this right away.
		// 	random_brute_damage(src.occupant, 90, 1)
		src.occupant.TakeDamage("chest", 90, 0, 0, DAMAGE_BLUNT)

		src.occupant.take_toxin_damage(50)
		src.occupant.take_oxygen_deprivation(40)
		src.occupant.take_brain_damage(60)

		//Here let's calculate their health so the pod doesn't immediately eject them!!!
		src.occupant.health = (src.occupant.get_brute_damage() + src.occupant.get_toxin_damage() + src.occupant.get_oxygen_deprivation())

		src.operating = 1
		src.locked = 1
		src.gen_bonus = src.healing_multiplier()

		src.use_power(5000)

		return 1


	// Start cloning someone (transferring mind + DNA into new body),
	// starting a new clone cycle if needed
	// Returns 1 (stated) or 0 (failed to start for some reason)
	proc/growclone(mob/ghost as mob, var/clonename, var/datum/mind/mindref, var/datum/bioHolder/oldholder, var/datum/abilityHolder/oldabilities, var/datum/traitHolder/traits, var/datum/cloner_defect_holder/defects)
		if (((!ghost) || (!ghost.client)) || src.mess || src.attempting)
			return 0

		if (ghost.mind.get_player()?.dnr)
			src.connected_message("Ephemereal conscience detected, seance protocols reveal this corpse cannot be cloned.", "warning")
			return 0

		//if (src.meat_level < MEAT_NEEDED_TO_CLONE)
		if (!src.start_clone(1))
			src.connected_message("Insufficient biomatter to begin.", "warning")
			return 0

		src.attempting = 1 //One at a time!!
		src.time_started = TIME
		src.failed_tick_counter = 0 // make sure we start here

		src.look_busy(1)
		src.visible_message(SPAN_ALERT("[src] whirrs and starts up!"))

		src.eject_wait = 10 SECONDS

#ifdef DATALOGGER
		game_stats.Increment("clones")
#endif

		if (istype(oldholder))
			oldholder.clone_generation++
			src.occupant.bioHolder.CopyOther(oldholder, copyActiveEffects = connected?.gen_analysis)
			src.occupant?.set_mutantrace(oldholder?.mobAppearance?.mutant_race?.type)
			src.occupant?.set_mutantrace(oldholder?.mobAppearance?.original_mutant_race?.type)
			oldholder.mobAppearance?.mutant_race = oldholder.mobAppearance?.original_mutant_race
			if(ishuman(src.occupant))
				var/mob/living/carbon/human/H = src.occupant
				H.update_colorful_parts()
		else
			logTheThing(LOG_DEBUG, null, "<b>Cloning:</b> growclone([english_list(args)]) with invalid holder.")

		if (istype(oldabilities))
			oldabilities.on_clone()
			src.occupant.abilityHolder = oldabilities // This should already be a copy.
			src.occupant.abilityHolder.transferOwnership(src.occupant) //mbc : fixed clone removing abilities bug!
			src.occupant.abilityHolder.remove_unlocks()

		ghost.mind.transfer_to(src.occupant)
		src.occupant.is_npc = FALSE
		spawn_rules_controller.apply_to(src.occupant)
		if (!defects)
			stack_trace("Clone [identify_object(src.occupant)] generating with a null `defects` holder.")
			defects = new /datum/cloner_defect_holder

		// Little weird- we only want to apply cloner defects after they're ejected, so we apply it as soon as they change loc instead of right now
		defects.apply_to_on_move(src.occupant)

		if (!src.clonehack && !src.perfect_clone) // syndies and pod wars people get good clones
			/* Apply clone defects, number picked from a uniform distribution on
			 * [floor(clone_generation/2), clone generation], or [floor(clone_generation), clone generation * 2] if emagged.
			 * (Clone generation is the number of times a person has been cloned)
			 */
			var/generation = src.occupant.bioHolder.clone_generation
			for (var/i in 1 to rand(round(generation / 2)  * (src.emagged ? 2 : 1), (generation * (src.emagged ? 2 : 1))))
				if ((generation > 1) || traits.hasTrait("defect_prone"))
					defects.add_random_cloner_defect()
				else
					// First cloning can't get major defects
					defects.add_random_cloner_defect(CLONER_DEFECT_SEVERITY_MINOR)

			if (traits.hasTrait("defect_prone"))
				defects.add_random_cloner_defect()

		src.mess = FALSE
		var/is_puritan = FALSE
		if (!isnull(traits) && src.occupant.traitHolder)
			traits.copy_to(src.occupant.traitHolder)


			#ifndef MAP_OVERRIDE_POD_WARS
			if(src.occupant.traitHolder.hasTrait("puritan"))
				is_puritan = TRUE

			for (var/trait as anything in src.occupant?.client.preferences.traitPreferences.traits_selected)
				if(trait == "puritan")
					is_puritan = TRUE

			if (is_puritan)
				if (clonehack) // If mindhack cloner, bypass puritan stuff.
					boutput(src.occupant, SPAN_NOTICE("<h3>The mindhack module has forced your body to adapt, bypassing your clone instability!</h3>"))
				else
					src.mess = TRUE
					// Puritans have a bad time.
					// This is a little different from how it was before:
					// - Immediately take 250 tox and 100 random brute
					// - Always get a major cloning defect
					// - 50% chance, per limb, to lose that limb
					// - enforced premature_clone, which gibs you on death
					// If you have a clone body that's been allowed to fully heal before
					// cloning a puritan, you have a sliiiiiiiiiiight chance to get them
					// out of deep critical health before they turn into chunky salsa
					// This should be really rare to have happen, but I want to leave it in
					// just in case someone manages to pull off a miracle save
					defects.add_random_cloner_defect(CLONER_DEFECT_SEVERITY_MAJOR)
					src.occupant.bioHolder?.AddEffect("premature_clone")
					src.occupant.take_toxin_damage(350)
					APPLY_ATOM_PROPERTY(src.occupant, PROP_HUMAN_DROP_BRAIN_ON_GIB, "puritan")
					random_brute_damage(src.occupant, 200, 0)
					if (ishuman(src.occupant))
						var/mob/living/carbon/human/P = src.occupant
						if (P.limbs)
							var/list/limbs = list("l_arm", "r_arm", "l_leg", "r_leg")
							for (var/limb in limbs)
								if (prob(50))
									P.limbs.sever(limb)
			#endif

		if (length(defects.active_cloner_defects) > 7)
			src.occupant.unlock_medal("Quit Cloning Around")

		if (src.mess)
			boutput(src.occupant, "[SPAN_NOTICE("<b>Clone generation process initi&mdash;</b>")][SPAN_ALERT(" oh fuck oh god oh no no NO <b>NO NO THIS IS NOT GOOD</b>")]")
		else
			boutput(src.occupant, SPAN_NOTICE("<b>Clone generation process initiated.</b> This might take a moment, please hold."))
		if (!clonename)
			clonename = oldholder?.ownerName
		if (clonename)
			if (!src.perfect_clone && prob(15))
				src.occupant.real_name = "[pick("Almost", "Sorta", "Mostly", "Kinda", "Nearly", "Pretty Much", "Roughly", "Not Quite", "Just About", "Something Resembling", "Somewhat")] [clonename]"
			else
				src.occupant.real_name = clonename
		else
			src.occupant.real_name = "clone"  //No null names!!
		src.occupant.name = src.occupant.real_name
		if (is_puritan)
			message_ghosts("<b>[src.occupant]</b> is being cloned as a puritan at [log_loc(src, ghostjump=TRUE)].")
		if (!((mindref) && (istype(mindref))))
			logTheThing(LOG_DEBUG, null, "<b>Mind</b> Clonepod forced to create new mind for key \[[src.occupant.key ? src.occupant.key : "INVALID KEY"]]")
			src.occupant.mind = new /datum/mind(  )
			src.occupant.mind.ckey = src.occupant.ckey
			src.occupant.mind.key = src.occupant.key
			src.occupant.mind.transfer_to(src.occupant)
			ticker.minds += src.occupant.mind

		src.occupant.is_npc = FALSE
		logTheThing(LOG_STATION, usr, "starts cloning [constructTarget(src.occupant,"combat")] at [log_loc(src)].")

		if (isobserver(ghost))
			qdel(ghost) //Don't leave ghosts everywhere!!

		if (src.reagents && src.reagents.total_volume)
			src.reagents.reaction(src.occupant, INGEST, 1000)
			src.reagents.trans_to(src.occupant, 1000)

			// Oh boy someone is cloning themselves up an army!
		if(clonehack && implant_hacker)
			// No need to check near as much with a standard implant, as the cloned person is dead and is therefore enslavable upon cloning.
			// How did this happen. Why is someone cloning you as a mindhack to yourself. WHO KNOWS?!
			if(implant_hacker == src.occupant.mind)
				boutput(src.occupant, SPAN_ALERT("You feel utterly strengthened in your resolve! You are the most important person in the universe!"))
			else
				logTheThing(LOG_COMBAT, src.occupant, "was mindhack cloned. Mindhacker: [constructTarget(implant_hacker.current,"combat")]")
				src.occupant.setStatus("mindhack", null, implant_hacker.current)

		if (!src.occupant?.mind)
			logTheThing(LOG_DEBUG, src, "Cloning pod failed to check mind status of occupant [src.occupant].")
		else
			src.occupant.job = src.occupant.mind.assigned_role //Set the new mob's job to our mind's job
			for (var/datum/antagonist/antag in src.occupant.mind.antagonists)
				if (!antag.remove_on_clone)
					continue
				var/success = src.occupant.mind.remove_antagonist(antag)
				if (success)
					logTheThing(LOG_COMBAT, src.occupant, "Cloning pod removed [antag.display_name] antag status.")
				else
					logTheThing(LOG_DEBUG, src, "Cloning pod failed to remove [antag.display_name] antag status from [src.occupant] with return code [success].")

		// Someone is having their brain zapped. 75% chance of them being de-antagged if they were one
		//MBC todo : logging. This shouldn't be an issue thoug because the mindwipe doesn't even appear ingame (yet?)
		if(src.connected?.mindwipe)
			if(prob(75))
				src.occupant.show_antag_popup("mindwipe")
				boutput(src.occupant, SPAN_ALERT("<h2>You have awakened with a new outlook on life!</h2>"))
				src.occupant.mind.memory = "You cannot seem to remember much from before you were cloned. Weird!<BR>"
			else
				boutput(src.occupant, SPAN_ALERT("You feel your memories fading away, but you manage to hang on to them!"))
		// Lucky person - they get a power on cloning!
		if (src.connected?.BE)
			src.occupant.bioHolder.AddEffectInstance(src.connected.BE,1)

		if (!is_puritan)
			src.occupant.changeStatus("unconscious", 10 SECONDS)
		previous_heal = src.occupant.health
#ifdef CLONING_IS_INSTANT
		src.occupant.full_heal()
#endif
		return 1


	// Grow clones to maturity then kick them out when they're done.  FREELOADERS
	process(mult)
		/*
		if (src.occupant && src.attempting && src.meat_level)
			power_usage = 7500
		else
			power_usage = 200
		..()
		*/

		if (status & NOPOWER)
			if (src.occupant && (src.attempting || isdead(src.occupant)))
				// Autoeject if power is lost and we're cloning an actual person,
				// or the clone is dead (e.g. if a clone starts and power dies immediately)
				src.go_out(1)
				power_usage = 200
			return ..()

		if (src.occupant && src.occupant.loc == src)
			// If we have a body inside the pod right now...

			if (src.occupant.traitHolder && src.occupant.traitHolder.hasTrait("puritan"))
				// puritans get punted out immediately
				src.go_out(1)
				src.connected_message("Clone Aborted: Genetic Structure Incompatible.", "warning")
				src.send_pda_message("Clone Aborted: Genetic Structure Incompatible")
				power_usage = 200
				return ..()

			if (src.clonehack == 1 && prob(10))
				// Mindhack cloning modules make obnoxious noises.
				playsound(src.loc, pick('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg',
				'sound/machines/genetics.ogg','sound/machines/shieldoverload.ogg'), 50, 1)

			if (isdead(src.occupant) || src.occupant.suiciding)  //Autoeject corpses and suiciding dudes.
				// Dead or suiciding people are ejected.
				src.go_out(1)
				src.connected_message("Clone Rejected: Deceased.", "danger")
				src.send_pda_message("Clone Rejected: Deceased")
				power_usage = 200
				return ..()

			else if (src.failed_tick_counter >= MAX_FAILED_CLONE_TICKS) // you been in there too long, get out
				// If we've failed to progress the clone for a while, they get ejected too.
				src.go_out(1)
				src.connected_message("Clone Ejected: Low Biomatter.", "danger")
				src.send_pda_message("Clone Ejected: Low Biomatter")
				power_usage = 200
				return ..()

			else if (!src.meat_level)
				// If we lack more meat to continue cloning, then...
				if (src.attempting)
					// ... if someone's in this body, start the timer.
					// If it's a pre-clone body, it can just stay in here
					src.failed_tick_counter++
					if (src.failed_tick_counter == (MAX_FAILED_CLONE_TICKS / 2)) // halfway to ejection
						src.send_pda_message("Low Biomatter: Preparing to Eject Clone")
				src.UpdateIcon()
				power_usage = 200
				return ..()

			else if (src.get_progress() < 100)

				if (src.attempting)
					// If we're cloning an actual person, make weird noises
					src.look_busy(prob(33))

				// Otherwise, heal thyself, clone.
				src.occupant.changeStatus("unconscious", 10 SECONDS)

				// Slowly get that clone healed and finished.
				//At this rate one clone takes about 95 seconds to produce.
				src.occupant.HealDamage("All", 1 * gen_bonus * mult, 1 * gen_bonus * mult)
				src.occupant.take_toxin_damage(-1 * gen_bonus * mult)

				//Premature clones may have brain damage.
				src.occupant.take_brain_damage(-2 * gen_bonus * mult)

				//So clones don't die of oxy damage in a running pod.
				if (src.occupant.reagents.get_reagent_amount("perfluorodecalin") < 6)
					src.occupant.reagents.add_reagent("perfluorodecalin", 2 * mult)

				if (src.occupant.reagents.get_reagent_amount("epinephrine") < 8)
					src.occupant.reagents.add_reagent("epinephrine", 4 * mult)

				if (src.occupant.reagents.get_reagent_amount("saline") < 10)
					src.occupant.reagents.add_reagent("saline", 4 * mult)

				if (src.occupant.reagents.get_reagent_amount("synthflesh") < 50)
					src.occupant.reagents.add_reagent("synthflesh", 10 * mult)

				if (src.occupant.reagents.get_reagent_amount("mannitol") < 6)
					src.occupant.reagents.add_reagent("mannitol", 2 * mult)

				//Also heal some oxy ourselves because epinephrine is so bad at preventing it!!
				src.occupant.take_oxygen_deprivation(-10 * mult) // cogwerks: speeding this up too

				var/old_level = src.meat_level
				src.meat_level = max( 0, src.meat_level - meat_used_per_tick * mult )
				src.meat_used += old_level - src.meat_level //delta meat

				if (!src.meat_level)
					src.connected_message("Additional biomatter required to continue.", "warning")
					src.send_pda_message("Low Biomatter")
					src.visible_message(SPAN_ALERT("[src] emits an urgent boop!"))
					playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
					src.failed_tick_counter = 1

				var/heal_delta = (src.occupant.health - previous_heal)
				if (heal_delta <= 0)
					src.failed_tick_counter++
				else
					src.failed_tick_counter = 0
				previous_heal = src.occupant.health

				if (src.get_progress() > 50 && src.failed_tick_counter >= 2 && (src.time_started + eject_wait < TIME))
					// Wait a few ticks to see if they stop gaining health.
					// Once that's the case, boot em
					src.connected_message("Cloning Process Complete.", "success")
					src.send_pda_message("Cloning Process Complete")
					src.go_out(1)
				else // go_out() updates icon too, so vOv
					src.UpdateIcon()

				power_usage = 7500
				return ..()

			else if (src.get_progress() >= 100)
				// Clone is more or less fully complete!

				if (src.attempting && (src.time_started + eject_wait < TIME))
					// If this body has an actual mind in it, they're done.
					// Sure hope the outside is safe for ya.
					src.connected_message("Cloning Process Complete.", "success")
					src.send_pda_message("Cloning Process Complete")
					// literally ding like a microwave
					playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
					look_busy()
					src.go_out(1)
				else
					// Clones that are idling get some freebies to keep them topped up
					// until an actual person moves in
					if (src.occupant.reagents.get_reagent_amount("salbutamol") < 2)
						src.occupant.reagents.add_reagent("salbutamol", 2)
					src.occupant.take_oxygen_deprivation(-10)
					src.occupant.losebreath = 0

				power_usage = 200
				return ..()

		else
			src.occupant = null
			src.operating = 0
			src.attempting = 0
			src.failed_tick_counter = 0
			src.locked = 0
			if (!src.mess)
				src.UpdateIcon()
			power_usage = 200


			#ifndef CLONING_IS_A_SIN
			if (!src.operating && src.auto_mode)
				// Attempt to start a new clone (if possible)
				src.auto_delay -= mult
				if (src.auto_delay < 0)
					src.start_clone()
			#endif

			return ..()

		return ..()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.emagged = TRUE
		if (isnull(src.occupant))
			return 0
		if (user)
			boutput(user, "You force an emergency ejection.")
		logTheThing(LOG_STATION, src, "[key_name(src.occupant)] was ejected from [src] being emagged by [key_name(user)]!")
		src.go_out(1)
		return 1

	//Let's unlock this early I guess.
	attackby(obj/item/W, mob/user)
		var/obj/item/card/id/id_card = get_id_card(W)
		if (istype(id_card))
			W = id_card
		if (istype(W, /obj/item/card/id))
			if (!src.check_access(W))
				boutput(user, SPAN_ALERT("Access Denied."))
				return
			if ((!src.locked) || (isnull(src.occupant)))
				return
			if ((src.occupant.health < -20) && (!isdead(src.occupant)))
				boutput(user, SPAN_ALERT("Access Refused."))
				return
			else
				src.locked = 0
				boutput(user, "System unlocked.")
		else if (istype(W, /obj/item/card/emag))	//This is needed to suppress the SYNDI CAT HITS CLONING POD message *cry
			return
		else if (istype(W, /obj/item/reagent_containers/glass))
			return
		else if (istype(W, /obj/item/cloneModule/speedyclone)) // speed module
			if (is_speedy)
				boutput(user,SPAN_ALERT("There's already a speed booster in the slot!"))
				return
			if (operating && attempting)
				boutput(user,SPAN_ALERT("The cloning pod emits an angry boop!"))
				return
			user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			logTheThing(LOG_STATION, user, "installed ([W]) to ([src]) at [log_loc(user)].")
			speed_bonus *= SPEEDY_MODULE_SPEED_MULT
			meat_used_per_tick *= SPEEDY_MODULE_MEAT_MULT
			is_speedy = 1
			user.drop_item()
			qdel(W)
			return

		else if (istype(W, /obj/item/cloneModule/efficientclone)) // efficiency module
			if (is_efficient)
				boutput(user,SPAN_ALERT("There's already an efficiency booster in the slot!"))
				return
			if (operating && attempting)
				boutput(user,SPAN_ALERT("The cloning pod emits a[pick("n angry", " grumpy", "n annoyed", " cheeky")] [pick("boop","bop", "beep", "blorp", "burp")]!"))
				return
			user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			logTheThing(LOG_STATION, user, "installed ([W]) to ([src]) at [log_loc(user)].")
			meat_used_per_tick *= EFFICIENCY_MODULE_MEAT_MULT
			is_efficient = 1
			user.drop_item()
			qdel(W)
			return

		else if (istype(W, /obj/item/cloneModule/mindhack_module)) // Time to re enact the clone wars
			if (operating && attempting)
				boutput(user,SPAN_ALERT("The cloning pod emits a[pick("n angry", " grumpy", "n annoyed", " cheeky")] [pick("boop","bop", "beep", "blorp", "burp")]!"))
				return
			logTheThing(LOG_STATION, user, "installed ([W]) to ([src]) at [log_loc(user)].")
			clonehack = 1
			implant_hacker = user.mind
			light.enable()
			src.UpdateIcon()
			user.drop_item()
			qdel(W)
			return

		else if(isscrewingtool(W) && clonehack) // Wait nevermind the clone wars were a terrible idea
			if (src.occupant && src.attempting)
				boutput(user, "<space class='alert'>You must wait for the current cloning cycle to finish before you can remove the mindhack module.</span>")
				return
			boutput(user, SPAN_NOTICE("You begin detatching the mindhack cloning module..."))
			logTheThing(LOG_STATION, user, "removed the mindhack cloning module from ([src]) at [log_loc(user)].")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			SETUP_GENERIC_PRIVATE_ACTIONBAR(user, src, 5 SECONDS, PROC_REF(remove_mindhack_module), list(user), W.icon, W.icon_state, null, INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_MOVE | INTERRUPT_ATTACKED)
			return

		else if (ispryingtool(W) && (src.is_speedy || src.is_efficient))
			if (src.occupant && src.attempting)
				boutput(user, "<space class='alert'>You must wait for the current cloning cycle to finish before you can remove upgrade modules.</span>")
				return
			user.visible_message(SPAN_NOTICE("[user] starts removing the upgrade modules."))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, PROC_REF(remove_upgrade_modules), list(user), W.icon, W.icon_state, null, INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_MOVE | INTERRUPT_ATTACKED)
		else
			..()

	proc/remove_mindhack_module(mob/user)
		// someone else removed it before us
		if(!src.clonehack)
			return
		new /obj/item/cloneModule/mindhack_module(src.loc)
		src.clonehack = FALSE
		src.implant_hacker = null
		boutput(user, SPAN_ALERT("The mindhack cloning module falls to the floor!"))
		playsound(src.loc, 'sound/effects/pop.ogg', 80, FALSE)
		src.light.disable()
		src.UpdateIcon()

	proc/remove_upgrade_modules(mob/user)
		var/removed_module = FALSE
		if (src.is_speedy)
			src.is_speedy = FALSE
			removed_module = TRUE
			src.speed_bonus /= SPEEDY_MODULE_SPEED_MULT
			src.meat_used_per_tick /= SPEEDY_MODULE_MEAT_MULT
			var/obj/speedy = new /obj/item/cloneModule/speedyclone(src.loc)
			src.visible_message(SPAN_ALERT("The [speedy] module falls to the floor!"))
		if (src.is_efficient)
			src.is_efficient = FALSE
			removed_module = TRUE
			src.meat_used_per_tick /= EFFICIENCY_MODULE_MEAT_MULT
			var/obj/efficient = new /obj/item/cloneModule/efficientclone(src.loc)
			src.visible_message(SPAN_ALERT("The [efficient] module falls to the floor!"))
			playsound(src.loc, 'sound/effects/pop.ogg', 80, FALSE)
		if(removed_module)
			playsound(src.loc, 'sound/effects/pop.ogg', 80, FALSE)
		src.UpdateIcon()

	on_reagent_change()
		..()
		for(var/reagent_id in src.reagents.reagent_list)
			if (reagent_id in clonepod_accepted_reagents)
				var/datum/reagent/theReagent = src.reagents.reagent_list[reagent_id]
				if (theReagent)
					src.meat_level = min(src.meat_level + (theReagent.volume * clonepod_accepted_reagents[reagent_id]), MAXIMUM_MEAT_LEVEL)
					src.reagents.del_reagent(reagent_id)

		if (src.occupant)
			src.reagents.reaction(src.occupant, INGEST, 1000)
			src.reagents.trans_to(src.occupant, 1000)

	//Put messages in the connected computer's temp var for display.
	proc/connected_message(var/message, status)
		if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
			return 0
		if (!message)
			return 0
		src.connected.currentStatusMessage["text"] = message
		src.connected.currentStatusMessage["status"] = status
		tgui_process.update_uis(src)
		SPAWN(5 SECONDS)
			if(src?.connected.currentStatusMessage == message)
				src.connected.currentStatusMessage["text"] = ""
				src.connected.currentStatusMessage["status"] = ""
				tgui_process.update_uis(src)

	verb/eject()
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr) || iswraith(usr))
			return
		var/mob/occupant = src.occupant
		if (src.go_out())
			logTheThing(LOG_STATION, src, "[key_name(occupant)] was ejected from [src] by [key_name(usr)]")
		add_fingerprint(usr)
		return

	verb/toggle_auto()
		set src in oview(1)
		set name = "Toggle Auto Mode"
		set category = "Local"

		if (!isalive(usr) && !isAIeye(usr))
			return
		src.auto_mode = 1 - src.auto_mode
		boutput(usr, SPAN_NOTICE("\The [src] will [src.auto_mode ? "automatically" : "no longer"] automatically prepare new bodies for clones."))
		add_fingerprint(usr)
		return

	proc/go_out(unlock = 0)
		if (unlock)
			src.locked = 0
		else if (src.locked)
			return

		src.failed_tick_counter = 0
		src.eject_wait = 0 // Set eject_wait back to 0
		src.operating = 0
		src.attempting = 0

		if (!src.occupant)
			src.occupant = locate(/mob) in src
		if (!src.occupant)
			return

		if ((src.occupant.max_health - src.occupant.health) > (heal_level + 30) && src.occupant.bioHolder)
			// this seems to often not work right, changing 20 to 50
			// changing to 30 and rewriting to consider the /damage/ someone has;
			// max_health can vary depending on other
			src.occupant.bioHolder.AddEffect("premature_clone")

		if (src.meat_used < MINIMUM_MEAT_USED) //always make sure we use at least SOME meat
			src.meat_level = max(0, src.meat_level - (MINIMUM_MEAT_USED - src.meat_used))

		if (src.mess) //Clean that mess and dump those gibs!
			src.mess = 0
			gibs(get_turf(src)) // we don't need to do if/else things just to say "put gibs on this thing's turf"
			for (var/obj/O in src)
				O.set_loc(get_turf(src))
				if (prob(33))
					step_rand(O) // cogwerks - let's spread that mess instead of having a pile! bahaha
			if (src.occupant)
				src.occupant.set_loc(get_turf(src))
				. = TRUE
				src.occupant = null
			src.UpdateIcon()
			return

		if (!src.occupant)
			return

		for (var/obj/O in src)
			O.set_loc(get_turf(src))

		if (src.occupant.get_oxygen_deprivation())
			src.occupant.take_oxygen_deprivation(-INFINITY)

		if (src.occupant.losebreath) // STOP FUCKING SUFFOCATING GOD DAMN
			src.occupant.losebreath = 0

		if (iscarbon(src.occupant))
			var/mob/living/carbon/C = src.occupant
			C.remove_ailments() // no more cloning with heart failure

		src.occupant.changeStatus("unconscious", 10 SECONDS)
		src.occupant.set_loc(get_turf(src))
		. = TRUE
		if (src.emagged) //huck em
			src.occupant.throw_at(get_edge_target_turf(src, pick(alldirs)), 10, 3)
		src.occupant = null
		src.UpdateIcon()

	proc/malfunction()
		if (src.occupant)
			src.connected_message("Critical Error!", "danger")
			src.send_pda_message("Critical Error")
			src.mess = 1
			src.failed_tick_counter = 0
			src.UpdateIcon()
			src.occupant.ghostize()
			SPAWN(0.5 SECONDS)
				qdel(src.occupant)
		return

	proc/operating_nominally()
		return operating && src.meat_level && connected?.gen_analysis //Only operate nominally for non-shit cloners

	proc/healing_multiplier()
		// effectively "speed_bonus" (cash-4-clones is never on)
		if (wagesystem.clones_for_cash)
			return 2 * speed_bonus
		else
			return speed_bonus

	relaymove(mob/user as mob)
		if (user.stat)
			return
		src.go_out()
		return

	Click(location, control, params)
		if(!src.ghost_observe_occupant(usr, src.occupant))
			. = ..()

	ex_act(severity)
		switch(severity)
			if(1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
			if(2)
				if (prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return
			if(3)
				if (prob(25))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return

	proc/look_busy(var/big = 0)
		if (big)
			animate_shake(src,5,rand(3,8),rand(3,8))
			playsound(src.loc, pick(src.sounds_function), 50, 2)
		else
			animate_shake(src,3,rand(1,4),rand(1,4))

	proc/get_progress()
		if (!src.occupant)
			return 0

		if (src.heal_level == 0)
			return 100

		return round(clamp(100 - ((src.occupant.max_health - src.occupant.health) - src.heal_level), 0, 100))

	//SOME SCRAPS I GUESS
	/* EMP grenade/spell effect
			if(istype(A, /obj/machinery/clonepod))
				A:malfunction()
	*/

