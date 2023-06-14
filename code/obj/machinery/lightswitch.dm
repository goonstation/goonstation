// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var

TYPEINFO(/obj/machinery/light_switch)
	mats = list("MET-1"=10,"CON-1"=15)

ADMIN_INTERACT_PROCS(/obj/machinery/light_switch, proc/trigger)
/obj/machinery/light_switch
	desc = "A light switch"
	name = null
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	text = ""
	var/on = 1
	var/area/area = null
	var/otherarea = null
	var/id = null
	//	luminosity = 1
	var/datum/light/light


/obj/machinery/light_switch/New()
	..()
	UnsubscribeProcess()
	if (!light)
		light = new /datum/light/point
	SPAWN(0.5 SECONDS)
		src.area = get_area(src)
		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		src.id = src.area.name
		ADD_SWITCHED_OBJ(SWOB_LIGHTS)

		if(!name || name == "N light switch" || name == "E light switch" || name == "S light switch" || name == "W light switch")
			name = "light switch"

		src.on = src.area.lightswitch
		UpdateIcon()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", PROC_REF(trigger))

		if (on)
			light.set_color(0.5, 1, 0.5)
		else
			light.set_color(1, 0.5, 0.5)
		light.set_brightness(0.3)
		light.attach(src)
		light.enable()

/obj/machinery/light_switch/disposing()
	REMOVE_SWITCHED_OBJ(SWOB_LIGHTS)
	. = ..()

/obj/machinery/light_switch/proc/trigger(var/datum/mechanicsMessage/inp)
	if(!ON_COOLDOWN(src, "mechcomp_toggle", 1 SECOND))
		toggle_group(null)

/obj/machinery/light_switch/proc/autoposition()
	var/turf/T = null
	for (var/dir in cardinal)
		T = get_step(src,dir)
		if (T.density || (locate(/obj/wingrille_spawn) in T) || (locate(/obj/window) in T))
			src.set_dir(dir)
			if (dir == EAST)
				src.pixel_x = 24
			else if (dir == WEST)
				src.pixel_x = -24
			else if (dir == NORTH)
				src.pixel_y = 24
			else
				src.pixel_y = -24
			break

/obj/machinery/light_switch/was_built_from_frame(mob/user, newly_built)
	. = ..()
	if (!newly_built) // dont want the area to end up something wacky
		src.area = get_area(src)
		src.on = src.area.lightswitch
		src.id = src.area.name
		ADD_SWITCHED_OBJ(SWOB_LIGHTS)
		area.machines += src // i dont know why it doesn't end up in there
		src.UpdateIcon()
	src.autoposition()

/obj/machinery/light_switch/was_deconstructed_to_frame(mob/user)
	. = ..()
	area.machines -= src
	REMOVE_SWITCHED_OBJ(SWOB_LIGHTS)

/obj/machinery/light_switch/update_icon()
	if(status & NOPOWER)
		icon_state = "light-p"
		light.disable()
		src.UpdateOverlays(null, "light")
	else
		var/mutable_appearance/light_ov = mutable_appearance(src.icon, "light-light")
		light_ov.plane = PLANE_LIGHTING
		light_ov.alpha = 70
		src.UpdateOverlays(light_ov, "light")
		if (icon_state == "light-p")
			light.enable()
		if(on)
			icon_state = "light1"
			light.set_color(0.5, 1, 0.5)
		else
			icon_state = "light0"
			light.set_color(1, 0.5, 0.5)

/obj/machinery/light_switch/get_desc(dist, mob/user)
	if(user && !user.stat)
		return "A light switch. It is [on? "on" : "off"]."

/obj/machinery/light_switch/attack_hand(mob/user)
	if(!ON_COOLDOWN(src, "toggle", 1 SECOND))
		toggle_group(user)

/obj/machinery/light_switch/proc/toggle_group(mob/user=null) //flip *this* switch, update target area, then prompt the group to refresh accordingly
	on = !on
	area.lightswitch = on
	area.power_change()

	if(user)
		interact_particle(user,src)

	playsound(src, 'sound/misc/lightswitch.ogg', 50, 1)

	if(user)
		src.add_fingerprint(user)
		logTheThing(LOG_STATION, user, "turns [on ? "on" : "off"] a lightswitch at [log_loc(user)]")

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[on ? "lightOn":"lightOff"]")

	switched_obj_toggle(SWOB_LIGHTS,src.id,src.on) //the bit that handles visual and switch state updates for the group, via the toggle proc below

	if(on && !ON_COOLDOWN(src, "turtlesplode", 10 SECONDS))
		for_by_tcl(S, /obj/critter/turtle)
			if(get_area(S) == src.area && S.rigged)
				S.explode()

/obj/machinery/light_switch/proc/toggle(var/on_signal)
	src.on = on_signal
	src.UpdateIcon()

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(LIGHT))
			status &= ~NOPOWER
		else
			status |= NOPOWER

		UpdateIcon()

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
		SPAWN(1 DECI SECOND)
			src.autoposition()
		..()
