/obj/machinery/igniter
	name = "igniter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	machine_registry_idx = MACHINES_SPARKERS
	var/id = null
	var/on = 1
	anchored = 1
	desc = "A device can be paired with other electronics, or used to heat chemicals directly."

/obj/machinery/igniter/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/igniter/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)

	use_power(50)
	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/process()
	if (src.on && !(status & NOPOWER) )
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/New()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( status & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	dir = EAST // so the sprites default to facing the same way as they always have
	machine_registry_idx = MACHINES_SPARKERS
	var/id = null
	var/disable = 0
	var/base_state = "migniter"
	var/datum/light/light
	anchored = 1

/obj/machinery/sparker/New()
	..()
	light = new /datum/light/point
	light.attach(src)
	light.set_brightness(0.4)

/obj/machinery/sparker/power_change()
	if ( powered() && disable == 0 )
		status &= ~NOPOWER
		icon_state = "[base_state]"
		light.enable()
	else
		status |= ~NOPOWER
		icon_state = "[base_state]-p"
		light.disable()

/obj/machinery/sparker/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='alert'>[user] has disabled the [src]!</span>", "<span class='alert'>You disable the connection to the [src].</span>")
			icon_state = "[base_state]-d"
		if (!src.disable)
			user.visible_message("<span class='alert'>[user] has reconnected the [src]!</span>", "<span class='alert'>You fix the connection to the [src].</span>")
			if(src.powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if (src.anchored)
		return src.ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((src.disable) || ON_COOLDOWN(src,"spark", 5 SECONDS))
		return


	flick("[base_state]-spark", src)
	elecflash(src)
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1)
	return 1


/obj/machinery/activation_button/ignition_switch
	name = "Ignition Switch"
	desc = "A remote control switch for a mounted igniter."

	activate()
		for(var/obj/machinery/sparker/M in machine_registry[MACHINES_SPARKERS])
			if (M.id == src.id)
				SPAWN( 0 )
					M.ignite()
			LAGCHECK(LAG_MED)

		for(var/obj/machinery/igniter/M in machine_registry[MACHINES_SPARKERS])
			if(M.id == src.id)
				use_power(50)
				M.on = !( M.on )
				M.icon_state = text("igniter[]", M.on)
			LAGCHECK(LAG_MED)

		sleep(5 SECONDS)
