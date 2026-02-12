
/obj/machinery/bathtub/piped
	name = "bathtub"
	desc = "Now, that looks cosy! You can actually see where it drains to!"
	icon = 'icons/obj/fluidpipes/bathtub.dmi'
	flags = OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	default_reagent = null
	var/obj/machinery/fluid_machinery/unary/node/input
	var/obj/machinery/fluid_machinery/unary/node/output
	HELP_MESSAGE_OVERRIDE("Input on faucet side. Drain always points south.")

	New()
		..()
		if (src.dir == NORTH) src.dir = SOUTH
		new /dmm_suite/preloader(src.loc, list("dir" = turn(src.dir, -180)))
		src.input = new /obj/machinery/fluid_machinery/unary/node(src.loc)
		src.input.initialize()
		src.output = new /obj/machinery/fluid_machinery/unary/node{dir = SOUTH}(src.loc)
		src.output.initialize()

	disposing()
		src.reagents.trans_to(get_turf(src), src.reagents.maximum_volume)
		QDEL_NULL(src.input)
		QDEL_NULL(src.output)
		..()

	turn_tap(mob/user)
		src.add_fingerprint(user)
		if (on)
			user.visible_message(SPAN_NOTICE("[user] turns off the bathtub's tap."), SPAN_NOTICE("You turn off the bathtub's tap."))
			playsound(src.loc, 'sound/effects/valve_creak.ogg', 30, 2)
			on = FALSE
		else
			if(src.reagents.is_full())
				boutput(user, SPAN_ALERT("The tub is already full!"))
			else
				if (!src.input.network)
					boutput(user, SPAN_ALERT("You try to turn on the tap, but nothing's connected to the back!"))
					return
				user.visible_message(SPAN_NOTICE("[user] turns on the bathtub's tap."), SPAN_NOTICE("You turn on the bathtub's tap."))
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 60, 4)
				src.on_reagent_change()
				on = TRUE

	drain_bathtub(mob/user)
		src.add_fingerprint(user)
		if (GET_DIST(user, src) <= 1 && !is_incapacitated(user))
			if (src.reagents.total_volume)
				user.visible_message(SPAN_NOTICE("[user] reaches into the bath and pulls the plug."), SPAN_NOTICE("You reach into the bath and pull the plug."))
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if(!H.gloves)
						reagents.reaction(H, TOUCH, 5)

				var/datum/reagents/fluid = src.reagents.remove_any_to(500)
				if(!src.output.push_to_network(src.output.network, fluid))
					fluid.trans_to_direct(src.reagents, fluid.total_volume)
				playsound(src.loc, 'sound/misc/drain_glug.ogg', 70, 1)
				src.on_reagent_change()

				var/count = 0
				// TODO: Connect to disposals
				for (var/obj/O in src)
					count++
					qdel(O)
				if (count > 0)
					user.visible_message(SPAN_ALERT("...and something flushes down the drain. Damn!"), SPAN_ALERT("...and flushes something down the drain. Damn!"))
			else
				boutput(user, SPAN_NOTICE("The bathtub's already empty."))

	process()
		if (src.on)
			var/datum/reagents/fluid = src.input.pull_from_network(src.input.network, 150)
			fluid?.trans_to_direct(src.reagents, fluid.total_volume)
			src.input.push_to_network(src.input.network, fluid)
			if (src.default_reagent)
				src.reagents.add_reagent(src.default_reagent, 50)
			src.on_reagent_change()
			if (src.reagents.is_full())
				src.visible_message(SPAN_NOTICE("As \the [src] finishes filling, the tap shuts off automatically."))
				playsound(src.loc, 'sound/misc/pourdrink2.ogg', 60, 5)
				src.on = FALSE
		if (src.occupant)
			if(src.occupant.loc != src)
				src.occupant.pixel_y = 0
				src.occupant = null
				src.on_reagent_change()
				return
			if(src.reagents.total_volume)
				// copied from fluid_core.dm
				var/react_volume = src.reagents.total_volume > 10 ? (src.reagents.total_volume / 2) : (src.reagents.total_volume)
				react_volume = min(react_volume, 100) //capping the react amt
				var/list/reacted_ids = src.reagents.reaction(src.occupant, TOUCH, react_volume)
				var/volume_fraction = src.reagents.total_volume ? (react_volume / src.reagents.total_volume) : 0

				for(var/current_id in reacted_ids)
					var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
					if (!current_reagent)
						continue
					src.reagents.remove_reagent(current_id, current_reagent.volume * volume_fraction)
