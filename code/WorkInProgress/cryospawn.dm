#define CRYOSLEEP_DELAY 15 MINUTES
#define CRYOTRON_MESSAGE_DELAY 3 SECONDS

/obj/cryotron_spawner
	New()
		..()
		SPAWN_DBG(1 SECOND)
#ifdef RP_MODE
			new /obj/cryotron(src.loc)
#endif
			qdel(src)

//Special destiny spawn point doodad
/obj/cryotron
	name = "industrial cryogenic sleep unit"
	desc = "The terminus of a large underfloor cryogenic storage complex."
	anchored = 1
	density = 1
	icon = 'icons/obj/64x96.dmi'
	icon_state = "cryotron_up"
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
	var/tmp/busy = 0

	New()
		..()
		// x += 1 here, with bound_x / pixel_x -= 32, keeps it centered while
		// ensuring that its location is actually the center of the damn thing
		// this keeps it from needing to move mobs one over,
		// and stops the "decompression" from coming out the left side
		START_TRACKING
		processing_items += src
		x += 1

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

		SPAWN_DBG(1.9 SECONDS)
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
				return 1

		stored_mobs += L
		if (!voluntary) // someone shoved us in here, mark them as not being in here of their own choice (this can only be done with braindead people who have a ckey, so you can't just grief some guy by shoving them in)
			stored_mobs[L] = "involuntary"
		else
			stored_mobs[L] = world.timeofday
		L.set_loc(src)
		L.hibernating = 1
		if (L.client)
			L.addOverlayComposition(/datum/overlayComposition/blinded)
			L.updateOverlaysClient(L.client)
		if (ishuman(L))
			var/mob/living/carbon/human/H = L
			if (H.sims)
				for (var/name in H.sims.motives)
					H.sims.affectMotive(name, 100)
		return 1

	proc/enter_prompt(var/mob/living/user as mob)
		if (mob_can_enter_storage(user)) // check before the prompt for dead/incapped/restrained/etc users
			if (alert(user, "Would you like to enter cryogenic storage? You will be unable to leave it again until 15 minutes have passed.", "Confirmation", "Yes", "No") == "Yes")
				if (alert(user, "Are you absolutely sure you want to enter cryogenic storage?", "Confirmation", "Yes", "No") == "Yes")
					if (mob_can_enter_storage(user)) // check again in case they left the prompt up and moved away/died/whatever
						add_person_to_storage(user)
					return 1
		return 0

	proc/mob_can_enter_storage(var/mob/living/L as mob, var/mob/user as mob)
		if (!ticker)
			boutput(L, "<b>You can't enter cryogenic storage before the game's started!</b>")
			boutput(user, "<b>You can't put someone in cryogenic storage before the game's started!</b>")
			return 0
		if(master_mode == "battle_royale")
			boutput(L, "<b>The high levels of BATTLE ENERGY in this area prevent the use of cryogenic storage! Get your ass out there and fight, coward!</b>")
			boutput(user, "<b>The high levels of BATTLE ENERGY in this area prevent the use of cryogenic storage!</b>")
		if (!istype(L) || isdead(L))
			boutput(L, "<b>You have to be alive to enter cryogenic storage!</b>")
			boutput(user, "<b>You can't put someone in cryogenic storage if they aren't alive!</b>")
			return 0
		if (L.stat || L.restrained() || L.getStatusDuration("paralysis") || L.sleeping)
			boutput(L, "<b>You can't enter cryogenic storage while incapacitated!</b>")
			boutput(user, "<b>You can't put someone in cryogenic storage while they're incapacitated or restrained!</b>")
			return 0
		if (user && (user.stat || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping))
			boutput(user, "<b>You can't put someone in cryogenic storage while you're incapacitated or restrained!</b>")
			return 0
		if (get_dist(src, L) > 1)
			boutput(L, "<b>You need to be closer to [src] to enter cryogenic storage!</b>")
			boutput(user, "<b>[L] needs to be closer to [src] for you to put them in cryogenic storage!</b>")
			return 0
		if (user && get_dist(src, user) > 1)
			boutput(user, "<b>You need to be closer to [src] to put someone in cryogenic storage!</b>")
			return 0
		var/mob/living/silicon/R = L
		if (istype(R))
			if (R.mainframe || isAI(R) || isshell(R))
				boutput(user, "<b>You can't put the AI in cryogenic storage!</b>")
				return 0
			if (!isrobot(R) && !isghostdrone(R))
				boutput(user, "<b>You can't put that machine in cryogenic storage!</b>")
				return 0
		return 1

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
					user.last_cryotron_message = ticker.round_elapsed_ticks
					return 0
		if (alert(user, "Would you like to leave cryogenic storage?", "Confirmation", "Yes", "No") == "No")
			return 0
		if (user.loc != src || !stored_mobs.Find(user))
			return 0
		if (add_person_to_queue(user, null))
			stored_mobs[user] = null
			stored_mobs -= user
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

	attack_hand(var/mob/user as mob)
		if(isgrab(user.l_hand))
			src.attackby(user.l_hand, user)
		else if(isgrab(user.r_hand))
			src.attackby(user.r_hand, user)
		else if (!enter_prompt(user))
			return ..()

	attack_ai(mob/user as mob)
		if (!enter_prompt(user))
			return ..()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
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
			return 0
		else if (alert(user, "Would you like to put [target] into cryogenic storage? They will be able to leave it immediately if they log back in.", "Confirmation", "Yes", "No") == "Yes")
			if (!src.mob_can_enter_storage(target, user))
				return 0
			else
				src.add_person_to_storage(target, 0)
				src.visible_message("<span class='alert'><b>[user] forces [target] into [src]!</b></span>")
				return 1
		return 0

	relaymove(var/mob/user as mob, dir)
		if ((user.last_cryotron_message + CRYOTRON_MESSAGE_DELAY) > ticker.round_elapsed_ticks)
			return ..()
		if (!exit_prompt(user))
			return ..()

	MouseDrop_T(atom/target, mob/user as mob)
		if (ishuman(target) && isrobot(user) && get_dist(src, user) <= 1 && get_dist(src, target) <= 1 && get_dist(user, target) <= 1)
			insert_prompt(target, user)
			return
		return ..()

