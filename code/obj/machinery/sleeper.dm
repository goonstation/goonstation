// Contains:
// - Sleeper control console
// - Sleeper
// - Portable sleeper (fake Port-a-Medbay)

// I overhauled the sleeper to make it a little more viable. Aside from being a saline dispenser,
// it was of practically no use to medical personnel and thus ignored in general. The current
// implemention is by no means a substitute for a doctor in the same way that a medibot isn't, but
// the sleeper should now be capable of keeping light-crit patients stabilized for a reasonable
// amount of time. I tried to ensure that, at the time of writing, the sleeper is neither under-
// or overpowered with regard to other methods of healing mobs (Convair880).

//////////////////////////////////////// Sleeper control console //////////////////////////////

/obj/machinery/sleep_console
	name = "sleeper console"
	desc = "A device that displays the vital signs of the occupant of the sleeper, and can dispense chemicals."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	anchored = 1
	density = 1
	mats = 8
	deconstruct_flags = DECON_CROWBAR | DECON_MULTITOOL
	var/timing = 0 // Timer running?
	var/time = null // In 1/10th seconds.
	var/time_started = 0 // TIME when the timer was started
	var/obj/machinery/sleeper/our_sleeper = null
	var/find_sleeper_in_range = 1
	// Capped at 3 min. Used to be 10 min, Christ.
	var/maximum_time = 3 MINUTES
	var/injection_delay = 5 SECONDS

	New()
		..()
		if (src.find_sleeper_in_range)
			SPAWN_DBG(0.5 SECONDS)
				our_sleeper = locate() in get_step(src,src.dir)
				if (!our_sleeper)
					our_sleeper = locate() in orange(src,1)
		else if (!our_sleeper && istype(src.loc, /obj/machinery/sleeper))
			our_sleeper = src.loc
		return

	ex_act(severity)
		switch (severity)
			if (1.0)
				qdel(src)
				return
			if (2.0)
				if (prob(50))
					qdel(src)
					return
			else
		return

	// Just relay emag_act() here.
	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.add_fingerprint(user)
		if (!src.our_sleeper)
			return 0
		switch (src.our_sleeper.emag_act(user, E))
			if (0) return 0
			if (1) return 1

	proc/wake_occupant()
		if (!src || !src.our_sleeper)
			return

		var/mob/occupant = src.our_sleeper.occupant
		if (ishuman(occupant))
			var/mob/living/carbon/human/O = occupant
			if (O.sleeping)
				O.sleeping = 3
				if (prob(5)) // Heh.
					boutput(O, "<span class='success'> [bicon(src)] Wake up, Neo...</span>")
				else
					boutput(O, "<span class='notice'> [bicon(src)] *beep* *beep*</span>")
			src.visible_message("<span class='notice'>The [src.name]'s occupant alarm clock dings!</span>")
			playsound(src.loc, "sound/machines/ding.ogg", 100, 1)
		return

	process()
		if (!src)
			return
		if (src.status & (NOPOWER|BROKEN))
			return
		if (!src.our_sleeper)
			src.time = 0
			src.timing = 0
			src.time_started = 0
			src.updateDialog()
			return
		if (src.timing)
			if ((src.time_started + src.time) > TIME) // is the time started plus the time we're set to greater than the current time? the mob hasn't waited long enough
				var/mob/occupant = src.our_sleeper.occupant
				if (occupant)
					if (ishuman(occupant))
						var/mob/living/carbon/human/O = occupant
						if (isdead(O))
							src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"Alert! No further life signs detected from occupant.\"")
							playsound(src.loc, "sound/machines/buzz-two.ogg", 100, 0)
							src.timing = 0
							src.time_started = 0
						else
							if (O.sleeping != 5)
								O.sleeping = 5
							src.our_sleeper.alter_health(O)
				else
					src.timing = 0
					src.time_started = 0
			else
				src.wake_occupant()
				src.time = 0
				src.timing = 0
				src.time_started = 0

			src.updateDialog()
		return

	// Makes sense, I suppose. They're on the shuttles too.
	powered()
		return

	use_power()
		return

	power_change()
		return

	ui_status(mob/user)
		var/use_obj = src
		if (src.loc == src.our_sleeper) // port-a-medbay
			use_obj = src.loc
			if (user in use_obj)
				return UI_CLOSE
		if (src.our_sleeper?.occupant == user)
			return UI_DISABLED
		return min(
			tgui_broken_state.can_use_topic(use_obj, user),
			tgui_default_state.can_use_topic(use_obj, user),
			tgui_not_incapacitated_state.can_use_topic(use_obj, user)
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		switch(action)
			if("timer")
				if (src.our_sleeper?.occupant && !isdead(src.our_sleeper.occupant))
					src.timing = !src.timing
					src.visible_message("<span class='notice'>[usr] [src.timing ? "sets" : "stops"] the [src]'s occupant alarm clock.</span>")
					if (src.timing)
						src.time_started = TIME
						// People do use sleepers for grief from time to time.
						logTheThing("station", usr, src.our_sleeper.occupant, "initiates a sleeper's timer ([src.our_sleeper.emagged ? "<b>EMAGGED</b>, " : ""][src.time/10] seconds), forcing [constructTarget(src.our_sleeper.occupant,"station")] asleep at [log_loc(src.our_sleeper)].")
					else
						src.time = clamp(src.time + src.time_started - TIME, 0, src.maximum_time)
						src.time_started = 0
						src.wake_occupant()
				. = TRUE
			if("time_add")
				if (src.our_sleeper && src.time <= src.maximum_time)
					var/t = params["tp"]
					if (t > 0 && src.timing && src.our_sleeper.occupant)
						// People do use sleepers for grief from time to time.
						logTheThing("station", usr, src.our_sleeper.occupant, "increases a sleeper's timer ([src.our_sleeper.emagged ? "<b>EMAGGED</b>, " : ""]occupied by [constructTarget(src.our_sleeper.occupant,"station")]) by [t] seconds at [log_loc(src.our_sleeper)].")
					src.time = clamp(src.time + (t*10), 0, src.maximum_time)
				. = TRUE
			if("inject")
				if (src.our_sleeper)
					var/is_recharging = src.our_sleeper.no_med_spam && world.time < src.our_sleeper.no_med_spam + src.injection_delay
					if (src.our_sleeper.occupant && !src.timing && !is_recharging)
						src.our_sleeper.inject(usr, TRUE)
				. = TRUE
			if("eject")
				if (src.our_sleeper?.occupant)
					src.our_sleeper.go_out()
				. = TRUE

	ui_data(mob/user)
		if (!src.our_sleeper)
			return list(
				"sleeperGone" = TRUE,
				"hasOccupant" = FALSE,
			)

		. = list(
			"sleeperGone" = FALSE,
			"hasOccupant" = FALSE,
			"rejuvinators" = list(),
			"recharging" = src.our_sleeper.no_med_spam && world.time < src.our_sleeper.no_med_spam + src.injection_delay,
			"isTiming" = src.timing,
			"time" = src.time,
			"timeStarted" = src.time_started,
			"timeNow" = TIME,
			"maxTime" = src.maximum_time,
		)

		var/mob/occupant = src.our_sleeper.occupant
		if (occupant)
			. += list(
				"hasOccupant" = TRUE,
				"occupantStat" = occupant.stat,
				"health" = occupant.health / occupant.max_health,
				"oxyDamage" = occupant.get_oxygen_deprivation(),
				"toxDamage" = occupant.get_toxin_damage(),
				"burnDamage" = occupant.get_burn_damage(),
				"bruteDamage" = occupant.get_brute_damage(),
			)

			// We don't have a fully-fledged reagent scanner built-in. Of course, this also means
			// we can't detect our own poisons if the sleeper's emagged. Too bad.
			for (var/R in occupant.reagents.reagent_list)
				var/datum/reagent/medical/MR = occupant.reagents.reagent_list[R]
				if (istype(MR))
					.["rejuvinators"] += list(list("name" = MR.name, "color" = rgb(MR.fluid_r, MR.fluid_g, MR.fluid_b), "volume" = MR.volume, "od" = MR.overdose))

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Sleeper", src.name)
			ui.open()

/obj/machinery/sleep_console/compact
	find_sleeper_in_range = 0

	portable
		name = "Port-A-Medbay console"


////////////////////////////////////////////// Sleeper ////////////////////////////////////////

/obj/machinery/sleeper
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"//_0"
	desc = "An enterable machine that analyzes and stabilizes the vital signs of the occupant."
	density = 1
	anchored = 1
	mats = 25
	deconstruct_flags = DECON_CROWBAR | DECON_WIRECUTTERS | DECON_MULTITOOL
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/mob/occupant = null
	var/image/image_lid = null
	var/obj/machinery/power/data_terminal/link = null
	var/net_id = null //net id for control over powernet

	var/obj/machinery/sleep_console/our_console = null // if portable this will be where the internal console is kept

	var/no_med_spam = 0 // In relation to world time.
	var/med_stabilizer = "saline" // Basic med that will always be injected.
	var/med_crit = "ephedrine" // If < -25 health.
	var/med_oxy = "salbutamol" // If > +15 OXY.
	var/med_tox = "charcoal" // If > +15 TOX.

	var/emagged = 0
	var/list/med_emag = list("sulfonal", "toxin", "mercury") // Picked at random per injection.

	var/damage_threshold = 15
	var/crit_threshold = -25
	var/timed_inject = 2
	var/maximum_reagent = 10
	var/inject_reagent = 5
	var/maximum_poison = 5
	var/inject_poison = 2.5

	New()
		..()
		src.update_icon()
		SPAWN_DBG(0.6 SECONDS)
			if (src && !src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if (test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src
			src.net_id = format_net_id("\ref[src]")

	disposing()
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	proc/update_icon()
		ENSURE_IMAGE(src.image_lid, src.icon, "sleeperlid[!isnull(occupant)]")
		src.UpdateOverlays(src.image_lid, "lid")
		return

	CanPass(atom/movable/O as mob|obj, target as turf, height=0, air_group=0)
		if (air_group || (height==0))
			return 1
		..()

	ex_act(severity)
		switch (severity)
			if (1.0)
				for (var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
			if (2.0)
				if (prob(50))
					for (var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return
			if (3.0)
				if (prob(25))
					for (var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return
		return

	// Let's get us some poisons.
	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.add_fingerprint(user)
		if (src.emagged == 1)
			return 0
		else
			src.emagged = 1
			if (user && ismob(user))
				user.show_text("You short out [src]'s reagent synthesis safety protocols.", "blue")
			src.visible_message("<span class='alert'><b>[src] buzzes oddly!</b></span>")
			logTheThing("station", user, src.occupant, "emags \a [src] [src.occupant ? "with [constructTarget(src.occupant,"station")] inside " : ""](setting it to inject poisons) at [log_loc(src)].")
			return 1

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair [src]'s reagent synthesis safety protocols.", "blue")
		src.emagged = 0
		return 1

	blob_act(var/power)
		if (prob(power * 3.75))
			for (var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				A.blob_act(power)
			qdel(src)
		return

	allow_drop()
		return 0

	attackby(obj/item/grab/G as obj, mob/user as mob)
		src.add_fingerprint(user)

		if (!istype(G) || !ishuman(G.affecting))
			..()
			return
		if (src.occupant)
			user.show_text("[src] is already occupied!", "red")
			return

		var/mob/living/carbon/human/H = G.affecting
		H.set_loc(src)
		src.occupant = H
		src.update_icon()
#ifdef DATALOGGER
		game_stats.Increment("sleeper")
#endif
		for (var/obj/O in src)
			if (O == src.our_console) // don't barf out the internal sleeper console tia
				continue
			O.set_loc(src.loc)
		qdel(G)
		playsound(src.loc, "sound/machines/sleeper_close.ogg", 30, 1)
		return

	// Makes sense, I suppose. They're on the shuttles too.
	powered()
		return

	use_power()
		return

	power_change()
		return

	// Called by sleeper console once per tick when occupant is asleep/hibernating.
	alter_health(var/mob/living/M as mob)
		if (!M || !isliving(M))
			return
		if (!ishuman(M))
			src.go_out() // stop turning into cyborgs inside sleepers thanks
		if (isdead(M))
			return

		var/injected_anything = FALSE

		// We always inject this, even when emagged to mask the fact we're malfunctioning.
		// Otherwise, one glance at the control console would be sufficient.
		if (M.reagents.get_reagent_amount(src.med_stabilizer) == 0)
			injected_anything = TRUE
			M.reagents.add_reagent(src.med_stabilizer, 2)

		// Why not, I guess? Might convince people to willingly enter hiberation, providing
		// traitorous MDs with a good opportunity to off somebody with an emagged sleeper.
		if (M.ailments)
			for (var/datum/ailment_data/D in M.ailments)
				if (istype(D.master, /datum/ailment/addiction))
					var/datum/ailment_data/addiction/A = D
					var/probability = 5
					if (world.timeofday > A.last_reagent_dose + 2.5 MINUTES)
						probability = 10
					if (prob(probability))
						//DEBUG_MESSAGE("Healed [M]'s [A.associated_reagent] addiction.")
						M.show_text("You no longer feel reliant on [A.associated_reagent]!", "blue")
						M.ailments -= A
						qdel(A)

		// No life-saving meds for you, buddy.
		if (src.emagged)
			var/our_poison = pick(src.med_emag)
			if (M.reagents.get_reagent_amount(our_poison) == 0)
				//DEBUG_MESSAGE("Injected occupant with [our_poison] at [log_loc(src)].")
				M.reagents.add_reagent(our_poison, timed_inject)
				// don't set injected_anything (the poison uses a sneaky silent injector)
		else
			if (M.health < crit_threshold && M.reagents.get_reagent_amount(src.med_crit) == 0)
				M.reagents.add_reagent(src.med_crit, src.timed_inject)
				injected_anything = TRUE
			if (M.get_oxygen_deprivation() >= src.damage_threshold && M.reagents.get_reagent_amount(src.med_oxy) == 0)
				M.reagents.add_reagent(src.med_oxy, src.timed_inject)
				injected_anything = TRUE
			if (M.get_toxin_damage() >= src.damage_threshold && M.reagents.get_reagent_amount(src.med_tox) == 0)
				M.reagents.add_reagent(src.med_tox, src.timed_inject)
				injected_anything = TRUE

		if (injected_anything)
			playsound(src.loc, "sound/items/hypo.ogg", 25, 1)

		src.no_med_spam = world.time // So they can't combine this with manual injections.
		return

	// Called by sleeper console when injecting stuff manually.
	proc/inject(mob/user_feedback as mob, var/manual_injection = 0)
		if (!src)
			return
		if (src.occupant)
			if (isdead(src.occupant))
				if (user_feedback && ismob(user_feedback))
					user_feedback.show_text("The occupant is dead.", "red")
				return
			if (src.no_med_spam && world.time < src.no_med_spam + 50)
				if (user_feedback && ismob(user_feedback))
					user_feedback.show_text("The reagent synthesizer is recharging.", "red")
				return

			var/crit = src.occupant.reagents.get_reagent_amount(src.med_crit)
			var/rejuv = src.occupant.reagents.get_reagent_amount(src.med_stabilizer)
			var/oxy = src.occupant.reagents.get_reagent_amount(src.med_oxy)
			var/tox = src.occupant.reagents.get_reagent_amount(src.med_tox)

			var/injected_anything = FALSE

			// We always inject this, even when emagged to mask the fact we're malfunctioning.
			// Otherwise, one glance at the control console would be sufficient.
			if (rejuv < src.maximum_reagent)
				var/inject_r = src.inject_reagent
				if ((rejuv + inject_r) > src.maximum_reagent)
					inject_r = max(0, (src.maximum_reagent - rejuv))
				src.occupant.reagents.add_reagent(src.med_stabilizer, inject_r)
				injected_anything = TRUE

			// No life-saving meds for you, buddy.
			if (src.emagged)
				var/our_poison = pick(src.med_emag)
				var/poison = src.occupant.reagents.get_reagent_amount(our_poison)
				if (poison < src.maximum_poison)
					var/inject_p = src.inject_poison
					if ((poison + inject_p) > src.maximum_poison)
						inject_p = max(0, (src.inject_poison - poison))
					src.occupant.reagents.add_reagent(our_poison, inject_p)
					// don't set injected_anything (the poison uses a sneaky silent injector)
					//DEBUG_MESSAGE("Injected occupant with [inject_p] units of [our_poison] at [log_loc(src)].")
					if (manual_injection == 1)
						logTheThing("station", user_feedback, src.occupant, "manually injects [constructTarget(src.occupant,"station")] with [our_poison] ([inject_p]) from an emagged sleeper at [log_loc(src)].")
			else
				if (src.occupant.health < src.crit_threshold && crit < src.maximum_reagent)
					var/inject_c = src.inject_reagent
					if ((crit + inject_c) > src.maximum_reagent)
						inject_c = max(0, (src.maximum_reagent - crit))
					src.occupant.reagents.add_reagent(src.med_crit, inject_c)
					injected_anything = TRUE

				if (src.occupant.get_oxygen_deprivation() >= src.damage_threshold && oxy < src.maximum_reagent)
					var/inject_o = src.inject_reagent
					if ((oxy + inject_o) > src.maximum_reagent)
						inject_o = max(0, (src.maximum_reagent - oxy))
					src.occupant.reagents.add_reagent(src.med_oxy, inject_o)
					injected_anything = TRUE

				if (src.occupant.get_toxin_damage() >= src.damage_threshold && tox < src.maximum_reagent)
					var/inject_t = src.inject_reagent
					if ((tox + inject_t) > src.maximum_reagent)
						inject_t = max(0, (src.maximum_reagent - tox))
					src.occupant.reagents.add_reagent(src.med_tox, inject_t)
					injected_anything = TRUE

			src.no_med_spam = world.time

			if (injected_anything)
				playsound(src.loc, "sound/items/hypo.ogg", manual_injection ? 50 : 25, 1)

		return


	proc/go_out()
		if (!src || !src.occupant)
			return
		for (var/obj/O in src)
			if (O == src.our_console) // don't barf out the internal sleeper console tia
				continue
			O.set_loc(src.loc)
		src.add_fingerprint(usr)
		if (src.occupant.loc == src)
			src.occupant.set_loc(src.loc)
		src.occupant.changeStatus("weakened", 1 SECOND)
		src.occupant.force_laydown_standup()
		src.occupant = null
		src.update_icon()
		playsound(src.loc, "sound/machines/sleeper_open.ogg", 50, 1)
		return

	relaymove(mob/user as mob, dir)
		eject_occupant(user)
		return

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (get_dist(src,user) > 1 || get_dist(user, target) > 1)
			return

		if (target == user)
			move_inside()
		else if (can_operate(user))
			var/previous_user_intent = user.a_intent
			user.a_intent = INTENT_GRAB
			user.drop_item()
			target.attack_hand(user)
			user.a_intent = previous_user_intent
			SPAWN_DBG(user.combat_click_delay + 2)
				if (can_operate(user))
					if (istype(user.equipped(), /obj/item/grab))
						src.attackby(user.equipped(), user)
		return

	proc/can_operate(var/mob/M)
		if (!IN_RANGE(src, M, 1))
			return FALSE
		if (istype(M) && is_incapacitated(M))
			return FALSE
		if (src.occupant)
			boutput(M, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return FALSE
		if (!ishuman(M))
			boutput(usr, "<span class='alert'>You can't seem to fit into \the [src].</span>")
			return FALSE
		if (src.occupant)
			usr.show_text("The [src.name] is already occupied!", "red")
			return FALSE

		.= TRUE

	verb/move_inside()
		set src in oview(1)
		set category = "Local"

		if (!src) return

		if (!can_operate(usr)) return

		usr.pulling = null
		usr.set_loc(src)
		src.occupant = usr
		src.update_icon()
		for (var/obj/O in src)
			if (O == src.our_console) // don't barf out the internal sleeper console tia
				continue
			O.set_loc(src.loc)
		playsound(src.loc, "sound/machines/sleeper_close.ogg", 50, 1)
		return

	attack_hand(mob/user as mob)
		..()
		eject_occupant(user)

	MouseDrop(mob/user as mob)
		if (can_operate(user))
			eject_occupant(user)
		else
			..()

	verb/eject()
		set src in oview(1)
		set category = "Local"

		eject_occupant(usr)
		return

	verb/eject_occupant(var/mob/user)
		if (!isalive(user)) return
		src.go_out()
		add_fingerprint(user)

	//Sleeper communication over powernet link thing.
	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		//They don't need to target us specifically to ping us.
		//Otherwise, ff they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.data["device"] = "MED_SLEEPER"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.data["sender"] = src.net_id
				pingsignal.transmission_method = TRANSMISSION_WIRE
				SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
					src.link.post_signal(src, pingsignal)

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("status") //How is our patient doing?
				var/patient_stat = "NONE"
				if(src.occupant)
					patient_stat = "[src.occupant.get_brute_damage()];[src.occupant.get_burn_damage()];[src.occupant.get_toxin_damage()];[src.occupant.get_oxygen_deprivation()]"

				var/datum/signal/reply = new
				reply.data["command"] = "device_reply"
				reply.data["status"] = patient_stat
				reply.data["address_1"] = signal.data["sender"]
				reply.data["sender"] = src.net_id
				reply.transmission_method = TRANSMISSION_WIRE
				SPAWN_DBG(0.5 SECONDS)
					src.link.post_signal(src, reply)

			if("inject")
				src.inject(null, 1)

		return

/obj/machinery/sleeper/port_a_medbay
	name = "Port-A-Medbay"
	desc = "An emergency transportation device for critically injured patients."
	icon = 'icons/obj/porters.dmi'
	anchored = 0
	mats = 30
	p_class = 1.2
	var/homeloc = null
	/// Mailgroups it'll try to send PDA notifications to
	var/list/mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH)

	New()
		..()
		if (!islist(portable_machinery))
			portable_machinery = list()
		portable_machinery.Add(src)
		our_console = new /obj/machinery/sleep_console/compact/portable (src)
		our_console.our_sleeper = src
		src.homeloc = src.loc
		animate_bumble(src, Y1 = 1, Y2 = -1, slightly_random = 0)

	disposing()
		..()
		if (islist(portable_machinery))
			portable_machinery.Remove(src)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		animate_bumble(src, Y1 = 1, Y2 = -1, slightly_random = 0)

	attack_hand(mob/user as mob)
		if (our_console)
			our_console.attack_hand(user)
			interact_particle(user,src)

	examine()
		. = ..()
		. += "Home turf: [get_area(src.homeloc)]."

	// Could be useful (Convair880).
	MouseDrop(over_object, src_location, over_location)
		if (src.occupant)
			..()
			return
		if (isobserver(usr) || isintangible(usr))
			return
		if (usr == src.occupant || !isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened"))
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 1)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor/))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (alert("Set selected turf as home location?",,"Yes","No") == "Yes")
			src.homeloc = over_object
			usr.visible_message("<span class='notice'><b>[usr.name]</b> changes the [src.name]'s home turf.</span>", "<span class='notice'>New home turf selected: [get_area(src.homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing("station", usr, null, "sets [src.name]'s home turf to [log_loc(src.homeloc)].")
		return

/// Yells at doctors to check the thing when it's sent home
/obj/machinery/sleeper/port_a_medbay/proc/PDA_alert_check()
	if (src.loc != homeloc)
		return
	if (!occupant)
		return
	var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency(FREQ_PDA)
	if (!transmit_connection)
		return

	var/PDAalert = "[src.name] has returned to [get_area(src.homeloc)] with a "
	var/alertgroup = MGA_MEDCRIT
	if (isdead(occupant))
		PDAalert += "deceased body - please process the occupant as soon as possible."
		alertgroup = MGA_DEATH
	else if (occupant.health < 0)
		PDAalert += "patient in critical condition - respond and treat immediately."
	else
		PDAalert += "patient - please check in on the occupant."

	var/datum/signal/PDAsignal = get_free_signal()

	PDAsignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="HEALTH-MAILBOT",  "group"=mailgroups+alertgroup, "sender"="00000000", "message"="[PDAalert]")
	PDAsignal.transmission_method = TRANSMISSION_RADIO
	transmit_connection.post_signal(src, PDAsignal)


/obj/machinery/sleeper/compact
	name = "Compact Sleeper"
	desc = "Your usual sleeper, but compact this time. Wow!"
	icon = 'icons/obj/compact_machines.dmi'
	icon_state = "compact_sleeper"
	anchored = 1

	New()
		..()
		if (!islist(portable_machinery))
			portable_machinery = list()
		portable_machinery.Add(src)
		our_console = new /obj/machinery/sleep_console/compact (src)
		our_console.our_sleeper = src

	disposing()
		..()
		if (islist(portable_machinery))
			portable_machinery.Remove(src)

	attack_hand(mob/user as mob)
		if (our_console)
			our_console.attack_hand(user)
			interact_particle(user,src)
