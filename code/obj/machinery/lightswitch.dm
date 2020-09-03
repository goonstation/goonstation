// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var

/obj/machinery/light_switch
	desc = "A light switch"
	name = null
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	plane = PLANE_NOSHADOW_ABOVE
	text = ""
	var/on = 1
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1
	// mats = 6 fuck you mport
	var/datum/light/light


/obj/machinery/light_switch/New()
	..()
	UnsubscribeProcess()
	light = new /datum/light/point
	SPAWN_DBG(0.5 SECONDS)
		src.area = src.loc.loc

		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		if(!name || name == "N light switch" || name == "E light switch" || name == "S light switch" || name == "W light switch")
			name = "light switch"

		src.on = src.area.lightswitch
		updateicon()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", "trigger")

		if (on)
			light.set_color(0.5, 1, 0.50)
		else
			light.set_color(1, 0.50, 0.50)
		light.set_brightness(0.3)
		light.attach(src)
		light.enable()

/obj/machinery/light_switch/proc/trigger(var/datum/mechanicsMessage/inp)
	attack_hand(usr) //bit of a hack but hey.
	return


/obj/machinery/light_switch/proc/updateicon()
	if(status & NOPOWER)
		icon_state = "light-p"
		light.disable()
	else
		if (icon_state == "light-p")
			light.enable()
		if(on)
			icon_state = "light1"
			light.set_color(0.5, 1, 0.50)
		else
			icon_state = "light0"
			light.set_color(1, 0.50, 0.50)

/obj/machinery/light_switch/examine(mob/user)
	if(user && !user.stat)
		return list("A light switch. It is [on? "on" : "off"].")

/obj/machinery/light_switch/attack_hand(mob/user)

	on = !on

	area.lightswitch = on

	area.power_change()

	interact_particle(user,src)

	for(var/obj/machinery/light_switch/L in area)
		L.on = on
		L.updateicon()
		LAGCHECK(LAG_MED)

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[on ? "lightOn":"lightOff"]")

	playsound(get_turf(src), "sound/misc/lightswitch.ogg", 50, 1)

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(LIGHT))
			status &= ~NOPOWER
		else
			status |= NOPOWER

		updateicon()

/obj/machinery/light_switch/north
	name = "N light switch"
	pixel_y = 24

/obj/machinery/light_switch/east
	name = "E light switch"
	pixel_x = 24

/obj/machinery/light_switch/south
	name = "S light switch"
	pixel_y = -24

/obj/machinery/light_switch/west
	name = "W light switch"
	pixel_x = -24

/obj/machinery/light_switch/auto
	name = "light switch"

	New()
		var/turf/T = null
		SPAWN_DBG(1 DECI SECOND)
			for (var/dir in cardinal)
				T = get_step(src,dir)
				if (istype(T,/turf/simulated/wall) || (locate(/obj/wingrille_spawn) in T) || (locate(/obj/window) in T))
					if (dir == EAST)
						src.pixel_x = 24
					else if (dir == WEST)
						src.pixel_x = -24
					else if (dir == NORTH)
						src.pixel_y = 24
					else
						src.pixel_y = -24
					break
			T = null
		..()
