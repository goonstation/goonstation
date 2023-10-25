/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doortimer0"
	desc = "A remote control switch for a door."
	req_access = list(access_security)
	anchored = ANCHORED
	var/id = null
	var/time = 30
	var/timing = FALSE
	var/last_tick = 0
	var/const/max_time = 300

	New()
		..()
		START_TRACKING

	disposing()
		..()
		STOP_TRACKING

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig_automatic (secure_closets.dm)
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	// /obj/machinery/flasher (flasher.dm)

	solitary
		name = "Cell #1"
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
		name = "Cell #2"
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
		name = "Cell #3"
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
		name = "Cell #4"
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
		name = "Mini-Brig"
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
		name = "Mini-Brig #2"
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
		name = "Mini-Brig #3"
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
		name = "General Population"
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
		name = "General Population North"
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
		name = "General Population South"
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

/obj/machinery/door_timer/examine()
	. = list("A remote control switch for a door.")

	if(src.timing)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		. += "<span class='alert'>Time Remaining: <b>[(minute ? text("[minute]:") : null)][second]</b></span>"
	else
		. += "<span class='alert'>There is no time set.</span>"

/obj/machinery/door_timer/process()
	..()
	if (src.timing)
		if (!last_tick) last_tick = TIME
		var/passed_time = round(max(round(TIME - last_tick), 10) / 10)
		if (src.time > 0)
			src.time -= passed_time
		else
			alarm()
			src.time = 0
			src.timing = FALSE
			last_tick = 0
		src.UpdateIcon()
		last_tick = TIME
	else
		last_tick = 0
	return

/obj/machinery/door_timer/power_change()
	src.UpdateIcon()


// Why range 30? COG2 places linked fixtures much further away from the timer than originally envisioned.
/obj/machinery/door_timer/proc/alarm()
	if (!src)
		return
	if (src.status & (NOPOWER|BROKEN))
		return

	for_by_tcl(M, /obj/machinery/door/window/brigdoor)
		if (!IN_RANGE(M, src, 30))
			continue
		if (M.id == src.id)
			SPAWN(0)
				if (M) M.close()

	for_by_tcl(FF, /obj/machinery/floorflusher)
		if (!IN_RANGE(FF, src, 30))
			continue
		if (FF.id == src.id)
			if (FF.open != 1)
				FF.openup()

	for_by_tcl(B, /obj/storage/secure/closet/brig_automatic)
		if (!IN_RANGE(B, src, 30))
			continue
		if (B.id == src.id && B.our_timer == src)
			if (B.locked)
				B.locked = 0
				B.UpdateIcon()
				B.visible_message("<span class='notice'>[B.name] unlocks automatically.</span>")

	tgui_process.update_uis(src)
	src.UpdateIcon()
	return

/obj/machinery/door_timer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DoorTimer", name)
		ui.open()

/obj/machinery/door_timer/ui_static_data(mob/user)
	. = list("maxTime" = src.max_time)


/obj/machinery/door_timer/ui_data(mob/user)
	. = list(
		"timing" = src.timing,
		"time" = src.time,
	)

	for_by_tcl(F, /obj/machinery/flasher)
		if (!IN_RANGE(F, src, 10))
			continue
		if (F.id == src.id)
			. += list(
				"flasher" = TRUE,
				"recharging" = GET_COOLDOWN(F, "flash")
			)
			break

	for_by_tcl(FF, /obj/machinery/floorflusher)
		if (!IN_RANGE(FF, src, 30))
			continue
		if (FF.id == src.id)
			. += list(
				"flusher" = TRUE,
				"flusheropen" = FF.open,
				"opening" = FF.opening
			)
			break

/obj/machinery/door_timer/ui_status(mob/user, datum/ui_state/state)
	return min(
		..(),
		src.allowed(user) ? UI_INTERACTIVE : UI_UPDATE,
	)

/obj/machinery/door_timer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch(action)
		if ("set-time")
			src.add_fingerprint(usr)
			var/previous_time = src.time
			src.time = clamp(0, round(params["time"]), src.max_time)
			if (params["finish"])
				logTheThing(LOG_STATION, usr, "set timer to [src.time]sec (previously: [previous_time]sec) on a door timer: [src] [log_loc(src)].")

			return TRUE

		if ("toggle-timing")
			if (src.timing == FALSE)
				for_by_tcl(M, /obj/machinery/door/window/brigdoor)
					if (!IN_RANGE(M, src, 10))
						continue
					if (M.id == src.id)
						M.close() //close the cell door up when the timer starts.
						break
			else
				for_by_tcl(M, /obj/machinery/door/window/brigdoor)
					if (!IN_RANGE(M, src, 10))
						continue
					if (M.id == src.id)
						M.open() //open the cell door if the timer is stopped.
						break

			src.timing = !src.timing
			logTheThing(LOG_STATION, usr, "[src.timing ? "starts" : "stops"] a door timer: [src] [log_loc(src)].")

			src.add_fingerprint(usr)
			src.UpdateIcon()
			return TRUE

		if ("activate-flasher")
			for_by_tcl(F, /obj/machinery/flasher)
				if (!IN_RANGE(F, src, 10))
					continue
				if (F.id == src.id)
					src.add_fingerprint(usr)
					if (GET_COOLDOWN(F, "flash"))
						return
					F.flash()
					logTheThing(LOG_STATION, usr, "sets off flashers from a door timer: [src] [log_loc(src)].")
					return TRUE

		if ("toggle-flusher")
			for_by_tcl(FF,/obj/machinery/floorflusher)
				if (!IN_RANGE(FF, src, 30))
					continue
				if (FF.id == src.id)
					src.add_fingerprint(usr)
					if (FF.flush == TRUE || FF.opening == TRUE)
						return
					if (FF.open != 1)
						FF.openup()
						logTheThing(LOG_STATION, usr, "opens a floor flusher from a door timer: [src] [log_loc(src)].")
					else
						FF.closeup()
						logTheThing(LOG_STATION, usr, "closes a floor flusher from a door timer: [src] [log_loc(src)].")
					return TRUE

/obj/machinery/door_timer/attack_ai(mob/user)
	return src.Attackhand(user)

/obj/machinery/door_timer/attack_hand(mob/user)
	return src.ui_interact(user)

/obj/machinery/door_timer/update_icon()
	if (src.status & (NOPOWER))
		icon_state = "doortimer-p"
		return
	else if (src.status & (BROKEN))
		icon_state = "doortimer-b"
		return
	else
		if (src.timing)
			icon_state = "doortimer1"
		else if (src.time > 0)
			icon_state = "doortimer0"
		else
			SPAWN(5 SECONDS)
				icon_state = "doortimer0"
			icon_state = "doortimer2"
