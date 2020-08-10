// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "\improper Mounted Flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	var/datum/light/light
	anchored = 1

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig/automatic (secure_closets.dm)
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

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

/obj/machinery/flasher/New()
	..()
	light = new /datum/light/point
	light.attach(src)
	light.set_brightness(0.4)
	light.set_height(0.5)

/obj/machinery/flasher/power_change()
	if ( powered() )
		status &= ~NOPOWER
		icon_state = "[base_state]1"
	else
		status |= ~NOPOWER
		icon_state = "[base_state]1-p"
		light.disable()

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/W as obj, mob/user as mob)
	if (issnippingtool(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='alert'>[user] has disconnected the [src]'s flashbulb!</span>", "<span class='alert'>You disconnect the [src]'s flashbulb!</span>")
		if (!src.disable)
			user.visible_message("<span class='alert'>[user] has connected the [src]'s flashbulb!</span>", "<span class='alert'>You connect the [src]'s flashbulb!</span>")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(src.loc, "sound/weapons/flash.ogg", 100, 1)
	flick("[base_state]_flash", src)
	src.last_flash = world.time
	use_power(1000)

	for (var/mob/O in viewers(src, null))
		if (get_dist(src, O) > src.range)
			continue

		// Heavy-duty flashers should be capable of disrupting cloaks in a reliable fashion, hence the 100% at the end.
		O.apply_flash(30, src.strength, 0, 0, 0, rand(0, 2), 0, 0, 100)

	return

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if ((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			light.disable()
			user.show_message(text("<span class='alert'>[src] can now be moved.</span>"))
			src.overlays = null

		else if (src.anchored)
			if ( powered() )
				light.enable()
			user.show_message(text("<span class='alert'>[src] is now secured.</span>"))
			src.overlays += "[base_state]-s"
