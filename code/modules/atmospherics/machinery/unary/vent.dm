/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "vent-map"
	name = "Vent"
	desc = "A large air vent"
	level = UNDERFLOOR
	plane = PLANE_FLOOR

/obj/machinery/atmospherics/unary/vent/New()
	..()
	src.air_contents.volume = 250

/obj/machinery/atmospherics/unary/vent/process()
	..()

	//stolen from mingle_with_turf WOOHOOH
	var/turf/simulated/ourturf = get_turf(src)

	if(istype(ourturf) && ourturf.parent && ourturf.parent.group_processing)
		//Have to consider preservation of group statuses
		var/datum/gas_mixture/turf_copy = new /datum/gas_mixture

		turf_copy.copy_from(ourturf.parent.air)
		turf_copy.volume = ourturf.parent.air.volume //Copy a good representation of the turf from parent group

		equalize_gases(list(air_contents, turf_copy))

		if(ourturf.parent.air.compare(turf_copy))
			//The new turf would be an acceptable group member so permit the integration

			turf_copy.subtract(ourturf.parent.air)

			ourturf.parent.air.merge(turf_copy)

		else
			//Comparison failure so dissemble group and copy turf

			ourturf.parent.suspend_group_processing()
			ourturf.air.copy_from(turf_copy)
			qdel(turf_copy) // done with this

	else if (istype(ourturf, /turf/space/fluid))
		// build up pressure and then vent it in a bubble
		if (MIXTURE_PRESSURE(src.air_contents) < ONE_ATMOSPHERE)
			return
		var/datum/gas_mixture/bubble_gas = new
		equalize_gases(list(src.air_contents, bubble_gas))
		new /obj/bubble(ourturf, bubble_gas)
	else
		var/datum/gas_mixture/turf_air = ourturf.return_air()

		equalize_gases(list(air_contents, turf_air))

		//turf_air already modified by equalize_gases()

	if(istype(ourturf) && !ourturf.processing)
		if(ourturf.air)
			if(ourturf.air.check_tile_graphic())
				ourturf.update_visuals(ourturf.air)

	if(!isnull(src.network))
		src.network.update = TRUE

/obj/machinery/atmospherics/unary/vent/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/vent/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	src.icon_state = hide_pipe ? "hvent" : "vent"
	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, hide_pipe)
