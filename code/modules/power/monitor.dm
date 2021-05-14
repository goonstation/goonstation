// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet

/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "power2"
	density = 1
	anchored = 1
	desc = "Shows the power usage of the station."
	flags = FPRINT | TGUI_INTERACTIVE
	var/datum/light/light
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/window_tag = "powcomp"
	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image
	var/list/history
	var/const/history_max = 50

/obj/machinery/power/monitor/New()
	..()
	history = list()

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


/obj/machinery/power/monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PowerMonitor", src.name)
		ui.open()

/obj/machinery/power/monitor/ui_static_data(mob/user)
	. = list(
		"type" = "apc",
		"apcNames" = list(),
	)

	var/list/L = list()
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		var/obj/machinery/power/apc/A = term.master
		if(istype(A) && (!A.area || A.area.requires_power))
			L += A

	for(var/obj/machinery/power/apc/A as anything in L)
		.["apcNames"] += list(
			"\ref[A]" =  A.area.name
		)

/obj/machinery/power/monitor/ui_data(mob/user)
	. = list(
		"available" = src.powernet.avail,
		"load" = src.powernet.viewload,
		"apcs" = list(),
		"history" = src.history,
	)

	var/list/L = list()
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		var/obj/machinery/power/apc/A = term.master
		if(istype(A) && (!A.area || A.area.requires_power))
			L += A

	for(var/obj/machinery/power/apc/A as anything in L)
		var/list/data = list(
			"\ref[A]",
			A.equipment,
			A.lighting,
			A.environ,
			A.lastused_total,
		)

		if (A.cell)
			data += round(A.cell.percent())
			data += A.charging

		.["apcs"] += list(data)

/obj/machinery/power/monitor/attack_hand(mob/user)
	add_fingerprint(user)
	..()

/obj/machinery/power/monitor/process()
	if (status & (NOPOWER|BROKEN))
		return

	use_power(250)
	add_history()
	if (src.history.len > src.history_max)
		src.history.Cut(1, 2) //drop the oldest entry

/obj/machinery/power/monitor/proc/add_history()
	src.history += list(list(
		src.powernet.avail,
		src.powernet.viewload,
	))

/obj/machinery/power/monitor/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "power1"

/obj/machinery/power/monitor/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "power2"

/obj/machinery/power/monitor/power_change()

	if(status & BROKEN)
		icon_state = "broken"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")
	else
		if( powered() )
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
				src.icon_state = "power20"
				status |= NOPOWER
				light.disable()
				if(glow_in_dark_screen)
					src.ClearSpecificOverlays("screen_image")

// tweaked version to hook up to the engine->smes powernet and show SMES usage stats and power produced
/obj/machinery/power/monitor/smes
	name = "SMES Monitoring Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1
	desc = "Shows the SMES usage and power produced by the engine."
	window_tag = "smespowcomp"

/obj/machinery/power/monitor/smes/ui_static_data(mob/user)
	. = list(
		"type" = "smes",
		"unitNames" = list(),
	)

	var/list/L = list()
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		if(istype(term.master, /obj/machinery/power/smes))
			var/obj/machinery/power/smes/A = term.master
			L += A
		else if(istype(term.master, /obj/machinery/power/pt_laser))
			var/obj/machinery/power/pt_laser/P = term.master
			L += P

	for(var/obj/machinery/power/A as anything in L)
		var/area/place = get_area(A)
		if (place)
			.["unitNames"] += list(
				"\ref[A]" = place.name
			)

/obj/machinery/power/monitor/smes/ui_data(mob/user)
	. = list(
		"available" = src.powernet.avail,
		"load" = src.powernet.viewload,
		"units" = list(),
		"history" = src.history,
	)

	var/list/L = list()
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		if(istype(term.master, /obj/machinery/power/smes))
			var/obj/machinery/power/smes/A = term.master
			L += A
		else if(istype(term.master, /obj/machinery/power/pt_laser))
			var/obj/machinery/power/pt_laser/P = term.master
			L += P

	for(var/obj/machinery/power/smes/A in L)
		.["units"] += list(list(
			"\ref[A]",
			round(100.0*A.charge/A.capacity, 0.1),
			A.charging,
			A.chargelevel,
			A.output,
			A.online,
			A.loaddemand
		))

	for(var/obj/machinery/power/pt_laser/P in L)
		.["units"] += list(list(
			"\ref[P]",
			P.output ? round(100.0*P.charge/P.output, 0.1) : 0,
			P.charging,
			P.chargelevel,
			P.output,
			P.online,
		))
