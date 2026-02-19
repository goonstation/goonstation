TYPEINFO(/obj/machinery/sink)
	mats = 12

/obj/machinery/sink
	name = "sink"
	desc = "A water-filled unit intended for cookery purposes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	anchored = ANCHORED
	density = TRUE
	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_DESTRUCT
	flags = NOSPLASH

/obj/machinery/sink/proc/get_fluid(amount)
	var/datum/reagents/fluid = new(amount)
	fluid.add_reagent("water", amount)
	return fluid

/obj/machinery/sink/proc/transfer_fluid(atom/A, amount)
	var/datum/reagents/fluid = src.get_fluid(amount)
	. = fluid.trans_to(A, amount)
	qdel(fluid)

/obj/machinery/sink/proc/fluid_remaining()
	return INFINITY

/obj/machinery/sink/proc/drain_fluid(datum/reagents/fluid, amount)
	return fluid.remove_any(amount)

/obj/machinery/sink/attackby(obj/item/W, mob/user)
	if (src.fluid_remaining() <= CHEM_EPSILON)
		boutput(user, SPAN_ALERT("Nothing comes out of [src]!"))
		return

	if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks) || istype(W, /obj/item/reagent_containers/balloon) || istype(W, /obj/item/soup_pot))
		if (W.reagents.total_volume >= W.reagents.maximum_volume)
			boutput(user, SPAN_ALERT("[W] is too full already."))
		else
			boutput(user, SPAN_NOTICE("You fill [W] with [src.transfer_fluid(W, W.reagents.maximum_volume-W.reagents.total_volume)] units of the contents of [src]."))
			playsound(src.loc, 'sound/misc/pourdrink.ogg', 100, 1)
	else if (istype(W, /obj/item/mop)) // dude whatever
		if (W.reagents.total_volume >= W.reagents.maximum_volume)
			boutput(user, SPAN_ALERT("[W] is too wet already."))
		else
			src.transfer_fluid(W,  W.reagents.maximum_volume-W.reagents.total_volume)
			boutput(user, SPAN_NOTICE("You wet [W]."))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
	else if (istype(W, /obj/item/grab))
		var/obj/item/grab/GRAB = W
		if (ismob(GRAB.affecting))
			var/mob/living/M = GRAB.affecting
			var/mob/living/A = GRAB.assailant
			if (GRAB.state >= 1 && istype(M, /mob/living/critter/small_animal))
				if (BOUNDS_DIST(src.loc, M.loc) > 0)
					return
				user.visible_message(SPAN_NOTICE("[A] shoves [M] in the sink and starts to wash them."))
				M.set_loc(src.loc)
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
				actions.start(new/datum/action/bar/private/critterwashing(A,src,M,GRAB),user)
			else
				if (!M.organHolder?.head)
					user.visible_message(SPAN_NOTICE("[A] tries to dunk [M]'s head in the sink, but [M] has no head to dunk!"))
					return
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
				user.visible_message(SPAN_NOTICE("[A] dunks [M]'s head in the sink!"))
				var/datum/reagents/fluid = src.get_fluid(30) // i YEARN for your pain when acid
				fluid.reaction(GRAB.affecting, TOUCH, 30)
				if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
					logTheThing(LOG_COMBAT, M, "[log_health(M)] is dunked into a sink [log_reagents(fluid)] [log_loc(src)] by [constructTarget(A, "combat")].")
				src.drain_fluid(fluid, fluid.total_volume)
				qdel(fluid)
				GRAB.affecting.lastgasp(grunt = pick("GLUB", "blblbl", "BLUH", "BLURGH")) // --BLUH
	else if (istype(W, /obj/item/gun/sprayer))
		var/obj/item/gun/sprayer/sprayer = W
		sprayer.clogged = FALSE
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		boutput(user, SPAN_NOTICE("You clean out [W]'s nozzle."))
	else
		var/datum/reagents/fluid = src.get_fluid(30)
		fluid.reaction(W, TOUCH)
		src.drain_fluid(fluid, fluid.total_volume)
		qdel(fluid)

		user.visible_message(SPAN_NOTICE("[user] washes [W]."))
		W.clean_forensic() // There's a global proc for this stuff now (Convair880).
		if (istype(W, /obj/item/device/key/skull))
			W.icon_state = "skull"
		if (istype(W, /obj/item/reagent_containers/mender))
			var/obj/item/reagent_containers/mender/automender = W
			if(automender.borg)
				return
		if (W.reagents && W.is_open_container())
			src.drain_fluid(W.reagents, W.reagents.total_volume)

/obj/machinery/sink/MouseDrop_T(obj/item/reagent_containers/W as obj, mob/user as mob)
	if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
		if(W.current_lid)
			boutput(user, SPAN_ALERT("You cannot transfer liquids from the [W] while it has a lid on it!"))
			return
		if (!W.reagents.total_volume)
			boutput(user, SPAN_ALERT("[W] is empty."))
			return

		logTheThing(LOG_CHEMISTRY, user, "pours chemicals from [log_object(W)] [log_reagents(W)] to [log_object(src)] at [log_loc(src)].")
		var/trans = src.drain_fluid(W.reagents, W.reagents.total_volume)
		if (trans <= CHEM_EPSILON)
			boutput(user, SPAN_ALERT("You couldn't pour any more fluid down [src]!"))
			return

		boutput(user, SPAN_NOTICE("You pour [trans] units of the solution down [src]."))
		playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

/obj/machinery/sink/attack_hand(var/mob/user)
	src.add_fingerprint(user)
	user.lastattacked = get_weakref(src)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.gloves)
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			user.visible_message(SPAN_NOTICE("[user] cleans [his_or_her(user)] gloves."))
			if (H.sims?.getValue("Hygiene"))
				boutput(user, SPAN_NOTICE("If you want to improve your hygiene, you need to remove your gloves first."))
			H.gloves.clean_forensic() // Ditto (Convair880).
			H.set_clothing_icon_dirty()
			var/datum/reagents/fluid = src.get_fluid(30)
			fluid.reaction(H.gloves, TOUCH)
			src.drain_fluid(fluid, fluid.total_volume)
			qdel(fluid)
		else
			if(H.sims?.getValue("Hygiene"))
				if (H.sims.getValue("Hygiene") >= SIMS_HYGIENE_THRESHOLD_MESSY)
					user.visible_message(SPAN_NOTICE("[user] starts washing [his_or_her(user)] hands."))
					actions.start(new/datum/action/bar/private/handwashing(user,src),user)
					return ..()
				else
					boutput(user, SPAN_ALERT("You're too messy to improve your hygiene this way, you need a shower or a bath."))
			//simpler handwashing if hygiene isn't a concern
			var/datum/reagents/fluid = src.get_fluid(30)
			fluid.reaction(user, TOUCH)
			if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
				logTheThing(LOG_CHEMISTRY, user, " [log_health(user)] is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
			fluid.remove_any(3)
			fluid.add_reagent("carbon", 3)
			src.drain_fluid(fluid, fluid.total_volume)
			qdel(fluid)
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
			user.visible_message(SPAN_NOTICE("[user] washes [his_or_her(user)] hands."))
			H.clean_forensic()
	..()


/obj/machinery/sink/slim
	name = "sink"
	desc = "A slim water-filled unit intended for hand-washing purposes."
	density = FALSE
	layer = ABOVE_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sink"

/datum/action/bar/private/handwashing
	duration = 1 SECOND //roughly matches the rate of manual clicking
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/living/carbon/human/user
	var/obj/machinery/sink/sink

	New(usermob,sink)
		user = usermob
		src.sink = sink
		..()

	proc/checkStillValid()
		if(BOUNDS_DIST(user, sink) > 1 || QDELETED(user) || QDELETED(sink) || user.l_hand || user.r_hand)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if (sink.fluid_remaining() <= CHEM_EPSILON)
			boutput(user, SPAN_ALERT("Nothing comes out of the sink!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE

	onUpdate()
		checkStillValid()
		..()

	onStart()
		..()
		if(BOUNDS_DIST(user, sink) > 1)
			boutput(user, SPAN_ALERT("You're too far from the sink!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if(user.l_hand || user.r_hand)
			boutput(user, SPAN_ALERT("Both your hands need to be free to wash them!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if (sink.fluid_remaining() <= CHEM_EPSILON)
			boutput(user, SPAN_ALERT("Nothing comes out of the sink!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		src.loopStart()


	loopStart()
		..()
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
		var/datum/reagents/fluid = sink.get_fluid(30)
		if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
			logTheThing(LOG_CHEMISTRY, user, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
		fluid.reaction(user, TOUCH)
		if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
			logTheThing(LOG_CHEMISTRY, user, " [log_health(user)] is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
		fluid.remove_any(3)
		fluid.add_reagent("carbon", 3)
		sink.drain_fluid(fluid, fluid.total_volume)
		QDEL_NULL(fluid)

	onEnd()
		if(!checkStillValid())
			..()
			return

		var/cleanup_rate = 2

		if(user.traitHolder.hasTrait("training_medical") || user.traitHolder.hasTrait("training_chef"))
			cleanup_rate = 3
		user.sims.affectMotive("Hygiene", cleanup_rate)
		user.clean_forensic()

		src.onRestart()

	onInterrupt()
		..()


/datum/action/bar/private/critterwashing
	duration = 7 DECI SECONDS
	var/mob/living/carbon/human/user
	var/obj/machinery/sink/sink
	var/mob/living/critter/small_animal/victim
	var/obj/item/grab/grab
	var/datum/aiTask/timed/wandering
	New(usermob,sink,critter,thegrab)
		src.user = usermob
		src.sink = sink
		src.victim = critter
		src.grab = thegrab
		..()

	proc/checkStillValid()
		if(GET_DIST(victim, sink) > 0 || BOUNDS_DIST(user, sink) > 1 || victim == null || user == null || sink == null || !grab)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if (sink.fluid_remaining() <= CHEM_EPSILON)
			boutput(user, SPAN_ALERT("Nothing comes out of the sink!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE
	onStart()
		if(BOUNDS_DIST(user, sink) > 1) boutput(user, SPAN_ALERT("You're too far from the sink!"))
		if (istype(victim, /mob/living/critter/small_animal/cat) && victim.ai?.enabled)
			victim._ai_patience_count = 0
			victim.was_harmed(user)
			victim.visible_message(SPAN_NOTICE("[victim] resists [user]'s attempt to wash them!"))
			playsound(victim.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)

		else if (victim.ai?.enabled && istype(victim.ai.current_task, /datum/aiTask/timed/wander) )
			victim.ai.wait(5)
		if (sink.fluid_remaining() <= CHEM_EPSILON)
			boutput(user, SPAN_ALERT("Nothing comes out of the sink!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		..()

	loopStart()
		..()
		if (!checkStillValid())
			return
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
		if(prob(50))
			animate_door_squeeze(victim)
		else
			animate_smush(victim, 0.65)
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)

		var/datum/reagents/fluid = sink.get_fluid(30)
		fluid.reaction(victim, TOUCH)
		if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
			logTheThing(LOG_COMBAT, victim, "[log_health(victim)] is dunked into a sink [log_reagents(fluid)] [log_loc(src)] by [constructTarget(user, "combat")].")
		fluid.remove_any(3)
		fluid.add_reagent("carbon", 3)
		sink.drain_fluid(fluid, fluid.total_volume)
		QDEL_NULL(fluid)


	onEnd()
		if(!checkStillValid())
			..()
			return
		victim.clean_forensic()
		src.onRestart()


TYPEINFO(/obj/machinery/sink/piped)
	can_build(turf/T, direction)
		var/obj/fluid_pipe/fluidthingy
		switch(direction)
			if(NORTH, SOUTH)
				direction = EAST|WEST
			if(EAST, WEST)
				direction = SOUTH|NORTH

		for(var/obj/device in T)
			if(!istype(device, /obj/fluid_pipe) && !istype(device, /obj/machinery/fluid_machinery))
				continue
			fluidthingy = device
			if((fluidthingy.initialize_directions & direction))
				return FALSE
		return TRUE

/obj/machinery/sink/piped
	name = "plumbed sink"
	desc = "A sink unit connected to plumbing."
	var/obj/machinery/fluid_machinery/unary/node/input
	var/obj/machinery/fluid_machinery/unary/node/output
	var/datum/reagents/drainage
	HELP_MESSAGE_OVERRIDE("Input on the left side, output on the right.")

/obj/machinery/sink/piped/get_fluid(amount)
	return (src.reagents.remove_any_to(amount) || new /datum/reagents(amount))

/obj/machinery/sink/piped/fluid_remaining()
	return src.reagents.total_volume

/obj/machinery/sink/piped/drain_fluid(datum/reagents/fluid, amount)
	return fluid.trans_to_direct(src.drainage, amount)

/obj/machinery/sink/piped/New()
	..()
	src.create_reagents(800)
	src.drainage = new(400)
	src.drainage.my_atom = src
	new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, -90)))
	src.input = new /obj/machinery/fluid_machinery/unary/node(src.loc)
	src.input.initialize()
	new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, 90)))
	src.output = new /obj/machinery/fluid_machinery/unary/node(src.loc)
	src.output.initialize()

/obj/machinery/sink/piped/disposing()
	src.reagents.trans_to(get_turf(src), src.reagents.maximum_volume)
	src.drainage.trans_to(get_turf(src), src.drainage.maximum_volume)
	QDEL_NULL(src.drainage)
	QDEL_NULL(src.input)
	QDEL_NULL(src.output)
	..()

/obj/machinery/sink/piped/was_built_from_frame(mob/user, newly_built)
	..()
	src.input.refresh_network()
	src.output.refresh_network()

/obj/machinery/sink/piped/process()
	..()
	if (src.output.network)
		var/datum/reagents/drained = src.drainage.remove_any_to(src.reagents.total_volume)
		if(!src.output.push_to_network(src.output.network, drained))
			drained.trans_to_direct(src.drainage, drained.total_volume)
	if (src.input.network)
		var/datum/reagents/fluid = src.input.pull_from_network(src.input.network, src.reagents.maximum_volume)
		fluid?.trans_to(src, fluid.total_volume)
		src.input.push_to_network(src.input.network, fluid)

/obj/machinery/sink/piped/slim
	name = "plumbed sink"
	desc = "A slim sink unit connected to plumbing. Has a smaller reservoir and drainage."
	density = FALSE
	layer = ABOVE_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sink"

/obj/machinery/sink/piped/slim/New()
	..()
	src.reagents.maximum_volume = 400
	src.drainage.maximum_volume = 200

