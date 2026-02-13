
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
		if (!on && !src.input.network)
			boutput(user, SPAN_ALERT("You try to turn on the tap, but nothing's connected to the back!"))
			return
		..()

	actually_drain()
		var/datum/reagents/fluid = src.reagents.remove_any_to(500)
		if(!src.output.push_to_network(src.output.network, fluid))
			fluid.trans_to_direct(src.reagents, fluid.total_volume)
		src.on_reagent_change()

	process()
		if (src.on)
			var/datum/reagents/fluid = src.input.pull_from_network(src.input.network, 150)
			fluid?.trans_to_direct(src.reagents, fluid.total_volume)
			src.input.push_to_network(src.input.network, fluid)
		..()
