// WIP bot improvements (Convair880).
#define CLEANBOT_MOVE_SPEED 10
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
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 3 MINUTES // How frequently?

	var/idle = 1 // In relation to world time. In case there aren't any valid targets nearby.
	var/idle_delay = 5 SECONDS // For how long?

	var/cleaning = 0 // Are we currently cleaning something?
	var/reagent_normal = "cleaner"
	var/reagent_emagged = "lube"
	var/list/lubed_turfs = list() // So we don't lube the same turf ad infinitum.
	var/bucket_type_on_destruction = /obj/item/reagent_containers/glass/bucket
	var/static/list/cleanbottargets = list()

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
				src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")

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

		src.KillPathAndGiveUp(1)
		src.icon_state = "[icon_state_base][src.on]"
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
		. = ..()
		if (!src.on)
			return

		if (src.cleaning || src.moving)
			return

		// We're still idling.
		if (src.idle && world.time < src.idle + src.idle_delay)
			return

		// Invalid targets may not be unreachable anymore. Clear list periodically.
		if (src.clear_invalid_targets && world.time > src.clear_invalid_targets + src.clear_invalid_targets_interval)
			src.targets_invalid = list()
			src.lubed_turfs = list()
			src.clear_invalid_targets = world.time

		if (src.frustration >= 8)
			if (src.target && !(src.target in src.targets_invalid))
				src.targets_invalid += src.target
			src.KillPathAndGiveUp(1)

		//mbc : hey i don't feel like fixing this right now, but this shouldn't be a list built each process(). move it to a static list on cleanbot base
		// So nearby bots don't go after the same mess.
		//lagg : k
		if (!src.target || isnull(src.target))
			for (var/obj/machinery/bot/cleanbot/bot in machine_registry[MACHINES_BOTS])
				if (bot != src)
					if (bot.target && !(bot.target in src.cleanbottargets))
						src.cleanbottargets += bot.target

		// Let's find us something to clean.
		if (!src.target || src.target == null)
			if (src.emagged)
				for (var/turf/simulated/floor/F in view(7, src))
					if (F in src.targets_invalid)
						continue
					if (F in src.cleanbottargets)
						continue
					if (F in src.lubed_turfs)
						continue
					for (var/atom/A in F.contents)
						if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
							if (!(F in src.targets_invalid))
								src.targets_invalid += F
							continue
					src.target = F
					break
			else
				for (var/turf/simulated/floor/F in view(7, src))
					if (F in targets_invalid)
						continue
					if (F in cleanbottargets)
						continue

					if (F.messy || F.active_liquid)
						src.target = F
						break

		// Still couldn't find one? Abort and retry later.
		if (!src.target || src.target == null)
			src.KillPathAndGiveUp(1)
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
					src.KillPathAndGiveUp(1)
					return

				if (istype(T, /turf/space))
					if (!(src.target in src.targets_invalid))
						src.targets_invalid += src.target
					src.KillPathAndGiveUp(1)
					return

				for (var/atom/A in T.contents)
					if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
						if (!(src.target in src.targets_invalid))
							src.targets_invalid += src.target
						src.KillPathAndGiveUp(1)
						return

				src.navigate_to(get_turf(src.target), CLEANBOT_MOVE_SPEED, max_dist = 50)

				if (!src.path) // Woops, couldn't find a path.
					if (!(src.target in src.targets_invalid))
						src.targets_invalid += src.target
					src.KillPathAndGiveUp(1)

	DoWhileMoving()
		. = ..()
		if (IN_RANGE(src, src.target, 1))
			src.KillPathAndGiveUp(0)
			actions.start(new/datum/action/bar/icon/cleanbotclean(src, src.target), src)
			return TRUE

	KillPathAndGiveUp(var/give_up)
		. = ..()
		if(give_up)
			src.target = null
			src.idle = world.time

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
		src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
		playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)

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

//////////////////////////////////////
////// Cleanbot Actionbar ////////////
//////////////////////////////////////

/datum/action/bar/icon/cleanbotclean
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "cleanbot_clean"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	var/obj/machinery/bot/cleanbot/master
	var/turf/T

	New(var/obj/machinery/bot/cleanbot/bot, var/turf/target)
		..()
		src.master = bot
		src.T = target

	onStart()
		..()
		if (!master || !T || !isturf(T) || !master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(get_turf(master), "sound/impact_sounds/Liquid_Slosh_2.ogg", 25, 1)
		master.anchored = 1
		master.icon_state = "[master.icon_state_base]-c"
		master.visible_message("<span class='alert'>[master] begins to clean the [T.name].</span>")
		master.cleaning = 1
		master.doing_something = 1

	onUpdate()
		..()
		if (!master || !T || !isturf(T) || !master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		master.cleaning = 0
		master.icon_state = "[master.icon_state_base][master.on]"
		master.anchored = 0
		master.target = null
		master.frustration = 0
		master.doing_something = 0
		. = ..()

	onEnd()
		if (master)
			if (master.reagents)
				master.reagents.reaction(T, 1, 10)

			if (master.emagged)
				if (!(T in master.lubed_turfs))
					master.lubed_turfs += T
				if (master.reagents) // ZeWaka: Fix for null.remove_reagent()
					master.reagents.remove_reagent(master.reagent_emagged, 10)
					if (master.reagents.get_reagent_amount(master.reagent_emagged) <= 0)
						master.reagents.add_reagent(master.reagent_emagged, 50)
			else
				if (master.reagents)
					master.reagents.remove_reagent(master.reagent_normal, 10)
					if (master.reagents.get_reagent_amount(master.reagent_normal) <= 0)
						master.reagents.add_reagent(master.reagent_normal, 50)

			if (T.active_liquid)
				if (T.active_liquid.group)
					T.active_liquid.group.drain(T.active_liquid,1,master)

			master.cleaning = 0
			master.icon_state = "[master.icon_state_base][master.on]"
			master.anchored = 0
			master.target = null
			master.frustration = 0
			master.doing_something = 0
		..()

#undef CLEANBOT_MOVE_SPEED
