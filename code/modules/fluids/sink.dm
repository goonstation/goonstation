//machinery kinda, but machinery i dont want the hpd to deconstruct or build

TYPEINFO(/obj/machinery/piped_sink)
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

/obj/machinery/piped_sink
	name = "plumbed sink"
	desc = "Having a much tinier fluid reservoir, this sink refills from piping."
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sink"
	flags = NOSPLASH | ACCEPTS_MOUSEDROP_REAGENTS
	deconstruct_flags = DECON_DESTRUCT
	var/obj/machinery/fluid_machinery/unary/node/input
	var/obj/machinery/fluid_machinery/unary/node/output
	var/datum/reagents/reservoir
	HELP_MESSAGE_OVERRIDE({"Input on the left side, output on the right, facing outwards. Click drag to drain into it."})

	New()
		..()
		src.create_reagents(200)
		src.reservoir = new(400)
		src.reservoir.my_atom = src
		new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, -90)))
		src.input = new /obj/machinery/fluid_machinery/unary/node(src.loc)
		src.input.initialize()
		new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, 90)))
		src.output = new /obj/machinery/fluid_machinery/unary/node(src.loc)
		src.output.initialize()

	disposing()
		src.reagents.trans_to(get_turf(src), src.reagents.maximum_volume)
		src.reservoir.trans_to(get_turf(src), src.reservoir.maximum_volume)
		QDEL_NULL(src.reservoir)
		QDEL_NULL(src.input)
		QDEL_NULL(src.output)
		..()

	was_built_from_frame(mob/user, newly_built)
		..()
		QDEL_NULL(src.input)
		QDEL_NULL(src.output)
		new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, -90)))
		src.input = new /obj/machinery/fluid_machinery/unary/node(src.loc)
		src.input.initialize()
		new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, 90)))
		src.output = new /obj/machinery/fluid_machinery/unary/node(src.loc)
		src.output.initialize()

	process()
		if (src.output.network)
			var/datum/reagents/drained = src.reagents.remove_any_to(src.reagents.total_volume)
			if(!src.output.push_to_network(src.output.network, drained))
				drained.trans_to_direct(src.reagents, drained.total_volume)
		if (src.input.network)
			var/datum/reagents/fluid = src.input.pull_from_network(src.input.network, src.reservoir.maximum_volume)
			fluid?.trans_to_direct(src.reservoir, src.reservoir.maximum_volume)
			src.input.push_to_network(src.input.network, fluid)

	attackby(obj/item/W, mob/user)
		if (src.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("[src] is dry!"))
			return
		if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks) || istype(W, /obj/item/reagent_containers/balloon) || istype(W, /obj/item/soup_pot))
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				boutput(user, SPAN_ALERT("[W] is too full already."))
			else
				fill -= W.reagents.total_volume
				boutput(user, SPAN_NOTICE("You fill [W] with [src.reservoir.trans_to(W, fill)] units of the contents of [src]."))
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 100, 1)
		else if (istype(W, /obj/item/mop)) // dude whatever
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				boutput(user, SPAN_ALERT("[W] is too wet already."))
			else
				fill -= W.reagents.total_volume
				src.reservoir.trans_to(W, fill)
				boutput(user, SPAN_NOTICE("You wet [W]."))
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/GRAB = W
			if (ismob(GRAB.affecting))
				if (GRAB.state >= 1 && istype(GRAB.affecting, /mob/living/critter/small_animal))
					var/mob/M = GRAB.affecting
					var/mob/A = GRAB.assailant
					if (BOUNDS_DIST(src.loc, M.loc) > 0)
						return
					user.visible_message(SPAN_NOTICE("[A] shoves [M] in the sink and starts to wash them."))
					M.set_loc(src.loc)
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					actions.start(new/datum/action/bar/private/critterwashing(A,src,M,GRAB),user)
				else
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					user.visible_message(SPAN_NOTICE("[user] dunks [W:affecting]'s head in the sink!"))
					var/datum/reagents/fluid = src.reservoir.remove_any_to(10)
					if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
						logTheThing(LOG_CHEMISTRY, W:affecting, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
					fluid.reaction(W:affecting, TOUCH, 10)
					fluid.trans_to_direct(src.reagents, fluid.total_volume)
					src.reagents.add_reagent("carbon", 5)
					GRAB.affecting.lastgasp() // --BLUH
		else if (istype(W, /obj/item/gun/sprayer))
			var/obj/item/gun/sprayer/sprayer = W
			sprayer.clogged = FALSE
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			boutput(user, SPAN_NOTICE("You clean out [W]'s nozzle."))
		else if (W.burning)
			W.combust_ended()
		else
			user.visible_message(SPAN_NOTICE("[user] cleans [W]."))
			W.clean_forensic() // There's a global proc for this stuff now (Convair880).
			if (istype(W, /obj/item/device/key/skull))
				W.icon_state = "skull"
			if (istype(W, /obj/item/reagent_containers/mender))
				var/obj/item/reagent_containers/mender/automender = W
				if(automender.borg)
					return
			if (W.reagents && W.is_open_container())
				W.reagents.clear_reagents()		// avoid null error

	MouseDrop_T(obj/item/reagent_containers/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			if(W.current_lid)
				boutput(user, SPAN_ALERT("You cannot transfer liquids from the [W] while it has a lid on it!"))
				return
			if (!W.reagents.total_volume)
				boutput(user, SPAN_ALERT("[W] is empty."))
				return

			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[src] is full."))
				return

			var/trans = W.reagents.trans_to(src, W.reagents.total_volume)
			boutput(user, SPAN_NOTICE("You pour [trans] units of the solution to [src]."))
			logTheThing(LOG_CHEMISTRY, user, "transfers [trans] units from [log_object(W)] [log_reagents(W)] to [log_object(src)] [log_reagents(src)] at [log_loc(src)].") // Added reagents (Convair880).

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		if (src.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("[src] is dry!"))
			return
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
				var/datum/reagents/fluid = src.reservoir.remove_any_to(10)
				if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
					logTheThing(LOG_CHEMISTRY, user, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
				fluid.reaction(user, TOUCH, 10)
				fluid.trans_to_direct(src.reagents, fluid.total_volume)
				QDEL_NULL(fluid)
				src.reagents.add_reagent("carbon", 5)
			else
				if(H.sims?.getValue("Hygiene"))
					if (H.sims.getValue("Hygiene") >= SIMS_HYGIENE_THRESHOLD_MESSY)
						user.visible_message(SPAN_NOTICE("[user] starts washing [his_or_her(user)] hands."))
						actions.start(new/datum/action/bar/private/chemhandwashing(user,src),user)
						return ..()
					else
						boutput(user, SPAN_ALERT("You're too messy to improve your hygiene this way, you need a shower or a bath."))
				//simpler handwashing if hygiene isn't a concern
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
				user.visible_message(SPAN_NOTICE("[user] washes [his_or_her(user)] hands."))
				var/datum/reagents/fluid = src.reservoir.remove_any_to(10)
				if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
					logTheThing(LOG_CHEMISTRY, user, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
				fluid.reaction(user, TOUCH, 10)
				fluid.trans_to_direct(src.reagents, fluid.total_volume)
				QDEL_NULL(fluid)
				src.reagents.add_reagent("carbon", 5)
				H.blood_DNA = null
				H.blood_type = null
				H.forensics_blood_color = null
				H.set_clothing_icon_dirty()
		..()

/datum/action/bar/private/chemhandwashing
	duration = 1 SECOND //roughly matches the rate of manual clicking
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/living/carbon/human/user
	var/obj/machinery/piped_sink/sink

	New(usermob,sink)
		user = usermob
		src.sink = sink
		..()

	proc/checkStillValid()
		if(BOUNDS_DIST(user, sink) > 1 || user == null || sink == null || user.l_hand || user.r_hand || sink.reservoir.total_volume <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if (sink.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("The sink went dry!"))
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
		if (sink.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("The sink's dry!"))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		src.loopStart()


	loopStart()
		..()
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
		var/datum/reagents/fluid = sink.reservoir.remove_any_to(10)
		if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
			logTheThing(LOG_CHEMISTRY, user, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
		fluid.reaction(user, TOUCH, 10)
		fluid.trans_to_direct(sink.reagents, fluid.total_volume)
		QDEL_NULL(fluid)
		sink.reagents.add_reagent("carbon", 5)

	onEnd()
		if(!checkStillValid())
			..()
			return

		var/cleanup_rate = 2

		if(user.traitHolder.hasTrait("training_medical") || user.traitHolder.hasTrait("training_chef"))
			cleanup_rate = 3
		user.sims.affectMotive("Hygiene", cleanup_rate)
		user.blood_DNA = null
		user.blood_type = null
		user.forensics_blood_color = null
		user.set_clothing_icon_dirty()

		src.onRestart()

	onInterrupt()
		..()


/datum/action/bar/private/critterwashingfluid
	duration = 7 DECI SECONDS
	var/mob/living/carbon/human/user
	var/obj/machinery/piped_sink/sink
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
		if (sink.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("The sink went dry!"))
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
		if (sink.reservoir.total_volume <= 0)
			boutput(user, SPAN_ALERT("The sink's dry!"))
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
		var/datum/reagents/fluid = sink.reservoir.remove_any_to(10)
		if (!fluid.has_reagent("water") || length(fluid.reagent_list) >= 2)
			logTheThing(LOG_CHEMISTRY, victim, "is hit by chemicals [log_reagents(fluid)] from a sink at [log_loc(src)].")
		fluid.reaction(victim, TOUCH, 10)
		fluid.trans_to_direct(sink.reagents, fluid.total_volume)
		QDEL_NULL(fluid)
		sink.reagents.add_reagent("carbon", 5)


	onEnd()
		if(!checkStillValid())
			..()
			return
		victim.blood_DNA = null
		victim.blood_type = null
		victim.forensics_blood_color = null
		victim.set_clothing_icon_dirty()

		src.onRestart()
