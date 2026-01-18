#define PROCESS_IDLE 0
#define PROCESS_STRIP 1
#define PROCESS_MINCE 2

TYPEINFO(/obj/machinery/clone_scanner)
	mats = 15

/obj/machinery/clone_scanner
	name = "cloning machine scanner"
	desc = "A machine that you stuff living, and freshly not-so-living people into in order to scan them for cloning"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	var/locked = 0
	var/mob/occupant = null
	anchored = ANCHORED
	soundproofing = 10
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/computer/cloning/connected = null

	// In case someone wants a perfectly safe device. For some weird reason.
	var/can_meat_grind = 1
	//Double functionality as a meat grinder
	var/list/obj/machinery/clonepod/pods
	// How long to run
	var/process_timer = 0
	var/timer_length = 0
	// Automatically strip the target of their equipment
	var/auto_strip = 1
	// Check if the target is a living human before mincing
	var/mince_safety = 1
	// How far away to find clone pods
	var/pod_range = 4
	// What we are working on at the moment
	var/active_process = PROCESS_IDLE
	// If we should start the mincer after the stripper (lol)
	var/automatic_sequence = 0
	// Our ID for mapping
	var/id = ""
	// If upgraded or not
	var/upgraded = 0

	allow_drop()
		return 0

	New()
		..()
		src.create_reagents(100)

	relaymove(mob/user as mob, dir)
		eject_occupant(user)

	disposing()
		connected?.scanner = null
		connected = null
		pods = null
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	Click(location, control, params)
		if(!src.ghost_observe_occupant(usr, src.occupant))
			. = ..()

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (BOUNDS_DIST(src, user) > 0 || BOUNDS_DIST(user, target) > 0)
			return

		if (target == user)
			move_mob_inside(target, user)
		else if (can_operate(user))
			var/previous_user_intent = user.a_intent
			user.set_a_intent(INTENT_GRAB)
			user.drop_item()
			target.Attackhand(user)
			user.set_a_intent(previous_user_intent)
			SPAWN(user.combat_click_delay + 2)
				if (can_operate(user))
					if (istype(user.equipped(), /obj/item/grab))
						src.Attackby(user.equipped(), user)
		return


	proc/can_operate(var/mob/M)
		if (!(BOUNDS_DIST(src, M) == 0))
			return FALSE
		if (is_incapacitated(M))
			return FALSE
		if (src.occupant)
			boutput(M, SPAN_NOTICE("<B>The scanner is already occupied!</B>"))
			return FALSE

		.= TRUE

	verb/move_inside()
		set src in oview(1)
		set category = "Local"

		move_mob_inside(usr, usr)
		return

	proc/move_mob_inside(var/mob/M, var/mob/user)
		if (!can_operate(user) || !ishuman(M) || QDELETED(M))
			return

		M.remove_pulling()
		M.set_loc(src)
		src.occupant = M
		src.icon_state = "scanner_1"

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(user)
		src.connected?.updateUsrDialog()

		playsound(src.loc, 'sound/machines/sleeper_close.ogg', 50, 1)

	attack_hand(mob/user)
		..()
		eject_occupant(user)

	mouse_drop(mob/user as mob)
		if (istype(user) && can_operate(user))
			eject_occupant(user)
		else
			..()

	verb/eject()
		set src in oview(1)
		set category = "Local"

		eject_occupant(usr)
		return

	verb/eject_occupant(var/mob/user)
		if (!src.can_eject_occupant(user))
			return
		src.go_out()
		add_fingerprint(user)

	attackby(var/obj/item/grab/G, user)
		if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
			return

		if (src.occupant)
			boutput(user, SPAN_NOTICE("<B>The scanner is already occupied!</B>"))
			return

		move_mob_inside(G.affecting, user)
		qdel(G)
		return

	proc/go_out()
		if ((!( src.occupant ) || src.locked))
			return
		if(!src.occupant.disposed)
			src.occupant.set_loc(get_turf(src))
		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.occupant)
			src.occupant = null

			for(var/atom/movable/A in src)
				if(!QDELETED(A))
					A.set_loc(src.loc)

			src.icon_state = "scanner_0"

			playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)

	was_deconstructed_to_frame(mob/user)
		src.go_out()

	proc/set_lock(var/lock_status)
		if(lock_status && !locked)
			locked = 1
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			boutput(occupant, SPAN_ALERT("\The [src] locks shut!"))
		else if(!lock_status && locked)
			locked = 0
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			boutput(occupant, SPAN_NOTICE("\The [src] unlocks!"))

	// Meat grinder functionality.
	proc/find_pods()
		if (!islist(src.pods))
			src.pods = list()
		if (!isnull(src.id) && genResearch && islist(genResearch.clonepods) && length(genResearch.clonepods))
			for (var/obj/machinery/clonepod/pod as anything in genResearch.clonepods)
				if (pod.id == src.id && !src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] (ID [src.id]) in genResearch.clonepods")
		else
			for (var/obj/machinery/clonepod/pod in orange(src.pod_range))
				if (!src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] in orange([src.pod_range])")

	process()
		switch(active_process)
			if(PROCESS_IDLE)
				UnsubscribeProcess()
				process_timer = 0
				return
			if(PROCESS_MINCE)
				do_mince()
			if(PROCESS_STRIP)
				do_strip()

	proc/report_progress()
		switch(active_process)
			if(PROCESS_IDLE)
				. = "Idle."
			if(PROCESS_MINCE)
				. = "Reclamation process [round(process_timer/timer_length)*100] % complete..."
			if(PROCESS_STRIP)
				. = "In progress..."

	proc/start_mince()
		active_process = PROCESS_MINCE
		timer_length = 15 + rand(-5, 5)
		process_timer = timer_length
		set_lock(1)
		boutput(occupant, "<span style='color:red;font-weight:bold'>A whirling blade slowly begins descending upon you!</span>")
		playsound(src, 'sound/machines/mixer.ogg', 50, TRUE)
		SubscribeToProcess()

	proc/start_strip()
		active_process = PROCESS_STRIP
		set_lock(1)
		boutput(occupant, SPAN_ALERT("Hatches open and tiny, grabby claws emerge!"))

		SubscribeToProcess()

	proc/do_mince()
		if (process_timer-- < 1)
			active_process = PROCESS_IDLE
			src.occupant.death(TRUE)
			src.occupant.ghostize()
			qdel(src.occupant)
			DEBUG_MESSAGE("[src].reagents.total_volume on completion of cycle: [src.reagents.total_volume]")

			if (islist(src.pods) && pods.len && src.reagents.total_volume)
				for (var/obj/machinery/clonepod/pod in src.pods)
					src.reagents.trans_to(pod, (src.reagents.total_volume / max(pods.len, 1))) // give an equal amount of reagents to each pod that happens to be around
					DEBUG_MESSAGE("[src].reagents.trans_to([pod] [log_loc(pod)], [src.reagents.total_volume]/[max(pods.len, 1)])")
			process_timer = 0
			active_process = PROCESS_IDLE
			set_lock(0)
			automatic_sequence = 0
			return

		var/mult = src.upgraded ? 2 : 1
		src.reagents.add_reagent("blood", 2 * mult)
		src.reagents.add_reagent("meat_slurry", 2 * mult)
		if (prob(2))
			src.reagents.add_reagent("beff", 1 * mult)

		// Mess with the occupant
		var/damage = round(200 / timer_length) + rand(1, 10)
		src.occupant.TakeDamage(zone="All", brute=damage)
		bleed(occupant, damage * 2, 0)
		if(prob(50))
			playsound(src, 'sound/machines/mixer.ogg', 50, TRUE)
		if(prob(30))
			SPAWN(0.3 SECONDS)
				playsound(src.loc, pick('sound/impact_sounds/Flesh_Stab_1.ogg', \
									'sound/impact_sounds/Slimy_Hit_3.ogg', \
									'sound/impact_sounds/Slimy_Hit_4.ogg', \
									'sound/impact_sounds/Flesh_Break_1.ogg', \
									'sound/impact_sounds/Flesh_Tear_1.ogg', \
									'sound/impact_sounds/Generic_Snap_1.ogg', \
									'sound/impact_sounds/Generic_Hit_1.ogg'), 100, 5)

	proc/do_strip()
		//Remove one item each cycle
		var/obj/item/to_remove
		if(src.occupant)
			to_remove = occupant.unequip_random()

		if(to_remove)
			if(prob(70))
				boutput(occupant, SPAN_ALERT("\The arms [pick("snatch", "grab", "steal", "remove", "nick", "blag")] your [to_remove.name]!"))
				playsound(src, "sound/misc/rustle[rand(1,5)].ogg", 50, 1)
			to_remove.set_loc(src.loc)
		else
			if(automatic_sequence)
				start_mince()
			else
				set_lock(0)
				active_process = PROCESS_IDLE

#undef PROCESS_IDLE
#undef PROCESS_STRIP
#undef PROCESS_MINCE
