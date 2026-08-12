/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "vent-map"
	name = "Vent"
	desc = "A large air vent"
	level = UNDERFLOOR
	plane = PLANE_FLOOR

/obj/machinery/atmospherics/unary/vent/New()
	..()
	src.air_contents.set_volume(250)

/obj/machinery/atmospherics/unary/vent/process()
	..()

	//stolen from mingle_with_turf WOOHOOH
	var/turf/simulated/ourturf = get_turf(src)

	if (istype(ourturf, /turf/space/fluid))
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
	update_pipe_underlay(src.node, src.dir, "long", hide_pipe)
