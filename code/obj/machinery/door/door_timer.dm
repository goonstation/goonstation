/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doortimer0"
	desc = "A remote control switch for a door."
	req_access = list(access_security)
	anchored = TRUE
	var/id = null
	var/time = 30
	var/timing = FALSE
	var/last_tick = 0
	var/const/max_time = 300

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig/automatic (secure_closets.dm)
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
		src.update_icon()
		last_tick = TIME
	else
		last_tick = 0
	return

/obj/machinery/door_timer/power_change()
	update_icon()


// Why range 30? COG2 places linked fixtures much further away from the timer than originally envisioned.
/obj/machinery/door_timer/proc/alarm()
	if (!src)
		return
	if (status & (NOPOWER|BROKEN))
		return
/*
	for(var/obj/machinery/sim/chair/C in range(30, src))
		if (C.id == src.id)
			if(!C.active)
				continue
			if(C.con_user)
				C.con_user.network_device = null
				C.active = 0
*/

	//	MBC : wow this proc is suuuuper fucking costly
	//loop through range(30) three times. sure. whatever.
	//FIX LATER, putting it in a spawn and lagchecking for now.

	SPAWN_DBG(0)
		for (var/obj/machinery/door/window/brigdoor/M in range(30, src))
			if (M.id == src.id)
				SPAWN_DBG(0)
					if (M) M.close()
			LAGCHECK(LAG_HIGH)

		LAGCHECK(LAG_LOW)

		for (var/obj/machinery/floorflusher/FF in range(30, src))
			if (FF.id == src.id)
				if (FF.open != 1)
					FF.openup()
			LAGCHECK(LAG_HIGH)

		LAGCHECK(LAG_LOW)

		for (var/obj/storage/secure/closet/brig/automatic/B in range(30, src))
			if (B.id == src.id && B.our_timer == src)
				if (B.locked)
					B.locked = 0
					B.update_icon()
					B.visible_message("<span class='notice'>[B.name] unlocks automatically.</span>")
			LAGCHECK(LAG_HIGH)

	src.updateUsrDialog()
	src.update_icon()
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

	for (var/obj/machinery/flasher/F in range(10, src))
		if (F.id == src.id)
			. += list(
				"flasher" = TRUE,
				"recharging" = F.last_flash && world.time < F.last_flash + 150
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
			src.time = min(max(round(params["time"]), 0), src.max_time)
			if (params["finish"])
				logTheThing("station", usr, null, "set timer to [src.time]sec (previously: [previous_time]sec) on a door timer: [src] [log_loc(src)].")

			return TRUE

		if ("toggle-timing")
			if (src.timing == FALSE)
				for (var/obj/machinery/door/window/brigdoor/M in range(10, src))
					if (M.id == src.id)
						M.close() //close the cell door up when the timer starts.
						break
			else
				for (var/obj/machinery/door/window/brigdoor/M in range(10, src))
					if (M.id == src.id)
						M.open() //open the cell door if the timer is stopped.
						break

			src.timing = !src.timing
			logTheThing("station", usr, null, "[src.timing ? "starts" : "stops"] a door timer: [src] [log_loc(src)].")

			src.add_fingerprint(usr)
			src.update_icon()
			return TRUE

		if ("activate-flasher")
			for (var/obj/machinery/flasher/F in range(10, src))
				if (F.id == src.id)
					src.add_fingerprint(usr)
					F.flash()
					logTheThing("station", usr, null, "sets off flashers from a door timer: [src] [log_loc(src)].")
					return TRUE

/obj/machinery/door_timer/attack_ai(mob/user)
	return src.Attackhand(user)

/obj/machinery/door_timer/attack_hand(mob/user)
	return src.ui_interact(user)

/obj/machinery/door_timer/proc/update_icon()
	if (status & (NOPOWER))
		icon_state = "doortimer-p"
		return
	else if (status & (BROKEN))
		icon_state = "doortimer-b"
		return
	else
		if (src.timing)
			icon_state = "doortimer1"
		else if (src.time > 0)
			icon_state = "doortimer0"
		else
			SPAWN_DBG(5 SECONDS)
				icon_state = "doortimer0"
			icon_state = "doortimer2"
