// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet

/obj/machinery/computer/power_monitor
	name = "Power Monitoring Computer"
	desc = "Shows the power usage of the station."
	icon_state = "power2"
	power_usage = 0
	circuit_type = /obj/item/circuitboard/powermonitor
	var/window_tag = "powcomp"
	var/list/history
	var/const/history_max = 50

/obj/machinery/computer/power_monitor/New()
	..()
	history = list()

/obj/machinery/computer/power_monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PowerMonitor", src.name)
		ui.open()

/obj/machinery/computer/power_monitor/ui_static_data(mob/user)
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!istype(powernet))
		return
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

/obj/machinery/computer/power_monitor/ui_data(mob/user)
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!istype(powernet))
		return
	. = list(
		"available" = powernet.avail,
		"load" = powernet.viewload,
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

/obj/machinery/computer/power_monitor/process()
	if (status & (NOPOWER|BROKEN))
		return

	use_power(250)
	add_history()
	if (src.history.len > src.history_max)
		src.history.Cut(1, 2) //drop the oldest entry

/obj/machinery/computer/power_monitor/proc/add_history()
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!istype(powernet))
		return
	src.history += list(list(
		powernet.avail,
		powernet.viewload,
	))

/obj/machinery/computer/power_monitor/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "power1"

/obj/machinery/computer/power_monitor/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "power2"

// tweaked version to hook up to the engine->smes powernet and show SMES usage stats and power produced
/obj/machinery/computer/power_monitor/smes
	name = "SMES Monitoring Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1
	desc = "Shows the SMES usage and power produced by the engine."
	window_tag = "smespowcomp"
	circuit_type = /obj/item/circuitboard/powermonitor_smes

/obj/machinery/computer/power_monitor/smes/ui_static_data(mob/user)
	. = list(
		"type" = "smes",
		"unitNames" = list(),
	)

	var/list/L = list()
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!istype(powernet))
		return
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

/obj/machinery/computer/power_monitor/smes/ui_data(mob/user)
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!istype(powernet))
		return
	. = list(
		"available" = powernet.avail,
		"load" = powernet.viewload,
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
