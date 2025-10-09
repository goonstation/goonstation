
#define UNWRENCHED 0	//! Defines a machine as being entirely loose. Not wrenched, not welded.
#define WRENCHED 1		//! Defines a machine as being secured to the floor (wrenched), but not welded.
#define WELDED 2		//! Defines a machine as being both secured to the floor (wrenched) and welded.

TYPEINFO(/obj/machinery/field_generator)
	mats = 14

/obj/machinery/field_generator
	name = "field generator"
	desc = "Projects an energy field when active"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Field_Gen"
	anchored = UNANCHORED
	density = 1
	req_access = list(access_engineering_engine)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	appearance_flags = KEEP_TOGETHER
	var/Varedit_start = 0
	var/Varpower = 0
	var/active = 0
	var/power = 20
	var/max_power = 100
	var/state = UNWRENCHED
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = 1
	//Remote control stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	var/active_dirs = 0
	var/shortestlink = 0

	HELP_MESSAGE_OVERRIDE({"In order to be activated, the Field Generator has to be <b>wrenched</b> and <b>welded</b> down first. Once \
							secured, a valid ID has to be swiped to unlock the controls. On activation, the generator will connect to \
							other ones within a cardinal range of 13 tiles."})

	proc/set_active(var/act)
		if (src.active != act)
			src.active = act
			if (src.active)
				event_handler_flags |= IMMUNE_SINGULARITY_INACTIVE
			else
				event_handler_flags &= ~IMMUNE_SINGULARITY_INACTIVE

/obj/machinery/field_generator/attack_hand(mob/user)
	if(state == WELDED)
		if(!src.locked)
			if(src.active >= 1)
				boutput(user, "You are unable to turn off the field generator, wait till it powers down.")
			else
				set_active(1)
				icon_state = "Field_Gen +a"
				boutput(user, "You turn on the field generator.")
				logTheThing(LOG_STATION, user, "activated a [src.name] at [log_loc(src)].") // Hmm (Convair880).
		else
			boutput(user, "The controls are locked!")
	else
		boutput(user, "The field generator needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)

/obj/machinery/field_generator/attack_ai(mob/user as mob)
	if(state == WELDED)
		if(src.active >= 1)
			boutput(user, "You are unable to turn off the field generator, wait till it powers down.")
		else
			src.set_active(1)
			icon_state = "Field_Gen +a"
			boutput(user, "You turn on the field generator.")
			logTheThing(LOG_STATION, user, "activated a [src.name] at [log_loc(src)].") // Hmm (Convair880).
	else
		boutput(user, "The field generator needs to be firmly secured to the floor first.")
	src.add_fingerprint(user)

/obj/machinery/field_generator/New()
	START_TRACKING
	..()
	SPAWN(0.6 SECONDS)
		if(!src.link && (state == WELDED))
			src.get_link()

		src.net_id = format_net_id("\ref[src]")

/obj/machinery/field_generator/disposing()
	STOP_TRACKING
	for(var/dir in cardinal)
		src.cleanup(dir)
	if (link)
		link.master = null
		link = null
	active = FALSE
	. = ..()

/obj/machinery/field_generator/was_deconstructed_to_frame(mob/user)
	. = ..()
	for(var/dir in cardinal)
		src.cleanup(dir)
	active = FALSE
	state = UNWRENCHED
	anchored = UNANCHORED

/obj/machinery/field_generator/can_deconstruct(mob/user)
	. = !active

/obj/machinery/field_generator/process(var/mult)
	if(src.Varedit_start == 1)
		if(src.active == 0)
			src.set_active(1)
			src.state = WELDED
			src.power = 100
			src.anchored = ANCHORED
			icon_state = "Field_Gen +a"
		Varedit_start = 0

	if(src.active == 1)
		if(!src.state == WELDED)
			src.set_active(0)
			return
		setup_field(NORTH)
		setup_field(SOUTH)
		setup_field(EAST)
		setup_field(WEST)
		src.set_active(2)
	src.power = clamp(src.power, 0, src.max_power)
	if(src.active >= 1)
		src.power -= 1 * mult
		if(Varpower == 0)
			if(src.power <= 0)
				src.visible_message(SPAN_ALERT("The [src.name] shuts down due to lack of power!"))
				playsound(src, 'sound/machines/shielddown.ogg', 50, TRUE)
				icon_state = "Field_Gen"
				src.set_active(0)
				src.cleanup(NORTH)
				src.cleanup(SOUTH)
				src.cleanup(EAST)
				src.cleanup(WEST)
				for(var/dir in cardinal)
					src.UpdateOverlays(null, "field_start_[dir]")
					src.UpdateOverlays(null, "field_end_[dir]")
				return

	if (src.active >= 1 && src.power <= 40)
		if (!ON_COOLDOWN(src, "power_alarm", 20 SECONDS + rand(-5 SECONDS, 5 SECONDS))) //stupid rand just to make the alarms go off at slightly different times and not stack up
			playsound(src, 'sound/machines/pod_alarm.ogg', 50, FALSE, pitch = 0.6 + (power/40) * 0.4)
			src.visible_message(SPAN_ALERT("The [src.name] emits a low power warning alarm!"))
		if (!src.GetOverlayImage("amber"))
			src.UpdateOverlays(image(src.icon, "FieldGen_amber", FLOAT_LAYER - 1), "amber")
	else
		src.UpdateOverlays(null, "amber")

/obj/machinery/field_generator/proc/setup_field(var/NSEW = 0)
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/obj/machinery/field_generator/G
	var/steps = 0

	if(!NSEW)//Make sure its ran right
		return
	var/oNSEW = turn(NSEW, 180)

	for(var/dist = 0, dist <= SINGULARITY_MAX_DIMENSION, dist += 1) // checks out to max dimension tiles away for another generator to link to
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		G = locate(/obj/machinery/field_generator) in T
		if(G && G != src && !QDELETED(G))
			steps -= 1
			if(shortestlink==0)
				shortestlink = dist
			else if (shortestlink > dist)
				shortestlink = dist
			if(!G.active)
				return
			if(G.active_dirs & oNSEW)
				return // already active I guess
			break

	if(isnull(G))
		return

	src.UpdateOverlays(image('icons/obj/singularity.dmi', "Contain_F_Start", dir=NSEW, layer=(NSEW == NORTH ? src.layer - 1 : FLOAT_LAYER)), "field_start_[NSEW]")
	G.UpdateOverlays(image('icons/obj/singularity.dmi', "Contain_F_End", dir=NSEW, layer=(NSEW == SOUTH ? src.layer - 1 : FLOAT_LAYER)), "field_end_[NSEW]")

	T2 = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field/(src, G) //(ref to this gen, ref to connected gen)
		CF.set_loc(T)
		CF.set_dir(field_dir)

	active_dirs |= NSEW
	G.active_dirs |= oNSEW

	G.process() // ok, a cool trick / ugly hack to make the direction of the fields nice and consistent in a circle

//Create a link with a data terminal on the same tile, if possible.
/obj/machinery/field_generator/proc/get_link()
	if(src.link)
		src.link.master = null
		src.link = null
	var/turf/T = get_turf(src)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
		src.link = test_link
		src.link.master = src

	return

/obj/machinery/field_generator/bullet_act(var/obj/projectile/P)
	if(!P)
		return
	if(!P.proj_data)
		return
	if(P.proj_data.damage_type == D_ENERGY)
		src.power += P.power
		FLICK("Field_Gen_Flash", src)

/obj/machinery/field_generator/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(active)
			boutput(user, "Turn off the field generator first.")
			return

		else if(state == UNWRENCHED)
			state = WRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			desc = "Projects an energy field when active. It has been bolted to the floor."
			src.anchored = ANCHORED
			return

		else if(state == WRENCHED)
			state = UNWRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			desc = "Projects an energy field when active."
			src.anchored = UNANCHORED
			return

	if(isweldingtool(W))
		if(state != UNWRENCHED)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/field_generator/proc/weld_action, \
						list(user), "[user] finishes using [his_or_her(user)] [W.name] on the field generator.", positions[1], positions[2]),user)
		if(state == WRENCHED)
			boutput(user, "You start to weld the field generator to the floor.")
			return
		else if(state == WELDED)
			boutput(user, "You start to cut the field generator free from the floor.")
			return

	if(ispulsingtool(W))
		boutput(user, SPAN_NOTICE("The [src.name] is at [get_percentage_of_fraction_and_whole(src.power, src.max_power)]% power."))

	var/obj/item/card/id/id_card = get_id_card(W)
	if (istype(id_card))
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			boutput(user, SPAN_ALERT("Access denied."))

	else
		src.add_fingerprint(user)
		boutput(user, SPAN_ALERT("You hit the [src.name] with your [W.name]!"))
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("The [src.name] has been hit with the [W.name] by [user.name]!"))

/obj/machinery/field_generator/proc/get_welding_positions()
	var/start
	var/stop

	start = list(-6,-15)
	stop = list(6,-15)

	if(state == WELDED)
		. = list(stop,start)
	else
		. = list(start,stop)

/obj/machinery/field_generator/proc/weld_action(mob/user)
	if(state == WRENCHED)
		state = WELDED
		src.get_link() //Set up a link, now that we're secure!
		boutput(user, "You weld the field generator to the floor.")
		desc = "Projects an energy field when active. It has been bolted and welded to the floor."
	else if(state == WELDED)
		state = WRENCHED
		if(src.link) //Clear active link.
			src.link.master = null
			src.link = null
		boutput(user, "You cut the field generator free from the floor.")
		desc = "Projects an energy field when active. It has been bolted to the floor."

/obj/machinery/field_generator/proc/cleanup(var/NSEW)
	var/obj/machinery/containment_field/F
	var/obj/machinery/field_generator/G
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/oNSEW = turn(NSEW, 180)

	active_dirs &= ~NSEW

	src.UpdateOverlays(null, "field_start_[NSEW]")
	src.UpdateOverlays(null, "field_end_[oNSEW]")

	for(var/dist = 0, dist <= SINGULARITY_MAX_DIMENSION, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		for(F in T)
			if(F.gen_primary == src || F.gen_secondary == src )
				qdel(F)

		G = locate(/obj/machinery/field_generator) in T
		if(G)
			G.UpdateOverlays(null, "field_end_[NSEW]")
			G.UpdateOverlays(null, "field_start_[oNSEW]")
			G.active_dirs &= ~oNSEW
			if(!G.active)
				break
			else
				G.setup_field(oNSEW)


//Send a signal over our link, if possible.
/obj/machinery/field_generator/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!src.link || !target_id)
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
/obj/machinery/field_generator/receive_signal(datum/signal/signal)
	if(!src.link)
		return
	if(!signal || !src.net_id || signal.encryption)
		return

	/* People might abuse this but I find it funny
	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return
	*/

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "PNET_ENG_FIELD", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	//Oh okay, time to start up.
	if(sigcommand == "activate" && !src.active)
		src.set_active(1)
		icon_state = "Field_Gen +a"

/obj/machinery/field_generator/activated
	Varedit_start = TRUE
	power = 50

/obj/machinery/field_generator/does_impact_particles(kinetic_impact)
	return kinetic_impact

#undef UNWRENCHED
#undef WRENCHED
#undef WELDED
