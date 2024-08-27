/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = ANCHORED
	power_usage = 250
	HELP_MESSAGE_OVERRIDE(null)
	var/datum/light/light
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/list/records = null
	var/id = null
	var/frequency = null
	var/base_icon_state = null

	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image

	///Set to TRUE to make multitools call connection_scan. For consoles with associated equipment (cloner, genetek etc)
	var/can_reconnect = FALSE
	///The related circuit board type for replacement/repairs
	var/obj/item/circuitboard/circuit_type = null

	Topic(href, href_list)
		if (..(href, href_list))
			return 1
		playsound(src.loc, 'sound/machines/keypress.ogg', 30, 1, -15)

	attack_hand(var/mob/user)
		. = ..()
		if (!user.literate)
			boutput(user, SPAN_ALERT("You don't know how to read or write, operating a computer isn't going to work!"))
			return 1
		interact_particle(user,src)

	attack_ai(mob/user as mob)
		src.Attackhand(user)

	attackby(obj/item/W, mob/user)
		if (can_reconnect)
			if (ispulsingtool(W) && !(status & (BROKEN|NOPOWER)))
				boutput(user, SPAN_NOTICE("You pulse the [name] to re-scan for equipment."))
				connection_scan()
				return
		if (isscrewingtool(W) && src.circuit_type)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/computer/proc/unscrew_monitor,\
			list(W, user), W.icon, W.icon_state, null, null)
			return
		else
			src.Attackhand(user)

	get_help_message(dist, mob/user)
		if (src.circuit_type)
			. = "Use a <b>screwdriver</b> to unscrew the screen."
		if (src.can_reconnect)
			if (.)
				.+= "\n"
			. += "Use a <b>multitool</b> to re-scan for equipment."

	proc/unscrew_monitor(obj/item/W as obj, mob/user as mob)
		var/obj/computerframe/A = new /obj/computerframe(src.loc)
		if (src.status & BROKEN)
			user?.show_text("The broken glass falls out.", "blue")
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
			A.state = 3
			A.icon_state = "3"
		else
			user?.show_text("You disconnect the monitor.", "blue")
			A.state = 4
			A.icon_state = "4"
		var/obj/item/circuitboard/M = new src.circuit_type(A)
		if (src.material)
			A.setMaterial(src.material)
		for (var/obj/C in src)
			C.set_loc(src.loc)
		A.set_dir(src.dir)
		A.circuit = M
		A.anchored = ANCHORED
		src.special_deconstruct(A, user)
		qdel(src)

	///Put the code for finding the stuff your computer needs in this proc
	proc/connection_scan()
	//Placeholder so the multitool probing thing can go on this parent

	///Special changes for deconstruction can be added by overriding this
	proc/special_deconstruct(var/obj/computerframe/frame as obj, mob/user)


/*
/obj/machinery/computer/airtunnel
	name = "Air Tunnel Control"
	icon = 'airtunnelcomputer.dmi'
	icon_state = "console00"
*/

/obj/machinery/computer/general_alert
	name = "general alert computer"
	icon_state = "alert:0"
	circuit_type = /obj/item/circuitboard/general_alert
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = FREQ_ALARM
	var/respond_frequency = FREQ_PDA

/obj/machinery/computer/hangar
	name = "Hangar"
	icon_state = "teleport"

/obj/machinery/computer/New()
	..()
	base_icon_state = initial(icon_state)
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
		src.AddOverlays(screen_image, "screen_image")

/obj/machinery/computer/meteorhit(var/obj/O as obj)
	if(status & BROKEN)	qdel(src)
	for(var/x in src.verbs)
		src.verbs -= x
	set_broken()

/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1)
			//gib(src.loc) NO.
			qdel(src)
			return
		if(2)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()
		if(3)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				set_broken()

/obj/machinery/computer/emp_act()
	. = ..()
	if(prob(20))
		src.set_broken()

/obj/machinery/computer/blob_act(var/power)
	if (prob(50 * power / 20))
		for(var/x in src.verbs)
			src.verbs -= x
		set_broken()
		src.set_density(0)

/obj/machinery/computer/power_change()
	//if(!istype(src,/obj/machinery/computer/security/telescreen))
	if(status & BROKEN)
		icon_state = "[src.base_icon_state]b"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")

	else if(powered())
		icon_state = src.base_icon_state
		status &= ~NOPOWER
		light.enable()
		if(glow_in_dark_screen)
			screen_image.plane = PLANE_LIGHTING
			screen_image.blend_mode = BLEND_ADD
			screen_image.layer = LIGHTING_LAYER_BASE
			screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
			src.AddOverlays(screen_image, "screen_image")
	else
		SPAWN(rand(0, 15))
			src.icon_state = "[src.base_icon_state]0"
			status |= NOPOWER
			light.disable()
			if(glow_in_dark_screen)
				src.ClearSpecificOverlays("screen_image")

/obj/machinery/computer/process()
	if(status & BROKEN)
		return
	. = ..()
	if(status & NOPOWER)
		return

/obj/machinery/computer/update_icon()
	if(src.glow_in_dark_screen)
		src.screen_image = image('icons/obj/computer_screens.dmi', src.icon_state, -1)
		src.screen_image.plane = PLANE_LIGHTING
		src.screen_image.blend_mode = BLEND_ADD
		src.screen_image.layer = LIGHTING_LAYER_BASE
		src.screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.AddOverlays(screen_image, "screen_image")
	. = ..()

/obj/machinery/computer/proc/set_broken()
	if (status & BROKEN) return
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	icon_state = "[src.base_icon_state]b"
	light.disable()
	status |= BROKEN

/obj/machinery/computer/bullet_act(obj/projectile/P)
	. = ..()
	switch (P.proj_data.damage_type)
		if (D_KINETIC, D_PIERCING, D_SLASHING)
			if (prob(P.power))
				if (status & BROKEN)
					playsound(src, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 50, TRUE)
					src.unscrew_monitor()
				else
					src.set_broken()
