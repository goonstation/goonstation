
#define UNWRENCHED 0	/// Defines a machine as being entirely loose. Not wrenched, not welded.
#define WRENCHED 1		/// Defines a machine as being secured to the floor (wrenched), but not welded.
#define WELDED 2		/// Defines a machine as being both secured to the floor (wrenched) and welded.

TYPEINFO(/obj/machinery/emitter)
	mats = 10

/obj/machinery/emitter
	name = "\improper Emitter"
	desc = "Shoots a high power laser when active"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Emitter"
	anchored = UNANCHORED
	density = 1
	req_access = list(access_engineering_engine)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	var/active = 0
	var/power = 20
	var/fire_delay = 100
	var/HP = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = UNWRENCHED
	var/locked = 1
	var/emagged = FALSE
	//Remote control stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	var/datum/projectile/current_projectile = new/datum/projectile/laser/heavy

	HELP_MESSAGE_OVERRIDE({"The Emitter shoots laser bolts at Containment Field Generators to power them. Has to be \
							<b>wrenched</b> and <b>welded</b> down before being useable. The control systems must be unlocked \
							with a valid ID in order to activate the Emitter."})

/obj/machinery/emitter/New()
	..()
	SPAWN(0.6 SECONDS)
		if(!src.link && (state == WELDED))
			src.get_link()

		src.net_id = format_net_id("\ref[src]")

/obj/machinery/emitter/can_deconstruct(mob/user)
	. = !active

/obj/machinery/emitter/was_deconstructed_to_frame(mob/user)
	. = ..()
	active = FALSE
	state = UNWRENCHED
	anchored = UNANCHORED

//Create a link with a data terminal on the same tile, if possible.
/obj/machinery/emitter/proc/get_link()
	if(src.link)
		src.link.master = null
		src.link = null
	var/turf/T = get_turf(src)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
		src.link = test_link
		src.link.master = src

	return

/obj/machinery/emitter/proc/set_active(var/turn_on, var/check_lock, mob/user)
	if(user)
		if(state != WELDED)
			boutput(user, "The emitter needs to be firmly secured to the floor first.")
			return FALSE
		if(!in_interact_range(src, user))
			boutput(user, "You are too far away to reach the emitter's controls.")
			return FALSE
	if(check_lock && src.locked)
		boutput(user, "The controls are locked!")
		return FALSE
	if(turn_on && !src.active)
		src.active = TRUE
		icon_state = "Emitter +a"
		boutput(user, "You turn on the emitter.")
		logTheThing(LOG_STATION, user, "activated emitter at [log_loc(src)].")
		src.shot_number = 0
		src.fire_delay = 100
		if(user)
			message_admins("[key_name(user)] activated emitter at [log_loc(src)].")
		return TRUE
	else if(!turn_on && src.active)
		src.active = FALSE
		icon_state = "Emitter"
		boutput(user, "You turn off the emitter.")
		logTheThing(LOG_STATION, user, "deactivated active emitter at [log_loc(src)].")
		if(user)
			message_admins("[key_name(user)] deactivated active emitter at [log_loc(src)].")
		return TRUE
	return FALSE

/obj/machinery/emitter/attack_hand(mob/user)
	if(state == WELDED)
		if(!src.locked)
			if(src.active)
				if(tgui_alert(user, "Turn off the emitter?", "Emitter controls", list("Yes", "No")) == "Yes")
					src.set_active(FALSE, TRUE, user)
			else
				if(tgui_alert(user, "Turn on the emitter?", "Emitter controls", list("Yes", "No")) == "Yes")
					src.set_active(TRUE, TRUE, user)
		else
			boutput(user, "The controls are locked!")
	else
		boutput(user, "The emitter needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)
	..()

/obj/machinery/emitter/attack_ai(mob/user as mob)
	if (src.emagged)
		boutput(user, SPAN_NOTICE("Unable to interface with [src]!"))
		return
	if(state == WELDED)
		if(src.active)
			if(tgui_alert(user, "Turn off the emitter?","Switch",list("Yes","No")) == "Yes")
				src.set_active(FALSE, FALSE, user)
		else
			if(tgui_alert(user, "Turn on the emitter?","Switch",list("Yes","No")) == "Yes")
				src.set_active(TRUE, FALSE, user)
	else
		boutput(user, "The emitter needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)
	return

/obj/machinery/emitter/process()

	if(status & (NOPOWER|BROKEN))
		return

	if(src.active && (src.state != WELDED))
		src.set_active(FALSE, FALSE, user = null)
		return

	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active))
		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(20,100)
			src.shot_number = 0

		if (!is_cardinal(src.dir)) // Not cardinal (not power of 2)
			src.dir &= 12 // Cardinalize

		src.visible_message(SPAN_ALERT("<b>[src]</b> fires a bolt of energy!"))

		shoot_projectile_DIR(src, current_projectile, dir)
		var/horizontal_offset = (src.dir in list(EAST, WEST)) ? 10 : 0 //offset by 10 pixels if we're firing to the side otherwise it looks weird
		muzzle_flash_any(src, dir_to_angle(dir), "muzzle_flash_plaser", horizontal_offset = horizontal_offset)
		use_power(current_projectile.power)

		if(prob(35))
			elecflash(src)
	..()

/obj/machinery/emitter/attackby(obj/item/W, mob/user)
	if (ispryingtool(W))
		if(!anchored)
			src.set_dir(turn(src.dir, -90))
			return
		else
			boutput(user, "The emitter is too firmly secured to be rotated!")
			return
	else if (iswrenchingtool(W))
		if(active)
			boutput(user, "Turn off the emitter first.")
			return

		else if(state == UNWRENCHED)
			state = WRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = ANCHORED
			desc = "Shoots a high power laser when active, it has been bolted to the floor."
			return

		else if(state == WRENCHED)
			state = UNWRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			src.anchored = UNANCHORED
			desc = "Shoots a high power laser when active."
			return

	if(isweldingtool(W))
		if(state != UNWRENCHED)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/emitter/proc/weld_action, \
						list(user), "[user] finishes using [his_or_her(user)] [W.name] on the emitter.", positions[1], positions[2]),user)
		if(state == WRENCHED)
			boutput(user, "You start to weld the emitter to the floor.")
			return
		else if(state == WELDED)
			boutput(user, "You start to cut the emitter free from the floor.")
			return

	var/obj/item/card/id/id_card = get_id_card(W)
	if (istype(id_card) && length(src.req_access))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			if (!src.locked)
				logTheThing(LOG_STATION, user, "unlocked emitter at at [log_loc(src)].")
		else
			boutput(user, SPAN_ALERT("Access denied."))

	else
		src.add_fingerprint(user)
		boutput(user, SPAN_ALERT("You hit the [src.name] with your [W.name]!"))
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("The [src.name] has been hit with the [W.name] by [user.name]!"))

/obj/machinery/emitter/proc/get_welding_positions()
	var/start
	var/stop
	if(dir & (NORTH|SOUTH))
		start = list(-10,-7)
		stop = list(10,-7)
	else
		start = list(-10,-14)
		stop = list(10,-14)

	if(state == WELDED)
		. = list(stop,start)
	else
		. = list(start,stop)


/obj/machinery/emitter/proc/weld_action(mob/user)
	if(state == WRENCHED)
		state = WELDED
		src.get_link()
		desc = "Shoots a high power laser when active, it has been bolted and welded to the floor."
		boutput(user, "You weld the emitter to the floor.")
		logTheThing(LOG_STATION, user, "welds an emitter to the floor at [log_loc(src)].")
	else if(state == WELDED)
		state = WRENCHED
		if(src.link) //Time to clear our link.
			src.link.master = null
			src.link = null
		desc = "Shoots a high power laser when active, it has been bolted to the floor."
		boutput(user, "You cut the emitter free from the floor.")
		logTheThing(LOG_STATION, user, "unwelds an emitter from the floor at [log_loc(src)].")

//Send a signal over our link, if possible.
/obj/machinery/emitter/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!src.link || src.emagged || !target_id)
		return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = TRANSMISSION_WIRE
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	signal.data["address_1"] = target_id
	signal.data["sender"] = src.net_id

	src.link.post_signal(src, signal)

//What do we do with an incoming command?
/obj/machinery/emitter/receive_signal(datum/signal/signal)
	if(!src.link || src.emagged)
		return
	if(!signal || !src.net_id || signal.encryption)
		return


	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "PNET_ENG_EMITR", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	//Oh okay, time to start up.
	if(sigcommand == "activate" && !src.active)
		src.set_active(TRUE, FALSE, user = null)
	//oh welp shutdown time.
	else if(sigcommand == "deactivate" && src.active)
		src.set_active(FALSE, FALSE, user = null)

	return

/obj/machinery/emitter/emag_act(mob/user, obj/item/card/emag/E)
	if (!src.emagged)
		boutput(user, SPAN_ALERT("\The [src] shorts out its remote connectivity controls!"))
		src.emagged = TRUE

/obj/machinery/emitter/demag(mob/user)
	. = ..()
	if (src.emagged)
		src.emagged = FALSE

/obj/machinery/emitter/assault
	name = "prototype assault emitter"
	desc = "Shoots a VERY high power laser when active. The ID lock appears to have been messily smashed off."
	current_projectile = new/datum/projectile/laser/asslaser
	locked = FALSE
	fire_delay = 30
	req_access = list()
	HELP_MESSAGE_OVERRIDE({"The Emitter shoots assault lasers at <s>Containment Field Generators</s> just about anything! Has to be \
							<b>wrenched</b> and <b>welded</b> down before being useable."})

	attack_ai(mob/user)
		return

	receive_signal(datum/signal/signal)
		return

#undef UNWRENCHED
#undef WRENCHED
#undef WELDED
