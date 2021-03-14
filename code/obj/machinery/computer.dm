/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = 1.0
	power_usage = 250
	var/datum/light/light
	var/light_r =1
	var/light_g = 1
	var/light_b = 1

	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image
/*
/obj/machinery/computer/airtunnel
	name = "Air Tunnel Control"
	icon = 'airtunnelcomputer.dmi'
	icon_state = "console00"
*/

/obj/machinery/computer/attack_hand(mob/user as mob)
	. = ..()
	if (!user.literate)
		boutput(user, "<span class='alert'>You don't know how to read or write, operating a computer isn't going to work!</span>")
		return 1

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "A computer that accepts modules, and uploads the commands to the AI."
	icon_state = "aiupload"

/obj/machinery/computer/general_alert
	name = "General Alert Computer"
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = "1437"
	var/respond_frequency = "1149"

/obj/machinery/computer/hangar
	name = "Hangar"
	icon_state = "teleport"

/obj/machinery/computer/New()
	..()
	light = new/datum/light/point
	light.set_brightness(0.4)
	light.set_color(light_r, light_g, light_b)
	light.attach(src)

	if(glow_in_dark_screen)
		src.screen_image = image('icons/obj/computer_screens.dmi', src.icon_state, -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(screen_image, "screen_image")

/obj/machinery/computer/meteorhit(var/obj/O as obj)
	if(status & BROKEN)	qdel(src)
	for(var/x in src.verbs)
		src.verbs -= x
	set_broken()
	return

/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1.0)
			//gib(src.loc) NO.
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/emp_act()
	..()
	if(prob(20))
		src.set_broken()
	return

/obj/machinery/computer/blob_act(var/power)
	if (prob(50 * power / 20))
		for(var/x in src.verbs)
			src.verbs -= x
		set_broken()
		src.set_density(0)

/obj/machinery/computer/power_change()
	//if(!istype(src,/obj/machinery/computer/security/telescreen))
	if(status & BROKEN)
		icon_state = initial(icon_state)
		src.icon_state += "b"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")

	else if(powered())
		icon_state = initial(icon_state)
		status &= ~NOPOWER
		light.enable()
		if(glow_in_dark_screen)
			screen_image.plane = PLANE_LIGHTING
			screen_image.blend_mode = BLEND_ADD
			screen_image.layer = LIGHTING_LAYER_BASE
			screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
			src.UpdateOverlays(screen_image, "screen_image")
	else
		SPAWN_DBG(rand(0, 15))
			//src.icon_state = "c_unpowered"
			icon_state = initial(icon_state)
			src.icon_state += "0"
			status |= NOPOWER
			light.disable()
			if(glow_in_dark_screen)
				src.ClearSpecificOverlays("screen_image")

/obj/machinery/computer/process()
	if(status & BROKEN)
		return
	..()
	if(status & NOPOWER)
		return
	use_power(250)

/obj/machinery/computer/proc/set_broken()
	if (status & BROKEN) return
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	icon_state = initial(icon_state)
	icon_state += "b"
	light.disable()
	status |= BROKEN

