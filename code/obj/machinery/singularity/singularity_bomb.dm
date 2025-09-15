
#define UNWRENCHED 0	/// Defines a machine as being entirely loose. Not wrenched, not welded.
#define WRENCHED 1		/// Defines a machine as being secured to the floor (wrenched), but not welded.
#define WELDED 2		/// Defines a machine as being both secured to the floor (wrenched) and welded.

// Thing thing had zero logging despite being overhauled recently. I corrected that oversight (Convair880).
TYPEINFO(/obj/machinery/the_singularitybomb)
	mats = 14

ADMIN_INTERACT_PROCS(/obj/machinery/the_singularitybomb, proc/prime, proc/abort)
/obj/machinery/the_singularitybomb
	name = "\improper Singularity Bomb"
	desc = "A WMD that creates a singularity."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	anchored = UNANCHORED
	density = 1
	var/state = UNWRENCHED
	var/timing = 0
	var/time = 30
	var/last_tick = null
	var/mob/activator = null // For logging purposes.
	is_syndicate = 1
	var/bhole = 1

/obj/machinery/the_singularitybomb/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)

	if (iswrenchingtool(W))

		if(state == UNWRENCHED)
			state = WRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = ANCHORED
			return

		else if(state == WRENCHED)
			state = UNWRENCHED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You undo the external reinforcing bolts.")
			src.anchored = UNANCHORED
			return

	if(isweldingtool(W))
		if(timing)
			boutput(user, "Stop the countdown first.")
			return

		var/turf/T = user.loc


		if(state == WRENCHED)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to weld the bomb to the floor.")
			sleep(5 SECONDS)

			logTheThing(LOG_STATION, user, "welds a [src.name] to the floor at [log_loc(src)].") // Like here (Convair880).

			if ((user.loc == T && user.equipped() == W))
				state = WELDED
				icon_state = "portgen1"
				boutput(user, "You weld the bomb to the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = WELDED
				icon_state = "portgen1"
				boutput(user, "You weld the bomb to the floor.")
			return

		if(state == WELDED)
			if(!W:try_weld(user, 1, noisy = 2))
				return
			boutput(user, "You start to cut the bomb free from the floor.")
			sleep(5 SECONDS)

			logTheThing(LOG_STATION, user, "cuts a [src.name] from the floor at [log_loc(src)].") // Hmm (Convair880).
			if (src.activator)
				src.activator = null

			if ((user.loc == T && user.equipped() == W))
				state = WRENCHED
				icon_state = "portgen0"
				boutput(user, "You cut the bomb free from the floor.")
			else if((isrobot(user) && (user.loc == T)))
				state = WRENCHED
				icon_state = "portgen0"
				boutput(user, "You cut the bomb free from the floor.")
			return

	else
		boutput(user, SPAN_ALERT("You hit the [src.name] with your [W.name]!"))
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("The [src.name] has been hit with the [W.name] by [user.name]!"))

/obj/machinery/the_singularitybomb/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	if ((in_interact_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		switch(href_list["action"]) //Yeah, this is weirdly set up. Planning to expand it later.
			if("trigger")
				switch(href_list["spec"])
					if("prime")
						if(!timing)
							src.prime()
						else
							boutput(usr, SPAN_ALERT("\The [src] is already primed!"))
					if("abort")
						if(timing)
							src.abort()
						else
							boutput(usr, SPAN_ALERT("\The [src] is already deactivated!"))
			if("timer")
				if(!timing)
					var/tp = text2num_safe(href_list["tp"])
					src.time += tp
					src.time = clamp(round(src.time), 30, 600)
				else
					boutput(usr, SPAN_ALERT("You can't change the time while the timer is engaged!"))
		/*
		if (href_list["time"])
			src.timing = text2num_safe(href_list["time"])
			if(timing) processing_items |= src
				src.icon_state = "portgen2"
			else
				src.icon_state = "portgen1"

		if (href_list["tp"])
			var/tp = text2num_safe(href_list["tp"])
			src.time += tp
			src.time = clamp(round(src.time), 60, 600)

		if (href_list["close"])
			usr.Browse(null, "window=timer")
			usr.machine = null
			return
		*/
		if (ismob(src.loc))
			attack_hand(src.loc)
		else
			src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=timer")
		return
	return

/obj/machinery/the_singularitybomb/proc/prime()
	src.timing = 1
	processing_items |= src
	src.icon_state = "portgen2"
	logTheThing(LOG_BOMBING, usr, "activated [src.name] ([src.time] seconds) at [log_loc(src)].")
	message_admins("[key_name(usr)] activated [src.name] ([src.time] seconds) at [log_loc(src)].")
	if (ismob(usr))
		src.activator = usr

/obj/machinery/the_singularitybomb/proc/abort()
	src.timing = 0
	src.icon_state = "portgen1"

	// And here (Convair880).
	logTheThing(LOG_BOMBING, usr, "deactivated [src.name][src.activator ? " (primed by [constructTarget(src.activator,"bombing")]" : ""] at [log_loc(src)].")
	message_admins("[key_name(usr)] deactivated [src.name][src.activator ? " (primed by [key_name(src.activator)])" : ""] at [log_loc(src)].")

/obj/machinery/the_singularitybomb/attack_ai(mob/user as mob)
	return

/obj/machinery/the_singularitybomb/attack_hand(mob/user)
	..()
	if(src.state != WELDED)
		boutput(user, "The bomb needs to be firmly secured to the floor first.")
		return
	if (user.stat || user.restrained() || user.lying)
		return
	if ((BOUNDS_DIST(src, user) == 0 && istype(src.loc, /turf)))
		src.add_dialog(user)
		/*
		var/dat = text("<TT><B>Timing Unit</B><br>[] []:[]<br><A href='byond://?src=\ref[];tp=-30'>-</A> <A href='byond://?src=\ref[];tp=-1'>-</A> <A href='byond://?src=\ref[];tp=1'>+</A> <A href='byond://?src=\ref[];tp=30'>+</A><br></TT>", (src.timing ? text("<A href='byond://?src=\ref[];time=0'>Timing</A>", src) : text("<A href='byond://?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><BR><A href='byond://?src=\ref[src];close=1'>Close</A>"
		*/
		user.Browse(src.get_interface(), "window=timer")
		onclose(user, "timer")
	else
		user.Browse(null, "window=timer")
		src.remove_dialog(user)

	src.add_fingerprint(user)
	return

/obj/machinery/the_singularitybomb/proc/time()
	var/turf/T = get_turf(src.loc)
	for(var/mob/O in hearers(src.loc, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)


	playsound(T, 'sound/effects/creaking_metal1.ogg', 100, FALSE, 5, 0.5)
	for (var/mob/M in range(7,T))
		boutput(M, "<span class='bold alert'>The contaiment field on \the [src] begins destabilizing!</span>")
		shake_camera(M, 5, 16)
	for (var/turf/TF in range(4,T))
		animate_shake(TF,5,1 * GET_DIST(TF,T),1 * GET_DIST(TF,T))
	particleMaster.SpawnSystem(new /datum/particleSystem/bhole_warning(T))

	SPAWN(3 SECONDS)
		for (var/mob/M in range(7,T))
			boutput(M, "<span class='bold alert'>The containment field on \the [src] fails completely!</span>")
			shake_camera(M, 5, 16)

		// And most importantly here (Convair880)!
		logTheThing(LOG_BOMBING, src.activator, "A [src.name] (primed by [src.activator ? "[src.activator]" : "*unknown*"]) detonates at [log_loc(src)].")
		message_admins("A [src.name] (primed by [src.activator ? "[key_name(src.activator)]" : "*unknown*"]) detonates at [log_loc(src)].")

		playsound(T, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, flags=SOUND_IGNORE_SPACE)
		if (bhole)
			var/obj/B = new /obj/bhole(get_turf(src.loc), rand(1600, 2400), rand(75, 100))
			B.name = "gravitational singularity"
			B.color = "#FF00FF"
		else
			new /obj/machinery/the_singularity(get_turf(src.loc), rand(1600, 2400))

	return

/obj/machinery/the_singularitybomb/process()
	if (src.timing)
		if (src.time > 0)
			if (!last_tick) last_tick = world.time
			var/passed_time = round(max(round(world.time - last_tick),10) / 10)
			src.time = max(0, src.time - passed_time)
			last_tick = world.time
		else
			time()
			src.time = 0
			src.timing = 0
			last_tick = 0

		if (ismob(src.loc))
			attack_hand(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.using_dialog_of(src))
					src.Attackhand(M)

	return

/obj/machinery/the_singularitybomb/proc/get_time()
	if(src.time < 0)
		return "DO:OM"
	else
		var/seconds = src.time % 60
		var/minutes = (src.time - seconds) / 60
		var/flick_seperator = (seconds % 2 == 0)  || !src.timing
		minutes = minutes < 10 ? "0[minutes]" : "[minutes]"
		seconds = seconds < 10 ? "0[seconds]" : "[seconds]"

		return "[minutes][flick_seperator ? ":" : " "][seconds]"

/obj/machinery/the_singularitybomb/proc/get_interface()
	return {"<html>
				<head>
					<style>
						body {
							font-family:verdana,sans-serif;

						}
						a {
							text-decoration:none;
						}
						.top_level {
							display: inline;
							border: 2px solid #333;
							padding:10px;
						}
						.timing_div {
							overflow:auto;
							padding:10px;
						}
						.timer {
							display:table-cell;
							color:#0A0;
							font-weight:bold;
							text-align:src.get_center();
							vertical-align:middle;
							border:3px solid #222;
							background-color:#111;
							padding:3px;
						}
						.timer.active {
							color:#F00;
						}
						.button {
							display:table-cell;
							color:#0A0;
							font-weight:bold;
							text-align:src.get_center();
							vertical-align:middle;
							border:3px solid #222;
							background-color:#111;
							padding:3px;
						}
						.button.timer_b {
							width:50px;
						}
						/*
						.button:hover {
							background-color:#222;
							border:3px solid #333;
						}
						*/
						#abort {
							color:#000;
							background-color:#A00;
						}
						/*
						#abort:hover {
							background-color:#600;
						}
						*/
						#prime {
							color:#000;
							background-color:#0A0;
						}
						/*
						#prime:hover {
							background-color:#060;
						}
						*/

						.timer_table {
							text-align:src.get_center();
							vertical-align:middle;
							width:200px;
						}
					</style>

				</head>
				<body bgcolor=#555>
					<div class="timing_div top_level">
						<table class="timer_table">
							<tr>
								<td class="timer[src.timing ? " active" : ""]" colspan=4>[src.get_time()]</td>
							</tr>

							<tr>
								<td>
									<a href="byond://?src=\ref[src];action=timer;tp=-30">
										<div class="button timer_b">
											--
										</div>
									</a>
								</td>
								<td>
									<a href="byond://?src=\ref[src];action=timer;tp=-1">
										<div class="button timer_b">
											-
										</div>
									</a>
								</td>
								<td>
									<a href="byond://?src=\ref[src];action=timer;tp=1">
										<div class="button timer_b">
											+
										</div>
									</a>
								</td>
								<td>
									<a href="byond://?src=\ref[src];action=timer;tp=30">
										<div class="button timer_b">
											++
										</div>
									</a>
								</td>
							</tr>
							<tr>
								<td colspan=2>
									<a href="byond://?src=\ref[src];action=trigger;spec=abort">
										<div class="button" id="abort">
											Abort
										</div>
									</a>
								</td>
								<td colspan=2>
									<a href="byond://?src=\ref[src];action=trigger;spec=prime">
										<div class="button" id="prime">
											Prime
										</div>
									</a>
								</td>
							</tr>
						</table>
					</div>
				</body>
			</html>"}

#undef UNWRENCHED
#undef WRENCHED
#undef WELDED
