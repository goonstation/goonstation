// WIP bot improvements (Convair880).

////////////////////////////////////////////// Cleanbot assembly ///////////////////////////////////////
/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_cleanbot_type = /obj/machinery/bot/cleanbot

	attackby(var/obj/item/parts/robot_parts/P, mob/user as mob)
		if (!istype(P, /obj/item/parts/robot_parts/arm/))
			return

		var/obj/machinery/bot/cleanbot/A = new created_cleanbot_type
		if (user.r_hand == src || user.l_hand == src)
			A.set_loc(get_turf(user))
		else
			A.set_loc(get_turf(src))

		boutput(user, "You add the robot arm to the bucket and sensor assembly! Beep boop!")
		qdel(P)
		qdel(src)
		return

	red
		icon_state = "bucket_proxy-red"
		created_cleanbot_type = /obj/machinery/bot/cleanbot/red

///////////////////////////////////////////////// Cleanbot ///////////////////////////////////////
/obj/machinery/bot/cleanbot
	name = "cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "cleanbot0"
	layer = 5
	density = 0
	anchored = 0
	var/icon_state_base // defined in new, this is the base of the icon_state with the suffix removed, i.e. "cleanbot" without the "0", for easier modification of icon_states so long as the convention is followed

	on = 1
	locked = 1
	health = 25
	no_camera = 1
	access_lookup = "Janitor"

	var/target // Current target.
	var/list/path = null // Path to current target.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 1800 // How frequently?
	var/frustration = 0 // Simple counter. Bot selects new target if current one is too far away.

	var/idle = 1 // In relation to world time. In case there aren't any valid targets nearby.
	var/idle_delay = 210 // For how long?

	var/cleaning = 0 // Are we currently cleaning something?
	var/reagent_normal = "cleaner"
	var/reagent_emagged = "lube"
	var/list/lubed_turfs = list() // So we don't lube the same turf ad infinitum.
	var/bucket_type_on_destruction = /obj/item/reagent_containers/glass/bucket

	New()
		..()
		icon_state_base = copytext(icon_state, 1, -1)
		src.add_simple_light("bot", list(255, 255, 255, 255 * 0.4))

		SPAWN_DBG(0.5 SECONDS)
			if (src)
				src.botcard = new /obj/item/card/id(src)
				src.botcard.access = get_access(src.access_lookup)
				src.clear_invalid_targets = world.time

				var/datum/reagents/R = new /datum/reagents(50)
				src.reagents = R
				R.my_atom = src

				if (src.emagged)
					R.add_reagent(src.reagent_emagged, 50)
				else
					R.add_reagent(src.reagent_normal, 50)

				src.toggle_power(1)
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user && ismob(user))
				src.emagger = user
				src.add_fingerprint(user)
				user.show_text("You short out [src]'s waste disposal circuits.", "red")
				for (var/mob/O in hearers(src, null))
					O.show_message("<span class='alert'><B>[src] buzzes oddly!</B></span>", 1)

			src.emagged = 1
			src.toggle_power(1)

			if (src.reagents)
				src.reagents.clear_reagents()
				src.reagents.add_reagent(src.reagent_emagged, 50)

			logTheThing("station", src.emagger, null, "emagged a [src.name], setting it to spread [src.reagent_emagged] at [log_loc(src)].")
			return 1

		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair [src]'s waste disposal circuits.", "blue")
		src.emagged = 0
		return 1

	emp_act()
		..()
		if (!src.emagged && prob(75))
			src.emag_act(usr && ismob(usr) ? usr : null, null)
		else
			src.explode()
		return

	proc/toggle_power(var/force_on = 0)
		if (!src)
			return

		if (force_on == 1)
			src.on = 1
		else
			src.on = !src.on

		src.anchored = 0
		src.target = null
		src.icon_state = "[icon_state_base][src.on]"
		src.path = null
		src.targets_invalid = list() // Turf vs decal when emagged, so we gotta clear it.
		src.lubed_turfs = list()
		src.clear_invalid_targets = world.time

		if (src.on)
			src.add_simple_light("bot", list(255, 255, 255, 255 * 0.4))
		else
			src.remove_simple_light("bot")

		return

	attack_hand(mob/user as mob, params)
		src.add_fingerprint(user)
		var/dat = ""

		dat += "<tt><b>Automatic Station Cleaner v1.1</b></tt>"
		dat += "<br><br>"
		dat += "Status: <A href='?src=\ref[src];start=1'>[src.on ? "On" : "Off"]</A><br>"

		if (user.client.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = "Cleanerbot v1.1 controls",
				"content" = dat,
			))

		return

	attack_ai(mob/user as mob)
		if (src.on && src.emagged)
			boutput(user, "[src] refuses your authority!", "red")
			return

		src.toggle_power(0)
		return

	Topic(href, href_list)
		if (..()) return
		if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat || usr.restrained()) return
		if (!issilicon(usr) && !in_range(src, usr)) return

		src.add_fingerprint(usr)
		src.add_dialog(usr)

		if (href_list["start"])
			src.toggle_power(0)

		src.updateUsrDialog()
		return

	attackby(obj/item/W, mob/user as mob)
		if (isweldingtool(W))
			if (src.health < initial(src.health))
				if(W:try_weld(user, 1))
					src.health = initial(src.health)
					src.visible_message("<span class='alert'><b>[user]</b> repairs the damage on [src].</span>")

		else
			..()
			switch(W.hit_type)
				if (DAMAGE_BURN)
					src.health -= W.force * 0.75
				else
					src.health -= W.force * 0.5
			if (src.health <= 0)
				src.explode()

		return

	process()
		if (!src.on)
			return

		if (src.cleaning)
			return

		// We're still idling.
		if (src.idle && world.time < src.idle + src.idle_delay)
			//DEBUG_MESSAGE("Sleeping. [log_loc(src)]")
			return

		// Invalid targets may not be unreachable anymore. Clear list periodically.
		if (src.clear_invalid_targets && world.time > src.clear_invalid_targets + src.clear_invalid_targets_interval)
			src.targets_invalid = list()
			src.lubed_turfs = list()
			src.clear_invalid_targets = world.time
			//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Cleared target_invalid. [log_loc(src)]")

		if (src.frustration >= 8)
			//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Selecting new target (frustration). [log_loc(src)]")
			if (src.target && !(src.target in src.targets_invalid))
				src.targets_invalid += src.target
			src.frustration = 0
			src.target = null

		//mbc : hey i don't feel like fixing this right now, but this shouldn't be a list built each process(). move it to a static list on cleanbot base
		// So nearby bots don't go after the same mess.
		var/list/cleanbottargets = list()
		if (!src.target || src.target == null)
			for (var/obj/machinery/bot/cleanbot/bot in machine_registry[MACHINES_BOTS])
				if (bot != src)
					if (bot.target && !(bot.target in cleanbottargets))
						cleanbottargets += bot.target

		// Let's find us something to clean.
		if (!src.target || src.target == null)
			if (src.emagged)
				for (var/turf/simulated/floor/F in view(7, src))
					if (F in targets_invalid)
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (target_invalid). [F] [log_loc(F)]")
						continue
					if (F in cleanbottargets)
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (other bot target). [F] [log_loc(F)]")
						continue
					if (F in src.lubed_turfs)
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (lubed). [F] [log_loc(F)]")
						continue
					for (var/atom/A in F.contents)
						if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
							if (!(F in src.targets_invalid))
								//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (density). [F] [log_loc(F)]")
								src.targets_invalid += F
							continue

					src.target = F
					//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Target acquired. [F] [log_loc(F)]")
					break
			else
				for (var/turf/simulated/floor/F in view(7, src))
					if (F in targets_invalid)
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (target_invalid). [D] [log_loc(D)]")
						continue
					if (F in cleanbottargets)
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (other bot target). [D] [log_loc(D)]")
						continue

					if (F.messy || F.active_liquid)
						src.target = F
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Target acquired. [D] [log_loc(D)]")
						break

		// Still couldn't find one? Abort and retry later.
		if (!src.target || src.target == null)
			//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (no valid targets). [log_loc(src)]")
			src.idle = world.time
			return

		// Let's find us a path to the target.
		if (src.target && (!src.path || !src.path.len))
			SPAWN_DBG(0)
				if (!src)
					return

				var/turf/T = get_turf(src.target)
				if (!isturf(src.loc) || !T || !isturf(T) || T.density)
					if (!(src.target in src.targets_invalid))
						src.targets_invalid += src.target
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (target density). [T] [log_loc(T)]")
					src.target = null
					return

				if (istype(T, /turf/space))
					if (!(src.target in src.targets_invalid))
						src.targets_invalid += src.target
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (space tile). [T] [log_loc(T)]")
					src.target = null
					return

				for (var/atom/A in T.contents)
					if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
						if (!(src.target in src.targets_invalid))
							src.targets_invalid += src.target
							//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Acquiring target failed (obstruction). [T] [log_loc(T)]")
						src.target = null
						return

				src.path = AStar(get_turf(src), get_turf(src.target), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, adjacent_param = botcard)

				if (!src.path) // Woops, couldn't find a path.
					if (!(src.target in src.targets_invalid))
						src.targets_invalid += src.target
						//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Pathfinding failed. [T] [log_loc(T)]")
					src.target = null
					return

		// Move towards the target.
		if (src.path && src.path.len && src.target && (src.target != null))
			if (src.path.len > 8)
				src.frustration++
			step_to(src, src.path[1])
			if (src.loc == src.path[1])
				src.path -= src.path[1]
			else
				src.frustration++

			SPAWN_DBG(0.3 SECONDS)
				if (length(src?.path))
					if (length(src.path) > 8)
						src.frustration++
					step_to(src, src.path[1])
					if (src.loc == src.path[1])
						src.path -= src.path[1]
					else
						src.frustration++
			//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Moving towards target. [src.target] [log_loc(src.target)]")

		if (src.target)
			if (src.loc == get_turf(src.target))
				clean(src.target)
				src.path = null
				src.target = null
				return

		return

	proc/clean(var/turf/T)
		if (!src)
			return
		if (!T || !isturf(T))
			return

		src.anchored = 1
		src.icon_state = "[icon_state_base]-c"
		src.visible_message("<span class='alert'>[src] begins to clean the [T.name].</span>")
		src.cleaning = 1
		//DEBUG_MESSAGE("[src.emagged ? "(E) " : ""]Cleaning target. [src.target] [log_loc(src.target)]")

		SPAWN_DBG(0.5 SECONDS)
			if (src)
				if (src.reagents)
					src.reagents.reaction(T, 1, 10)

				if (src.emagged)
					if (!(T in src.lubed_turfs))
						src.lubed_turfs += T
					if (src.reagents) // ZeWaka: Fix for null.remove_reagent()
						src.reagents.remove_reagent(src.reagent_emagged, 10)
						if (src.reagents.get_reagent_amount(src.reagent_emagged) <= 0)
							src.reagents.add_reagent(src.reagent_emagged, 50)
				else
					if (src.reagents)
						src.reagents.remove_reagent(src.reagent_normal, 10)
						if (src.reagents.get_reagent_amount(src.reagent_normal) <= 0)
							src.reagents.add_reagent(src.reagent_normal, 50)

				if (T.active_liquid)
					if (T.active_liquid.group)
						T.active_liquid.group.drain(T.active_liquid,1,src)

				src.cleaning = 0
				src.icon_state = "[icon_state_base][src.on]"
				src.anchored = 0
				src.target = null
				src.frustration = 0
		return

	ex_act(severity)
		switch (severity)
			if (1.0)
				src.explode()
				return
			if (2.0)
				src.health -= 15
				if (src.health <= 0)
					src.explode()
				return
		return

	meteorhit()
		src.explode()
		return

	blob_act(var/power)
		if (prob(25 * power / 20))
			src.explode()
		return

	explode()
		if (!src)
			return

		if(src.exploding) return
		src.exploding = 1
		src.on = 0
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)

		elecflash(src, radius=1, power=3, exclude_center = 0)

		var/turf/T = get_turf(src)
		if (T && isturf(T))
			new bucket_type_on_destruction(T)
			new /obj/item/device/prox_sensor(T)
			if (prob(50))
				new /obj/item/parts/robot_parts/arm/left(T)

		qdel(src)
		return

	red
		icon_state = "cleanbot-red0"
		idle_delay = 175 // DA RED WUNZ GO FASTA
		bucket_type_on_destruction = /obj/item/reagent_containers/glass/bucket/red

		New()
			name = pick("red cleanbot", "unnaturally red cleanbot", "crimson cleanbot", "battle-hardened cleanbot", "slayer cleanbot", "mess krusha")
			..() // calling parent later in case we add custom-naming functionality for cleanbots like we do for the other ones
