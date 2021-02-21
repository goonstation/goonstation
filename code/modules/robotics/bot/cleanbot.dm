// WIP bot improvements (Convair880).
#define CLEANBOT_MOVE_SPEED 10
#define CLEANBOT_CLEARTARGET_COOLDOWN "cleanbotclearinvalidtargetslist"
#define CLEANBOT_CLEAN_COOLDOWN "slackbotidle"
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
	bot_move_delay = CLEANBOT_MOVE_SPEED

	var/atom/target // Current target.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 5 MINUTES // How frequently?

	var/idle_delay = 2 SECONDS // For how long?

	var/cleaning = 0 // Are we currently cleaning something?
	var/reagent_normal = "cleaner"
	var/reagent_emagged = "lube"
	var/bucket_type_on_destruction = /obj/item/reagent_containers/glass/bucket
	var/search_range = 1
	var/max_search_range = 7
	/// Favor scanning from this spot, so that they'll tend to build out from here, and not just a bunch of metal spaghetti
	var/turf/scan_origin
	/// They're designed to work best while nobody's looking
	dynamic_processing = 0
	PT_idle = PROCESSING_QUARTER

	//mbc : hey i don't feel like fixing this right now, but this shouldn't be a list built each process(). move it to a static list on cleanbot base
	// So nearby bots don't go after the same mess.
	//lagg : k
	var/static/list/cleanbottargets = list()

	New()
		..()
		icon_state_base = copytext(icon_state, 1, -1)
		src.add_simple_light("bot", list(255, 255, 255, 255 * 0.4))

		SPAWN_DBG(0.5 SECONDS)
			if (src)
				src.clear_invalid_targets = TIME

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
		src.clear_invalid_targets = TIME

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
		if (!issilicon(usr) && !in_interact_range(src, usr)) return

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
		if (!src.on || src.cleaning || src.moving && GET_COOLDOWN(src, CLEANBOT_CLEAN_COOLDOWN))
			return

		// Invalid targets may not be unreachable anymore. Clear list periodically.
		if (src.clear_invalid_targets && !ON_COOLDOWN(src, CLEANBOT_CLEARTARGET_COOLDOWN, src.clear_invalid_targets_interval))
			src.targets_invalid = list()
			src.cleanbottargets = list() // if 5 minutes have gone by and jim still hasnt cleaned up the floor, I dont think they're gonna

		if (!src.target)
			if(!src.scan_origin || !isturf(src.scan_origin))
				src.scan_origin = get_turf(src)
			src.target = src.find_target()
			src.doing_something = 0

		if (src.target)
			src.point(src.target)
			src.doing_something = 1

			// are we there yet
			if (IN_RANGE(src, src.target, 1))
				do_the_thing()
				return

			// we are not there. how do we get there
			if (!src.path || !src.path.len)
				src.navigate_to(get_turf(src.target), CLEANBOT_MOVE_SPEED, max_dist = 120)
				if (!src.path || !src.path.len)
					// answer: we don't. try to find something else then.
					src.KillPathAndGiveUp(1)
		else // No targets found in range? Increase the range!
			if(src.search_range++ > src.max_search_range) // No targets in our max range? Move our origin here and scan some more!
				src.KillPathAndGiveUp(1)
				src.scan_origin = get_turf(src)
		if(frustration >= 8)
			src.KillPathAndGiveUp(1)

	proc/do_the_thing()
		// we are there, hooray
		if (prob(80))
			src.visible_message("[src] sloshes.")
		actions.start(new/datum/action/bar/icon/cleanbotclean(src, src.target), src)

	proc/find_target()
		for (var/turf/simulated/floor/F in view(src.search_range, src.scan_origin))
			var/coord = turf2coordinates(F)
			if ((coord in src.cleanbottargets) || (coord in src.targets_invalid))
				continue
			if (src.is_it_invalid(F))
				continue
			if (src.emagged && F.wet)
				continue
			if (!F.messy && !F.active_liquid)
				continue
			src.cleanbottargets += coord
			return F

	proc/is_it_invalid(var/turf/simulated/floor/F)
		var/coords = turf2coordinates(F)
		for (var/atom/A in F.contents)
			if (A.density && !(A.flags & ON_BORDER) && !istype(A, /obj/machinery/door) && !ismob(A))
				if (!(coords in src.targets_invalid))
					src.targets_invalid += coords
				return 1

			if (!F || !isturf(F) || F.density)
				if (!(coords in src.targets_invalid))
					src.targets_invalid += coords
				return 1

			if (istype(F, /turf/space))
				if (!(coords in src.targets_invalid))
					src.targets_invalid += coords
				return 1

	KillPathAndGiveUp(var/give_up)
		. = ..()
		var/coords = turf2coordinates(get_turf(src.target))
		if(give_up)
			if (src.target && !(coords in src.targets_invalid))
				src.targets_invalid += coords
			src.search_range = 1
			src.scan_origin = null
		src.cleaning = 0
		src.icon_state = "[src.icon_state_base][src.on]"
		src.cleanbottargets -= coords
		src.target = null
		src.anchored = 0


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
		master.cleanbottargets -= master.turf2coordinates(get_turf(master.target))
		master.KillPathAndGiveUp(1)
		. = ..()

	onEnd()
		if (master)
			if (master.reagents)
				master.reagents.reaction(T, 1, 10)

			if (master.emagged)
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

			master.cleanbottargets -= master.turf2coordinates(get_turf(master.target))
			ON_COOLDOWN(master, CLEANBOT_CLEAN_COOLDOWN, master.idle_delay)
			master.KillPathAndGiveUp(0)
		..()

#undef CLEANBOT_MOVE_SPEED
