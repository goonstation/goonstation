/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT
	p_class = 2

	var/has_valve = 1
	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/casecolor = "blue"
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	desc = "A container which holds a large amount of the labelled gas. It's possible to transfer the gas to a pipe system, the air, or to a tank that you attach to it."
	var/overpressure = 0 // for canister explosions
	var/rupturing = 0
	var/obj/item/assembly/detonator/det = null
	var/overlay_state = null
	var/dialog_update_enabled = 1 //For preventing the DAMNABLE window taking focus when manually inputting pressure

	var/global/image/atmos_dmi = image('icons/obj/atmospherics/atmos.dmi')
	var/global/image/bomb_dmi = image('icons/obj/canisterbomb.dmi')

	onMaterialChanged()
		..()
		if(istype(src.material))
			temperature_resistance = 400 + T0C + (((src.material.getProperty("flammable") - 50) * (-1)) * 3)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.release_pressure < 5*ONE_ATMOSPHERE || MIXTURE_PRESSURE(src.air_contents) < 5*ONE_ATMOSPHERE)
			return 0
		user.visible_message("<span class='alert'><b>[user] holds [his_or_her(user)] mouth to [src]'s release valve and briefly opens it!</b></span>")
		user.gib()
		return 1

	powered()
		return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	casecolor = "redws"
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	casecolor = "red"
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Plasma\]"
	icon_state = "orange"
	casecolor = "orange"
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	casecolor = "black"
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	casecolor = "grey"
	filled = 2.0
/obj/machinery/portable_atmospherics/canister/air/large
	name = "High-Volume Canister \[Air\]"
	icon_state = "greyred"
	casecolor = "greyred"
	filled = 5.0
/obj/machinery/portable_atmospherics/canister/empty
	name = "Canister \[Empty\]"
	icon_state = "empty"
	casecolor = "empty"

/obj/machinery/portable_atmospherics/canister/New()
	..()

/obj/machinery/portable_atmospherics/canister/update_icon()

	if (src.destroyed)
		src.icon_state = "[src.casecolor]-1"
		ClearAllOverlays()
	else
		icon_state = "[casecolor]"
		if (overlay_state)
			if (src.det.part_fs.timing && !src.det.safety && !src.det.defused)
				if (src.det.part_fs.time > 5)
					bomb_dmi.icon_state = "overlay_ticking"
					UpdateOverlays(bomb_dmi, "canbomb")
				else
					bomb_dmi.icon_state = "overlay_exploding"
					UpdateOverlays(bomb_dmi, "canbomb")
			else
				bomb_dmi.icon_state = overlay_state
				UpdateOverlays(bomb_dmi, "canbomb")
		else
			UpdateOverlays(null, "canbomb")

		if(holding)
			atmos_dmi.icon_state = "can-oT"
			UpdateOverlays(atmos_dmi, "holding")
		else
			UpdateOverlays(null, "holding")
		var/tank_pressure = MIXTURE_PRESSURE(air_contents)

		if (tank_pressure < 10)
			atmos_dmi.icon_state = "can-o0"
		else if (tank_pressure < ONE_ATMOSPHERE)
			atmos_dmi.icon_state = "can-o1"
		else if (tank_pressure < 15*ONE_ATMOSPHERE)
			atmos_dmi.icon_state = "can-o2"
		else
			atmos_dmi.icon_state = "can-o3"

		UpdateOverlays(atmos_dmi, "pressure")
	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(reagents) reagents.temperature_reagents(exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		message_admins("[src] was destructively opened, emptying contents at [log_loc(src)]. See station logs for atmos readout.")
		logTheThing("station", null, null, "[src] [log_atmos(src)] was destructively opened, emptying contents at [log_loc(src)].")

		var/atom/location = src.loc
		location.assume_air(air_contents)
		air_contents = null

		if (src.det)
			processing_items.Remove(src.det)

		src.destroyed = 1
		playsound(src.loc, "sound/effects/spray.ogg", 10, 1, -3)
		src.set_density(0)
		update_icon()

		if (src.holding)
			src.holding.set_loc(src.loc)
			src.holding = null
		return 1
	else
		return 1


/obj/machinery/portable_atmospherics/canister/process()
	if (!loc) return
	if (destroyed) return
	if (src.contained) return

	..()

	var/datum/gas_mixture/environment

	if(holding)
		environment = holding.air_contents
	else
		environment = loc.return_air()

	if (!environment)
		return

	var/env_pressure = MIXTURE_PRESSURE(environment)

	if(valve_open)
		var/pressure_delta = min(release_pressure - env_pressure, (MIXTURE_PRESSURE(air_contents) - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)

	overpressure = MIXTURE_PRESSURE(air_contents) / maximum_pressure

	switch(overpressure) // should the canister blow the hell up?

		if(-INFINITY to 12)
			if(rupturing) rupturing = 0
		if(12 to 14)
			if(prob(4))
				src.visible_message("<span class='alert'>[src] hisses!</span>")
				playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
		if(14 to 16)
			if(prob(3) && !rupturing)
				rupture()
		if (16 to INFINITY)
			if (!rupturing)
				rupture()

	//Canister bomb grumpy sounds
	if (src.det && src.det.part_fs)
		if (src.det.part_fs.timing) //If it's counting down
			if (src.det.part_fs.time > 9)
				src.add_simple_light("canister", list(0.94 * 255, 0.94 * 255, 0.3 * 255, 0.6 * 255))
				if (prob(15))
					switch(rand(1,10))
						if (1)
							playsound(src.loc, "sparks", 75, 1, -1)
							elecflash(src)
						if (2)
							playsound(src.loc, "sound/machines/warning-buzzer.ogg", 50, 1)
						if (3)
							playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
						if (4)
							playsound(src.loc, "sound/machines/bellalert.ogg", 50, 1)
						if (5)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 0
								theAPC.updateicon()
								theAPC.update()
								src.visible_message("<span class='alert'>The lights mysteriously go out!</span>")
						if (6)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 3
								theAPC.updateicon()
								theAPC.update()

			else if (src.det.part_fs.time < 10 && src.det.part_fs.time > 7)  //EXPLOSION IMMINENT
				src.add_simple_light("canister", list(1 * 255, 0.03 * 255, 0.03 * 255, 0.6 * 255))
				src.visible_message("<span class='alert'>[src] flashes and sparks wildly!</span>")
				playsound(src.loc, "sound/machines/siren_generalquarters.ogg", 50, 1)
				playsound(src.loc, "sparks", 75, 1, -1)
				elecflash(src,power = 2)
			else if (src.det.part_fs.time <= 3)
				playsound(src.loc, "sound/machines/warning-buzzer.ogg", 50, 1)
		else //Someone might have defused it or the bomb failed
			src.remove_simple_light("canister")

	if(dialog_update_enabled) src.updateDialog()
	src.update_icon()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/blob_act(var/power)
	src.health -= power / 10
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/proc/rupture() // cogwerks- high pressure tank explosions
	if (src.det)
		del(src.det) //Otherwise canister bombs detonate after rupture
	if (!destroyed)
		rupturing = 1
		SPAWN_DBG(1 SECOND)
			src.visible_message("<span class='alert'>[src] hisses ominously!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 55, 1)
			sleep(5 SECONDS)
			playsound(src.loc, "sound/machines/hiss.ogg", 60, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] hisses loudly!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] bulges!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] cracks!</span>")
			playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 65, 1)
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			if(rupturing && !destroyed) // has anyone drained the tank?
				playsound(src.loc, "explosion", 70, 1)
				src.visible_message("<span class='alert'>[src] ruptures violently!</span>")
				src.health = 0
				src.disconnect()
				healthcheck()
				var/T = get_turf(src)

				for(var/obj/window/W in range(4, T)) // smash shit
					if(prob( get_dist(W,T)*6 ))
						continue
					W.health = 0
					W.smash()

				for(var/obj/displaycase/D in range(4,T))
					D.ex_act(1)

				for(var/obj/item/reagent_containers/glass/G in range(4,T))
					G.smash()

				for(var/obj/item/reagent_containers/food/drinks/drinkingglass/G in range(4,T))
					G.smash()

				for(var/atom/movable/A in view(3, T)) // wreck shit
					if(A.anchored) continue
					if(ismob(A))
						var/mob/M = A
						M.changeStatus("weakened", 80)
						random_brute_damage(M, 20)//armor won't save you from the pressure wave or something
						var/atom/targetTurf = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
						M.throw_at(targetTurf, 200, 4)
					else if (prob(50)) // cut down the number of things that get blown around
						var/atom/targetTurf = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
						A.throw_at(targetTurf, 200, 4)

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if (istype(W, /obj/item/assembly/detonator)) //Wire: canister bomb stuff
		if (holding)
			user.show_message("<span class='alert'>You must remove the currently inserted tank from the slot first.</span>")
		else
			var/obj/item/assembly/detonator/Det = W
			if (Det.det_state != 4)
				user.show_message("<span class='alert'>The assembly is incomplete.</span>")
			else
				Det.loc = src
				Det.master = src
				Det.layer = initial(W.layer)
				user.u_equip(Det)
				overlay_state = "overlay_safety_on"
				src.det = Det
				src.det.attachedTo = src
				src.det.builtBy = usr
				logTheThing("bombing", user, null, "builds a canister bomb [log_atmos(src)] at [log_loc(src)].")
				message_admins("[key_name(user)] builds a canister bomb at [log_loc(src)]. See bombing logs for atmos readout.")
	else if (src.det && istype(W, /obj/item/tank))
		user.show_message("<span class='alert'>You cannot insert a tank, as the slot is shut closed by the detonator assembly.</span>")
	else if (src.det && W && istool(W, TOOL_PULSING | TOOL_SNIPPING))
		src.attack_hand(user)

	if (istype(W, /obj/item/cargotele))
		W:cargoteleport(src, user)
		return
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (porter.contents.len >= porter.capacity) boutput(user, "<span class='alert'>Your [W] is full!</span>")
		else if (src.anchored) boutput(user, "<span class='alert'>\The [src] is attached!</span>")
		else
			user.visible_message("<span class='notice'>[user] collects the [src].</span>", "<span class='notice'>You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			elecflash(src)
	if(!iswrenchingtool(W) && !istype(W, /obj/item/tank) && !istype(W, /obj/item/device/analyzer/atmospheric) && !istype(W, /obj/item/device/pda2))
		src.visible_message("<span class='alert'>[user] hits the [src] with a [W]!</span>")
		logTheThing("combat", user, null, "attacked [src] [log_atmos(src)] with [W] at [log_loc(src)].")
		src.health -= W.force
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	if(!src.connected_port && get_dist(src, user) > 7)
		return
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	if (src.destroyed)
		return

	src.add_dialog(user)
	var/holding_text
	var/safety_text
	var/det_text
	var/det_attachments_text
	var/timer_text
	var/trigger_text
	var/detonate_text
	var/valve_text
	var/anchor_text
	var/wires_text
	//var/df_code_text //WIRE TODO: finish det codes
	var/note_text
	var/width = 600
	var/height = 300

	if(holding)
		holding_text = {"
		<hr><b>Inserted</b>: [holding] <a href='?src=\ref[src];remove_tank=1'>(Remove)</a>
		<br>Pressure: [MIXTURE_PRESSURE(holding.air_contents)] kPa
		<br>[fancy_pressure_bar(MIXTURE_PRESSURE(holding.air_contents), 10 * ONE_ATMOSPHERE)]
		"}

	if (src.has_valve)
		valve_text = {"
			<b>Release Valve</b>: <A href='?src=\ref[src];toggle=1'>[valve_open ? "Open" : "Closed"]</A> - Release Pressure: <A href='?src=\ref[src];pressure_adj=-10000'>Min</A> &middot; <b><A href='?src=\ref[src];setpressure=1'>[release_pressure]</A></b> &middot; <A href='?src=\ref[src];pressure_adj=10000'>Max</A>
			"}
	else
		valve_text = {"
			<b>Release Valve</b>: Valve missing. [valve_open ? "The canister is leaking" : ""].
			"}

	if (src.det) //Wire: canister bomb stuff
		width = 700
		height = 520
		var/i
		for (i = 1, i <= src.det.WireNames.len, i++)
			wires_text += "[src.det.WireNames[i]]: "
			if (src.det.WireStatus[i])
				wires_text += "<A href='?src=\ref[src];cut=[i]'>Cut</A> | <A href='?src=\ref[src];pulse=[i]'>Pulse</A>"
			else
				wires_text += "cut"
			wires_text += "<BR>"

		if (src.det.defused) //Detonator header
			det_text = {"<b>A detonator is secured to the canister.</b><BR><BR>
						Detonator wires:<BR>
						[wires_text]<BR><BR>
						The detonator has been defused. It cannot be detonated anymore."}
		else
			if (src.det.part_fs.timing) //Timer
				var/second = src.det.part_fs.time % 60
				var/minute = (src.det.part_fs.time - second) / 60
				minute = (minute < 10 ? "0[minute]" : "[minute]")
				second = (second < 10 ? "0[second]" : "[second]")
				if (src.det.part_fs.time < 10 && src.det.part_fs.time > 0)
					timer_text = "<div class='timer warning'>[minute]:[second]</div>"
				else if (src.det.part_fs.time < 0) //fuckin byond goes below zero sometimes due to lag/byond being byond
					timer_text = "<div class='timer warning'>[pick("OHGOD", "HELP!", "BZZAP", "OH:NO", "B-Y-E")]</div>"
				else
					timer_text = "<div class='timer counting'>[minute]:[second]</div>"
			else
				timer_text = "<div class='timer'>--:--</div>"
				timer_text += "<A href='?src=\ref[src];timer=1' class='setTime'>Set Timer</A>"

			safety_text = "<b>Safety: </b>"
			if (src.det.safety)
				safety_text += "<A href='?src=\ref[src];safety=1'>Turn Off</A> (Note: This cannot be undone)"
			else
				safety_text += "Off."

			anchor_text = "<b>Anchor Status: </b>"
			if (!anchored)
				anchor_text += "<A href='?src=\ref[src];anchor=1'>Anchor</a>"
			else
				anchor_text += "Anchored. There are no controls for undoing this."

			trigger_text = "<b>Trigger: </b>"
			if (src.det.trigger)
				trigger_text += "<A href='?src=\ref[src];trigger=1'>[src.det.trigger.name]</A>"
			else
				trigger_text += "There is no trigger attached."

			var/det_attachments_list
			for (var/obj/item/a in src.det.attachments)
				det_attachments_list += "There is \an [a] wired onto the assembly as an attachment.<br>"
				height += 33

			if (det_attachments_list)
				det_attachments_text += "<b>Attachments: </b><br>"
				det_attachments_text += det_attachments_list

			detonate_text = "<b>Arming: </b>"
			if (src.det.defused) //Detonator/priming
				detonate_text += "The detonator is defused. You cannot prime the bomb."
			else if (src.det.safety)
				detonate_text += "The safety is on, therefore, you cannot prime the bomb."
			else if (src.det.part_fs.timing)
				detonate_text += "<b><font color=#FF0000>PRIMED</font></b>"
			else
				detonate_text += "<A href='?src=\ref[src];detonate=1'>Prime</A>"

			/* WIRE TODO: finish det codes
			df_code_text = "<b>Defusal Code: </b>"
			if (src.det.dfcodeSet)
				df_code_text += "<A href='?src=\ref[src];defuseCode=1'>Set Code</A>"
			else
				df_code_text += "<A href='?src=\ref[src];defuseCode=1'>Enter Code</A>"
			*/

			note_text = ""
			if (src.det.note)
				note_text = "<div class='note'>[src.det.note]</div>"

			det_text = {"
							<style>
								.det {position: relative;}
								.det .timer {position: absolute; top: 30px; right: 30px; font-size: 2em; font-family: \"Courier New\", Courier, monospace; line-height: 1; background: #111; padding: 5px 10px; color: green;}
								.det .timer.counting {color: orange;}
								.det .timer.warning {color: red;}
								.det a {display: inline-block;}
								.det .note {position: absolute; top: 105px; right: 30px; font-size: 0.75em; max-width: 250px; width: 250px; font-family: \"Courier New\", Courier, monospace; border-bottom: 2px solid black; border-right: 2px solid black; padding: 3px; border-top: 1px solid #888840; border-left: 1px solid #888840; background: #FFFFA5; color: black;}
								.setTime {position: absolute; top: 80px; right: 35px; line-height: 1;}
							</style>
							<hr>
							<b>A detonator is secured to the canister.</b><BR><BR>
							Detonator wires:<br>
							[wires_text]<br>
							[anchor_text]<br>
							[trigger_text]<br>
							[safety_text]<br>
							[detonate_text]<br>
							[det_attachments_text]
							[timer_text]
							[note_text]
						"}

	//var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? "<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><meta http-equiv=\"pragma\" content=\"no-cache\"><style type='text/css'>body { font-family: Tahoma, sans-serif; font-size: 10pt; }</style></head><body>" : ""

	var/output_text = {"<div id="canister">
							<div class="header">
								<b>[name]</b> [connected_port ? "<em>(Connected to port)</em>" : ""]
								<br>Pressure: [MIXTURE_PRESSURE(air_contents)] kPa
								<br>[fancy_pressure_bar(MIXTURE_PRESSURE(air_contents), maximum_pressure)]
								<br>[valve_text]
								[holding_text]
							</div>
							<div class="det">
								[det_text]
							</div>
							<hr>
							<A href='?action=mach_close&window=canister'>Close</A><BR>
						</div>"}

	user.Browse(output_text, "window=canister;size=[width]x[height]")
	onclose(user, "canister")
	return

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)
	if(..())
		return
	if (usr.stat || usr.restrained())
		return
	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		src.add_dialog(usr)

		if(href_list["toggle"])
			valve_open = !valve_open
			if(!holding && !connected_port)
				logTheThing("station", usr, null, "[valve_open ? "opened [src] into" : "closed [src] from"] the air [log_atmos(src)] at [log_loc(src)].")
				playsound(src.loc, "sound/effects/valve_creak.ogg", 50, 1)
				playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
				if(valve_open)
					message_admins("[key_name(usr)] opened [src] into the air at [log_loc(src)]. See station logs for atmos readout.")
					if (src.det)
						src.det.leaking()

		if (href_list["remove_tank"])
			if(holding)
				holding.set_loc(loc)
				usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
				holding = null
				valve_open = 0					// its the future its got an auto-close valve ok
				// im leaving this here in case it ever gets turned on again
				if(valve_open && !connected_port)
					message_admins("[key_name(usr)] removed a tank from [src], opening it into the air at [log_loc(src)]. See station logs for atmos readout.")
					logTheThing("station", usr, null, "removed a tank from [src] [log_atmos(src)], opening it into the air at [log_loc(src)].")

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			playsound(src.loc, "sound/effects/valve_creak.ogg", 20, 1)
			if(diff > 0)
				release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
			else
				release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

		if (href_list["setpressure"])
			playsound(src.loc, "sound/effects/valve_creak.ogg", 20, 1)
			dialog_update_enabled = 0
			var/change = input(usr,"Target Pressure ([ONE_ATMOSPHERE/10]-[10*ONE_ATMOSPHERE]):","Enter target pressure",release_pressure) as num
			dialog_update_enabled = 1
			if(!isnum(change)) return
			release_pressure = min(max(ONE_ATMOSPHERE/10, change),10*ONE_ATMOSPHERE)
			src.updateUsrDialog()
			return

		//Wire: canister bomb stuff start
		if (href_list["anchor"])
			src.anchored = 1

		if (href_list["trigger"])
			src.det.trigger.attack_self(usr)

		if (href_list["timer"])
			src.det.part_fs.attack_self(usr)

		if (href_list["safety"])
			src.det.safety = 0
			overlay_state = "overlay_safety_off"

		if (href_list["cut"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				usr.show_message("<span class='alert'>You need to have a snipping tool equipped for this.</span>")
			else
				if (src.det.shocked)
					var/mob/living/carbon/human/H = usr
					H.show_message("<span class='alert'>You tried to cut a wire on the bomb, but got burned by it.</span>")
					H.TakeDamage("chest", 0, 30)
					H.changeStatus("stunned", 150)
					H.UpdateDamageIcon()
				else
					var/index = text2num(href_list["cut"])
					src.visible_message("<b><font color=#B7410E>[usr.name] cuts the [src.det.WireNames[index]] on the detonator.</font></b>")
					switch (src.det.WireFunctions[index])
						if ("detonate")
							playsound(src.loc, "sound/machines/whistlealert.ogg", 50, 1)
							playsound(src.loc, "sound/machines/whistlealert.ogg", 50, 1)
							src.visible_message("<B><font color=#B7410E>The failsafe timer beeps three times before going quiet forever.</font></B>")
							SPAWN_DBG(0)
								src.det.detonate()
						if ("defuse")
							playsound(src.loc, "sound/machines/ping.ogg", 50, 1)
							src.visible_message("<B><font color=#32CD32>The detonator assembly emits a sighing, fading beep. The bomb has been disarmed.</font></B>")
							src.det.defused = 1
						if ("safety")
							if (!src.det.safety)
								src.visible_message("<B><font color=#B7410E>Nothing appears to happen.</font></B>")
							else
								playsound(src.loc, "sound/machines/click.ogg", 50, 1)
								src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
								src.det.safety = 0
							src.det.failsafe_engage()
						if ("losetime")
							src.det.failsafe_engage()
							playsound(src.loc, "sound/machines/twobeep.ogg", 50, 1)
							if (src.det.part_fs.time > 7)
								src.det.part_fs.time -= 7
							else
								src.det.part_fs.time = 2
							src.visible_message("<B><font color=#B7410E>The failsafe beeps rapidly for two moments. The external display indicates that the timer has reduced to [src.det.part_fs.time] seconds.</font></B>")
						if ("mobility")
							src.det.failsafe_engage()
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							if (anchored)
								src.visible_message("<B><font color=#B7410E>A faint click is heard from inside the canister, but the effect is not immediately apparent.</font></B>")
							else
								anchored = 1
								src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
						if ("leak")
							src.det.failsafe_engage()
							has_valve = 0
							valve_open = 1
							release_pressure = 10 * ONE_ATMOSPHERE
							src.visible_message("<B><font color=#B7410E>An electric buzz is heard before the release valve flies off the canister.</font></B>")
							playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
							src.det.leaking()
						else
							src.det.failsafe_engage()
							if (src.det.part_fs.timing)
								var/obj/item/attachment = src.det.WireFunctions[index]
								attachment.detonator_act("cut", src.det)

					src.det.WireStatus[index] = 0

		if (href_list["pulse"])
			if (!usr.find_tool_in_hand(TOOL_PULSING))
				usr.show_message("<span class='alert'>You need to have a multitool or similar equipped for this.</span>")
			else
				if (src.det.shocked)
					var/mob/living/carbon/human/H = usr
					H.show_message("<span class='alert'>You tried to pulse a wire on the bomb, but got burned by it.</span>")
					H.TakeDamage("chest", 0, 30)
					H.changeStatus("stunned", 150)
					H.UpdateDamageIcon()
				else
					var/index = text2num(href_list["pulse"])
					src.visible_message("<b><font color=#B7410E>[usr.name] pulses the [src.det.WireNames[index]] on the detonator.</font></b>")
					switch (src.det.WireFunctions[index])
						if ("detonate")
							if (src.det.part_fs.timing)
								playsound(src.loc, "sound/machines/buzz-sigh.ogg", 50, 1)
								if (src.det.part_fs.time > 7)
									src.det.part_fs.time = 7
									src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and sets itself to 7 seconds.</font></B>")
								else
									src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes refusingly before going quiet forever.</font></B>")
									SPAWN_DBG(0)
										src.det.detonate()
							else
								src.det.failsafe_engage()
								src.det.part_fs.time = rand(8,14)
								playsound(src.loc, "sound/machines/pod_alarm.ogg", 50, 1)
								src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and activates. You have [src.det.part_fs.time] seconds to act.</font></B>")
						if ("defuse")
							src.det.failsafe_engage()
							if (src.det.grant)
								src.det.part_fs.time += 5
								playsound(src.loc, "sound/machines/ping.ogg", 50, 1)
								src.visible_message("<B><font color=#B7410E>The detonator assembly emits a reassuring noise. You notice that the failsafe timer has increased to [src.det.part_fs.time] seconds.</font></B>")
								src.det.grant = 0
							else
								playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 1)
								src.visible_message("<B><font color=#B7410E>The detonator assembly emits a sinister noise, but there are no apparent changes visible externally.</font></B>")
						if ("safety")
							playsound(src.loc, "sound/machines/twobeep.ogg", 50, 1)
							if (!src.det.safety)
								src.visible_message("<B><font color=#B7410E>The display flashes with no apparent outside effect.</font></B>")
							else
								src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
								src.det.safety = 0
						if ("losetime")
							src.det.failsafe_engage()
							src.det.shocked = 1
							var/losttime = rand(2,5)
							src.visible_message("<B><font color=#B7410E>The bomb buzzes oddly, emitting electric sparks. It would be a bad idea to touch any wires for the next [losttime] seconds.</font></B>")
							playsound(src.loc, "sparks", 75, 1, -1)
							elecflash(src,power = 2)
							SPAWN_DBG(10 * losttime)
								src.det.shocked = 0
								src.visible_message("<B><font color=#B7410E>The buzzing stops, and the countdown continues.</font></B>")
						if ("mobility")
							src.det.failsafe_engage()
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							if (anchored)
								anchored = 0
								src.visible_message("<B><font color=#B7410E>A loud click is heard from the inside the canister, unsecuring itself.</font></B>")
							else
								anchored = 1
								src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
						if ("leak")
							src.det.failsafe_engage()
							playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
							if (prob(min(src.det.leaks * 8, 100)))
								has_valve = 0
								valve_open = 1
								release_pressure = 10 * ONE_ATMOSPHERE
								src.visible_message("<B><font color=#B7410E>An electric buzz is heard before the release valve flies off the canister.</font></B>")
							else
								valve_open = 1
								release_pressure = min(10, src.det.leaks + 1) * ONE_ATMOSPHERE
								src.visible_message("<B><font color=#B7410E>The release valve rumbles a bit, leaking some of the gas into the air.</font></B>")
							src.det.leaking()
							src.det.leaks++
						else
							src.det.failsafe_engage()
							if (src.det.part_fs.timing)
								var/obj/item/attachment = src.det.WireFunctions[index]
								attachment.detonator_act("pulse", src.det)

		if (href_list["detonate"])
			SPAWN_DBG(0)
				src.det.failsafe_engage()

		/* WIRE TODO: finish det codes
		if (href_list["defuseCode"])
			if (src.det.dfcodeSet) //code already programmed in
				var/code = copytext(input(usr, "[src.det.dfcodeTries] attempts left", "Enter defusal code (4 digits)") as num, 1, 4)
				if (length(code) != 4) return ..()
				if (code == src.det.dfcode) //defused!
					playsound(src.loc, "sound/machines/ping.ogg", 50, 1)
					src.visible_message("<B><font color=#32CD32>The detonator assembly emits a sighing, fading beep. The bomb has been disarmed.</font></B>")
					src.det.defused = 1
				else
					if (src.det.dfcodeTries >= 1) //still more tries left
						playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 1)
						src.visible_message("<B><font color=#B7410E>The detonator bloops an annoyed tone. Wrong code! \[[src.det.dfcodeTries] attempts remaining\]</font></B>")
						src.det.dfcodeTries = src.det.dfcodeTries - 1
					else //uh oh! kaboom!
						playsound(src.loc, "sound/machines/whistlealert.ogg", 50, 1)
						src.visible_message("<B><font color=red>The detonator rumbles menacingly. The timer changes to 3 seconds remaining. Oh dear.</font></B>")
						src.det.part_fs.time = 3
			else //still gotta set dat code yo
				var/code = copytext(input(usr, "[src.det.dfcodeTries] attempts left", "Enter defusal code (4 digits)") as num, 1, 4)
				boutput(world, "[length(code)]")
		*/

		//Wire: canister bomb stuff end

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr.Browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)

	//if (src.det)
	//	src.det.detonate()
	//	return

	if(src.material) src.material.triggerOnBullet(src, src, P)

	if(P.proj_data.damage_type == D_KINETIC)
		src.health -= damage
	else if(P.proj_data.damage_type == D_PIERCING)
		src.health -= (damage * 2)
	else if(P.proj_data.damage_type == D_ENERGY)
		src.health -= damage
	log_shot(P,src)
	SPAWN_DBG( 0 )
		healthcheck()
		return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	if(!air_contents.trace_gases)
		air_contents.trace_gases = list()
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.temperature = 80
	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1
