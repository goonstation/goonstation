#define CRYOSLEEP_DELAY 5 MINUTES
#define CRYOTRON_MESSAGE_DELAY 3 SECONDS

//Latejoin spawn point thing, for gracefully leaving rounds. Also replaces the arrivals shuttle on some maps.
/obj/cryotron
	name = "industrial cryogenic sleep unit"
	desc = "The terminus of a large underfloor cryogenic storage complex."
	anchored = ANCHORED_ALWAYS
	density = 1
	icon = 'icons/obj/large/64x96.dmi'
	icon_state = "cryotron_up"
	event_handler_flags = IMMUNE_SINGULARITY
	pass_unstable = FALSE
	bound_width = 96
	bound_x = -32
	bound_height = 64
#ifdef IN_MAP_EDITOR
	pixel_x = 0
#else
	pixel_x = -32
#endif

	var/list/folks_to_spawn = list()
	var/list/their_jobs = list()
	var/list/stored_mobs = list() // people who've bowed out of the round
	var/list/stored_crew_names = list() // stores real_names and only removes names if you leave cryo, not ghost
	var/tmp/busy = 0

	New()
		..()
		// x += 1 here, with bound_x / pixel_x -= 32, keeps it centered while
		// ensuring that its location is actually the center of the damn thing
		// this keeps it from needing to move mobs one over,
		// and stops the "decompression" from coming out the left side
		START_TRACKING
		processing_items += src
		x += -bound_x / world.icon_size
		#ifdef UPSCALED_MAP
		pixel_x = -64
		#endif


	disposing()
		STOP_TRACKING
		var/turf/T = get_turf(src)
		for (var/mob/M in src)
			M.set_loc(T)
			if (isliving(M))
				var/mob/living/L = M
				L.hibernating = 0
				L.removeOverlayComposition(/datum/overlayComposition/blinded)
		for (var/obj/O in src)
			O.set_loc(T)
		..()

	ex_act()
		return

	meteorhit(obj/meteor)
		return

	proc/add_person_to_queue(var/mob/living/person, var/datum/job/job)
		if (!istype(person) || job?.special_spawn_location)
			return 0

		person.set_loc(src)
		folks_to_spawn += person
		their_jobs += job

		boutput(person, "<b>Cryo-recovery process initiated.  Please wait . . .</b>")
		if (!person.bioHolder.HasEffect("blind"))
			person.removeOverlayComposition(/datum/overlayComposition/blinded)
		return 1

	proc/process()
		spawn_next_person()
		ensure_storage()

	//Return 1 if there is another person to spawn afterward
	proc/spawn_next_person()
		if (!folks_to_spawn.len)
			var/mob/living/L = locate(/mob/living) in src
			if (L && !stored_mobs.Find(L))
				folks_to_spawn += L
				their_jobs += null
			else
				return 0
		if (busy)
			return

		busy = 1
		var/mob/living/thePerson = folks_to_spawn[1]
		folks_to_spawn.Cut(1,2)
		var/datum/job/job = their_jobs[1]
		their_jobs.Cut(1,2)
		var/be_loud = job ? job.radio_announcement : 1
		if (!istype(thePerson) || thePerson.loc != src)
			busy = 0
			return (folks_to_spawn.len != 0)

		src.icon_state = "cryotron_down"
		flick("cryotron_go_down", src)

		SPAWN(1.9 SECONDS)
			if (!thePerson || thePerson.loc != src)
				busy = 0
				return
			var/turf/firstLoc = locate(src.x, src.y, src.z)
			thePerson.set_loc( firstLoc )
			playsound(src, 'sound/vox/decompression.ogg',be_loud ? 50 : 2)
			for (var/obj/O in src) // someone dropped something
				O.set_loc(firstLoc)

			sleep(1 SECOND)
			if (!thePerson)
				busy = 0
				return
			if (thePerson.loc == firstLoc)
				step(thePerson, SOUTH)
			src.icon_state = "cryotron_up"
			flick("cryotron_go_up", src)

			if (thePerson)
				thePerson.hibernating = 0
				if (thePerson.mind && thePerson.mind.assigned_role && be_loud)
					for (var/obj/machinery/computer/announcement/A as anything in machine_registry[MACHINES_ANNOUNCEMENTS])
						if (!A.status && A.announces_arrivals)
							A.announce_arrival(thePerson)

			sleep(0.9 SECONDS)
			busy = 0
			return

	proc/add_person_to_storage(var/mob/living/L as mob, var/voluntary = 1)
		if (!istype(L))
			return 0
		if (stored_mobs.Find(L))
			if (L.loc == src)
				return 0
			else
				L.set_loc(src)
				L.hibernating = 1
				if (L.client)
					L.addOverlayComposition(/datum/overlayComposition/blinded)
					L.updateOverlaysClient(L.client)
				for (var/obj/machinery/computer/announcement/A as anything in machine_registry[MACHINES_ANNOUNCEMENTS])
					if (!A.status && A.announces_arrivals)
						A.announce_departure(L)
				logTheThing(LOG_STATION, L, "entered cryogenic storage at [log_loc(src)].")
				return 1

		stored_mobs += L
		stored_crew_names += L.real_name
		if (!voluntary) // someone shoved us in here, mark them as not being in here of their own choice (this can only be done with braindead people who have a ckey, so you can't just grief some guy by shoving them in)
			stored_mobs[L] = "involuntary"
		else
			stored_mobs[L] = world.timeofday
		L.set_loc(src)
		L.hibernating = 1
		if (L.client)
			L.addOverlayComposition(/datum/overlayComposition/blinded)
			L.updateOverlaysClient(L.client)
		for (var/obj/machinery/computer/announcement/A as anything in machine_registry[MACHINES_ANNOUNCEMENTS])
			if (!A.status && A.announces_arrivals)
				A.announce_departure(L)
		if (ishuman(L))
			var/mob/living/carbon/human/H = L
			if (H.sims)
				for (var/name in H.sims.motives)
					H.sims.affectMotive(name, 100)

		var/datum/db_record/crew_record = data_core.general.find_record("id", L.datacore_id)
		if (!isnull(crew_record))
			crew_record["p_stat"] = "In Cryogenic Storage"
		logTheThing(LOG_STATION, L, "entered cryogenic storage at [log_loc(src)].")
		return 1

	proc/enter_prompt(var/mob/living/user as mob)
		if (mob_can_enter_storage(user)) // check before the prompt for dead/incapped/restrained/etc users
			if (tgui_alert(user, "Would you like to enter cryogenic storage? You will be unable to leave it again until 5 minutes have passed.", "Confirmation", list("Yes", "No")) == "Yes")
				if (tgui_alert(user, "Are you absolutely sure you want to enter cryogenic storage?", "Confirmation", list("Yes", "No")) == "Yes")
					if (mob_can_enter_storage(user)) // check again in case they left the prompt up and moved away/died/whatever
						add_person_to_storage(user)
					return 1
		return 0

	proc/mob_can_enter_storage(var/mob/living/L as mob, var/mob/user as mob)
		// Game hasn't started
		if (!ticker)
			boutput(L, "<b>You can't enter cryogenic storage before the game's started!</b>")
			boutput(user, "<b>You can't put someone in cryogenic storage before the game's started!</b>")
			return FALSE
		// It's a battle royale
		if(master_mode == "battle_royale")
			boutput(L, "<b>The high levels of BATTLE ENERGY in this area prevent the use of cryogenic storage! Get your ass out there and fight, coward!</b>")
			boutput(user, "<b>The high levels of BATTLE ENERGY in this area prevent the use of cryogenic storage!</b>")
			return FALSE
		// Non-living mob (by type)
		if (!istype(L))
			boutput(L, "<b>You won't fit in the cryogenic storage!</b>")
			boutput(user, "<b>That won't fit in the cryogenic storage!</b>")
			return FALSE
		// Dead person entering/being put in storage
		if (isdead(L))
			boutput(L, "<b>You have to be alive to enter cryogenic storage!</b>")
			boutput(user, "<b>You can't put someone in cryogenic storage if they aren't alive!</b>")
			return FALSE
		// Incapacitated or restrained person trying to enter storage on their own
		if (!user && (L.stat || L.restrained() || L.getStatusDuration("paralysis") || L.sleeping))
			boutput(L, "<b>You can't enter cryogenic storage while incapacitated!</b>")
			return FALSE
		// Incapacitated or restrained person trying to put someone else in
		if (user && (user.stat || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping))
			boutput(user, "<b>You can't put someone in cryogenic storage while you're incapacitated or restrained!</b>")
			return FALSE
		// Person entering is too far away
		if (BOUNDS_DIST(src, L) > 0)
			boutput(L, "<b>You need to be closer to [src] to enter cryogenic storage!</b>")
			boutput(user, "<b>[L] needs to be closer to [src] for you to put them in cryogenic storage!</b>")
			return FALSE
		// Person putting other person in is too far away
		if (user && BOUNDS_DIST(src, user) > 0)
			boutput(user, "<b>You need to be closer to [src] to put someone in cryogenic storage!</b>")
			return FALSE
		var/mob/living/silicon/R = L
		// That's a goddamn robot
		if (istype(R))
			// That's the goddamn AI
			if (R.mainframe || isAI(R) || isshell(R))
				boutput(user, "<b>You can't put the AI in cryogenic storage!</b>")
				return FALSE
			// That's a goddamn cyborg
			if (!isrobot(R) && !isghostdrone(R))
				boutput(user, "<b>You can't put that machine in cryogenic storage!</b>")
				return FALSE
		// Gratz
		return TRUE

	proc/exit_prompt(var/mob/living/user as mob)
		if (!user || !stored_mobs.Find(user))
			return 0
		var/entered = stored_mobs[user] // this will be the world.timeofday that the mob went into the cryotron, or a text string if they were forced in
		if (isnum(entered)) // fix for cannot compare 614825 to "involuntary" (sadly there is no fix for spy sassing me about a runtime HE CAUSED, THE BUTT)
			var/time_of_day = world.timeofday + ((world.timeofday < entered) ? 864000 : 0) //Offset the time of day in case of midnight rollover
			if ((entered + CRYOSLEEP_DELAY) > time_of_day) // is the time entered plus 15 minutes greater than the current time? the mob hasn't waited long enough
				var/time_left = entered + CRYOSLEEP_DELAY - time_of_day
				if (time_left >= 0)
					var/minutes = round(time_left / (1 MINUTE))
					var/seconds = round((time_left % (1 MINUTE)) / (1 SECOND))

					var/time_left_message = "[seconds] second[s_es(seconds)]"

					if(minutes >= 1)
						time_left_message = "[minutes] minute[s_es(minutes)] and [time_left_message]"

					boutput(user, "<b>You must wait at least [time_left_message] until you can leave cryosleep.</b>")
					return FALSE
		if (tgui_alert(user, "Would you like to leave cryogenic storage?", "Confirmation", list("Yes", "No")) != "Yes")
			return 0
		if (user.loc != src || !stored_mobs.Find(user))
			return 0
		if (add_person_to_queue(user, null))
			stored_mobs[user] = null
			stored_mobs -= user
			stored_crew_names -= user.real_name
			var/datum/db_record/crew_record = data_core.general.find_record("id", user.datacore_id)
			if (!isnull(crew_record))
				crew_record["p_stat"] = "Active"
			return 1
		return 0

	proc/ensure_storage()
		if (!stored_mobs.len)
			return
		for (var/mob/living/L in stored_mobs)
			if (L.loc != src)
				L.hibernating = 0
				L.removeOverlayComposition(/datum/overlayComposition/blinded)
				stored_mobs[L] = null
				stored_mobs -= L
				if(!isnull(L.loc)) // loc only goes null when you ghost, probably
					stored_crew_names -= L.real_name // you shouldn't be removed from the list when you ghost
					var/datum/db_record/crew_record = data_core.general.find_record("id", L.datacore_id)
					if (!isnull(crew_record))
						crew_record["p_stat"] = "Active"

	attack_hand(var/mob/user)
		if(isgrab(user.l_hand))
			src.Attackby(user.l_hand, user)
		else if(isgrab(user.r_hand))
			src.Attackby(user.r_hand, user)
		else if (!enter_prompt(user))
			return ..()

	attack_ai(mob/user as mob)
		if(isAIeye(user))
			boutput(user, "<span class='alert'>An incorporeal manifestation of an artificial intelligence's presence can't enter \the [src]!</span>")
			return FALSE
		if (!enter_prompt(user))
			return ..()

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (ismob(G.affecting) && insert_prompt(G.affecting, user))
				user.u_equip(G)
				qdel(G)
		else if (!enter_prompt(user))
			return ..()

	proc/insert_prompt(mob/target, mob/user)
		if (target.client || !target.ckey)
			boutput(user, "<span class='alert'>You can't force someone into cryosleep if they're still logged in or are an NPC!</span>")
			return FALSE
		else if (tgui_alert(user, "Would you like to put [target] into cryogenic storage? They will be able to leave it immediately if they log back in.", "Confirmation", list("Yes", "No")) == "Yes")
			if (!src.mob_can_enter_storage(target, user))
				return FALSE
			else
				src.add_person_to_storage(target, FALSE)
				src.visible_message("<span class='alert'><b>[user] forces [target] into [src]!</b></span>")
				return TRUE
		return FALSE

	relaymove(var/mob/user as mob, dir)
		if (ON_COOLDOWN(user, "cryotron_move", CRYOTRON_MESSAGE_DELAY))
			return ..()
		if (!exit_prompt(user))
			return ..()

	MouseDrop_T(atom/target, mob/user as mob)
		if (ishuman(target) && isrobot(user) && BOUNDS_DIST(src, user) == 0 && BOUNDS_DIST(src, target) == 0 && BOUNDS_DIST(user, target) == 0)
			insert_prompt(target, user)
			return
		return ..()

