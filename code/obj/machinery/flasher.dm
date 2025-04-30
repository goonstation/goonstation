// It is a gizmo that flashes a small area
ADMIN_INTERACT_PROCS(/obj/machinery/flasher, proc/flash)
/obj/machinery/flasher
	name = "\improper Mounted Flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	var/datum/light/light
	var/cooldown_flash = 15 SECONDS
	anchored = ANCHORED
	req_access = list(access_security)

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig_automatic (secure_closets.dm)
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door_timer (door_timer.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	solitary
		name = "\improper Mounted Flash (Cell #1)"
		id = "solitary"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary2
		name = "\improper Mounted Flash (Cell #2)"
		id = "solitary2"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary3
		name = "\improper Mounted Flash (Cell #3)"
		id = "solitary3"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary4
		name = "\improper Mounted Flash (Cell #4)"
		id = "solitary4"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig
		name = "\improper Mounted Flash (Mini-Brig)"
		id = "minibrig"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig2
		name = "\improper Mounted Flash (Mini-Brig #2)"
		id = "minibrig2"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig3
		name = "\improper Mounted Flash (Mini-Brig #3)"
		id = "minibrig3"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop
		name = "\improper Mounted Flash (Genpop)"
		id = "genpop"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop_n
		name = "\improper Mounted Flash (Genpop North)"
		id = "genpop_n"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop_s
		name = "\improper Mounted Flash (Genpop South)"
		id = "genpop_s"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	blob_act(var/power)
		if (prob(30 + power))
			qdel(src)

/obj/machinery/flasher/New()
	..()
	START_TRACKING
	light = new /datum/light/point
	light.attach(src)
	light.set_brightness(0.4)
	light.set_height(0.5)

/obj/machinery/flasher/disposing()
	..()
	STOP_TRACKING

/obj/machinery/flasher/power_change()
	if ( powered() )
		status &= ~NOPOWER
		icon_state = "[base_state]1"
	else
		status |= ~NOPOWER
		icon_state = "[base_state]1-p"
		light.disable()

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/W, mob/user)
	if (issnippingtool(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message(SPAN_ALERT("[user] has disconnected the [src]'s flashbulb!"), SPAN_ALERT("You disconnect the [src]'s flashbulb!"))
		if (!src.disable)
			user.visible_message(SPAN_ALERT("[user] has connected the [src]'s flashbulb!"), SPAN_ALERT("You connect the [src]'s flashbulb!"))

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (src.anchored && !ON_COOLDOWN(src, "flash", cooldown_flash))
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!powered())
		return

	if (src.disable)
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	FLICK("[base_state]_flash", src)
	ON_COOLDOWN(src, "flash", cooldown_flash)
	use_power(1000)

	for (var/mob/O in viewers(src, null))
		if (GET_DIST(src, O) > src.range)
			continue

		// Heavy-duty flashers should be capable of disrupting cloaks in a reliable fashion, hence the 100% at the end.
		O.apply_flash(30, src.strength, 0, 0, 0, rand(0, 2), 0, 0, 100)

	return

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1-c"
	strength = 8
	anchored = UNANCHORED
	base_state = "pflash"
	density = 1
	var/cooldown_scan = 1.5 SECONDS
	var/cooldown_end = 0

/obj/machinery/flasher/portable/power_change()
	..()
	UpdateIcon()

/obj/machinery/flasher/portable/update_icon()
	if (powered())
		if (!src.anchored)
			icon_state = "[base_state]1-c"
		else
			if (GET_COOLDOWN(src, "flash"))
				icon_state = "[base_state]1-c"
			else
				icon_state = "[base_state]1"
	else
		icon_state = "[base_state]1-p"

/obj/machinery/flasher/portable/EnteredProximity(atom/movable/AM)
	if (!src.anchored || src.disable)
		return

	if (GET_COOLDOWN(src, "flash"))
		return

	if (!powered())
		return

	if (isliving(AM))
		var/mob/M = AM
		if (isghostcritter(M) || (issmallanimal(M)) || (isghostdrone(M)) || (isintangible(M)))
			return
		if (M.m_intent != "walk")
			if (src.allowed(M))
				ON_COOLDOWN(src, "flash", cooldown_scan)
				SPAWN(cooldown_scan + 0.1 SECONDS)
					if (src)
						UpdateIcon()
			else
				ON_COOLDOWN(src, "flash", cooldown_flash)
				src.flash()
				SPAWN(cooldown_flash + 0.1 SECONDS)
					if (src)
						UpdateIcon()
			UpdateIcon()

/obj/machinery/flasher/portable/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			light.disable()
			UpdateIcon()
			user.show_message(SPAN_ALERT("[src] can now be moved."))
			src.UpdateOverlays(null, "anchor")
			src.RemoveComponentsOfType(/datum/component/proximity)

		else if (src.anchored)
			if (powered())
				light.enable()
			UpdateIcon()
			user.show_message(SPAN_ALERT("[src] is now secured."))
			src.UpdateOverlays(image(src.icon, "[base_state]-s"), "anchor")
			src.AddComponent(/datum/component/proximity)
