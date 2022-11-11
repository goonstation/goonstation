/datum/hud/pod
	var/atom/movable/screen/hud
		engine
		life_support
		comms
		sensors
		sensors_use
		weapon
		secondary
		lock
		set_code
		rts
		wormhole
		use_comms
		leave
		rcs
		lights
		tracking
		sensor_lock

	click_check = 0
	var/image/missing
	var/datum/healthBar/health_bar
	var/obj/machinery/vehicle/master

	New(P)
		..()
		master = P
		missing = image('icons/mob/hud_pod.dmi', "marker")
		engine = create_screen("engine", "Engine", 'icons/mob/hud_pod.dmi', "engine-off", "NORTH+1,WEST", tooltipTheme = "pod-alt", desc = "Turn the pod's engine on or off (you probably don't want to turn it off)")
		wormhole = create_screen("wormhole", "Create Wormhole", 'icons/mob/hud_pod.dmi', "wormhole", "NORTH+1,WEST+1", tooltipTheme = "pod", desc = "Open a wormhole to a beacon that you can fly through")
		life_support = create_screen("life_support", "Life Support", 'icons/mob/hud_pod.dmi', "life_support-off", "NORTH+1,WEST+2", tooltipTheme = "pod-alt", desc = "Turn life support on or off")
		comms = create_screen("comms", "Comms", 'icons/mob/hud_pod.dmi', "comms-off", "NORTH+1,WEST+3", tooltipTheme = "pod-alt", desc = "Turn the pod's communications system on or off")
		use_comms = create_screen("comms_system", "Use Comms System", 'icons/mob/hud_pod.dmi', "comms_system", "NORTH+1,WEST+4", tooltipTheme = "pod", desc = "Use the communications system to talk or whatever")
		sensors = create_screen("sensors", "Sensors", 'icons/mob/hud_pod.dmi', "sensors-off", "NORTH+1,WEST+5", tooltipTheme = "pod-alt", desc = "Turn the pod's sensors on or off")
		sensors_use = create_screen("sensors_use", "Activate Sensors", 'icons/mob/hud_pod.dmi', "sensors-use", "NORTH+1,WEST+6", tooltipTheme = "pod", desc = "Use the pod's sensors to search for drones and lifeforms nearby")
		weapon = create_screen("weapon", "Main Weapon", 'icons/mob/hud_pod.dmi', "weapon-off", "NORTH+1,WEST+7", tooltipTheme = "pod-alt", desc = "Turn the main weapon on or off, if the pod is equipped with one")
		lights = create_screen("lights", "Toggle Lights", 'icons/mob/hud_pod.dmi', "lights_off", "NORTH+1, WEST+8", tooltipTheme = "pod", desc = "Turn the pod's external lights on or off")
		secondary = create_screen("secondary", "Secondary System", 'icons/mob/hud_pod.dmi', "blank", "NORTH+1,WEST+9", tooltipTheme = "pod", desc = "Enable or disable the secondary system installed in the pod, if there is one")
		lock = create_screen("lock", "Lock", 'icons/mob/hud_pod.dmi', "lock-locked", "NORTH+1,WEST+10", tooltipTheme = "pod-alt", desc = "LOCK YOUR PODS YOU DOOFUSES")
		set_code = create_screen("set_code", "Set Lock code", 'icons/mob/hud_pod.dmi', "set-code", "NORTH+1,WEST+11", tooltipTheme = "pod", desc = "Set the code used to unlock the pod")
		rts = create_screen("return_to_station", "Return To [capitalize(station_or_ship())]", 'icons/mob/hud_pod.dmi', "return-to-station", "NORTH+1,WEST+12", tooltipTheme = "pod", desc = "Using this will place you on the station Z-level the next time you fly off the edge of the current level")
		leave = create_screen("leave", "Leave Pod", 'icons/mob/hud_pod.dmi', "leave", "SOUTH,EAST", tooltipTheme = "pod-alt", desc = "Get out of the pod")
		rcs = create_screen("rcs", "Toggle RCS", 'icons/mob/hud_pod.dmi', "rcs-off", "NORTH+1,WEST+13", tooltipTheme = "pod-alt", desc = "Reduce the pod's relative velocity")
		tracking = create_screen("tracking", "Tracking Indicator", 'icons/mob/hud_pod.dmi', "off", "CENTER, CENTER")
		tracking.mouse_opacity = 0
		sensor_lock = create_screen("sensor_lock", "Sensor Lock", 'icons/mob/hud_pod.dmi', "off", "SOUTH+1,EAST")
		sensor_lock.mouse_opacity = 0	//maybe set to one, so that clicking on it will explain what it is
		health_bar = new(3)
		health_bar.add_to_hud(src)
		if (master)
			update_health()
			update_systems()
			update_states()

	clear_master()
		master = null
		..()

	proc/detach_all_clients()
		for (var/client/C in clients)
			remove_client(C)

			if (C.tooltipHolder)
				C.tooltipHolder.inPod = 0

	proc/check_clients()
		for (var/client/C in clients)
			var/mob/M = C.mob
			if (M.loc != master)
				remove_client(C)

				if (C.tooltipHolder)
					C.tooltipHolder.inPod = 0

	proc/check_hud_layout(mob/user)
		if (user.client.tg_layout)
			leave.screen_loc = "SOUTH,EAST-6"
		else
			leave.screen_loc = "SOUTH,EAST"

	proc/update_health()
		check_clients()
		health_bar.update_health_overlay(master.health, master.maxhealth, 0, 0)

	proc/update_states()
		check_clients()
		if (master.engine)
			if (master.engine.active)
				engine.icon_state = "engine-on"
				wormhole.overlays.len = 0
			else
				engine.icon_state = "engine-off"
				if (!wormhole.overlays.len)
					wormhole.overlays += missing

		if (master.life_support)
			if (master.life_support.active)
				life_support.icon_state = "life_support-on"
			else
				life_support.icon_state = "life_support-off"

		if (master.com_system)
			if (master.com_system.active)
				comms.icon_state = "comms-on"
				rts.overlays.len = 0
				use_comms.overlays.len = 0
			else
				comms.icon_state = "comms-off"
				if (!rts.overlays.len)
					rts.overlays += missing
				if (!use_comms.overlays.len)
					use_comms.overlays += missing

		if (master.m_w_system)
			if (master.m_w_system.active)
				weapon.icon_state = "weapon-on"
			else
				weapon.icon_state = "weapon-off"

		if (master.sec_system)
			if (master.sec_system.f_active)
				secondary.icon_state = master.sec_system.hud_state
			else if (master.sec_system.active)
				secondary.icon_state = "[master.sec_system.hud_state]-on"
			else
				secondary.icon_state = "[master.sec_system.hud_state]-off"

		if (master.sensors)
			if (master.sensors.active)
				sensors.icon_state = "sensors-on"
				sensors_use.overlays.len = 0
			else
				sensors.icon_state = "sensors-off"
				if (!sensors_use.overlays.len)
					sensors_use.overlays += missing

		if (master.lock)
			if (master.lock.code && master.locked)
				lock.icon_state = "lock-locked"
			else
				lock.icon_state = "lock-unlocked"
		if (master.lights)
			if (master.lights.active)
				lights.icon_state = "lights_on"
			else
				lights.icon_state = "lights_off"

		if (master.rcs)
			rcs.icon_state = "rcs-on"
		else
			rcs.icon_state = "rcs-off"


	proc/update_systems()
		check_clients()
		if (master.engine)
			engine.name = master.engine.name
			engine.overlays.len = 0
		else
			engine.name = "Engine"
			if (!engine.overlays.len)
				engine.overlays += missing

		if (master.life_support)
			life_support.name = master.life_support.name
			life_support.overlays.len = 0
		else
			life_support.name = "Life Support"
			if (!life_support.overlays.len)
				life_support.overlays += missing

		if (master.com_system)
			comms.name = master.com_system.name
			comms.overlays.len = 0
			if (!master.com_system.active)
				if (!rts.overlays.len)
					rts.overlays += missing
				if (!use_comms.overlays.len)
					use_comms.overlays += missing
			else
				rts.overlays.len = 0
				use_comms.overlays.len = 0
		else
			comms.name = "Comms"
			if (!comms.overlays.len)
				comms.overlays += missing
			if (!rts.overlays.len)
				rts.overlays += missing
			if (!use_comms.overlays.len)
				use_comms.overlays += missing

		if (master.m_w_system)
			weapon.name = master.m_w_system.name
			weapon.overlays.len = 0
		else
			weapon.name = "Main Weapon"
			if (!weapon.overlays.len)
				weapon.overlays += missing

		if (master.sec_system)
			secondary.name = master.sec_system.name
			secondary.overlays.len = 0
		else
			secondary.name = "Secondary System"
			if (!secondary.overlays.len)
				secondary.overlays += missing
			secondary.icon_state = "blank"

		if (master.sensors)
			sensors.name = master.sensors.name
			sensors.overlays.len = 0
			if (!master.sensors.active)
				sensors_use.overlays.len = 0
			else
				if (!sensors_use.overlays.len)
					sensors_use.overlays += missing
		else
			sensors.name = "Sensors"
			if (!sensors.overlays.len)
				sensors.overlays += missing
			if (!sensors_use.overlays.len)
				sensors_use.overlays += missing

		if (master.lock)
			lock.name = master.lock.name
			lock.overlays.len = 0
			set_code.overlays.len = 0
			if (master && master.locked)
				lock.icon_state = "lock-locked"
			else
				lock.icon_state = "lock-unlocked"
		else
			lock.name = "Lock"
			lock.icon_state = "lock-locked"
			if (!lock.overlays.len)
				lock.overlays += missing
			if (!set_code.overlays.len)
				set_code.overlays += missing
		if (master.lights)
			lights.name = master.lights.name
			lights.overlays.len = 0
		else
			lights.name = "Lights"
			if (!lights.overlays.len)
				lights.overlays += missing

	relay_click(id, mob/user, list/params)
		if (user.loc != master)
			boutput(user, "<span class='alert'>You're not in the pod doofus. (Call 1-800-CODER.)</span>")
			remove_client(user.client)

			if (user.client.tooltipHolder)
				user.client.tooltipHolder.inPod = 0

			return
		if (is_incapacitated(user))
			boutput(user, "<span class='alert'>Not when you are incapacitated.</span>")
			return
		// WHAT THE FUCK PAST MARQUESAS
		// GET IT TOGETHER
		// - Future Marquesas
		// switch ("id")
		switch (id)
			if ("engine")
				if (master.engine)
					if (user != master.pilot)
						boutput(user, "<span class='alert'>Only the pilot may do that!</span>")
						return
					master.engine.toggle()
			if ("life_support")
				if (master.life_support)
					master.life_support.toggle()
			if ("comms")
				if (master.com_system)
					master.com_system.toggle()
					update_systems()
			if ("comms_system")
				if(master.com_system)
					if(master.com_system.active)
						master.com_system.External()
					else
						boutput(user, "[master.ship_message("SYSTEM OFFLINE")]")
				else
					boutput(user, "[master.ship_message("System not installed in ship!")]")
			if ("weapon")
				if (master.m_w_system)
					master.m_w_system.toggle()
			if ("secondary")
				if (master.sec_system)
					master.sec_system.toggle()
			if ("sensors")
				if (master.sensors)
					master.sensors.toggle()
			if ("sensors_use")
				if (master.sensors && master.sensors.active)
					master.sensors.opencomputer(user)
			if ("lock")
				if (master.lock)
					if (!master.lock.code || master.lock.code == "")
						master.lock.configure_mode = 1
						if (master)
							master.locked = 0
						master.lock.code = ""

						boutput(user, "<span class='notice'>Code reset.  Please type new code and press enter.</span>")
						master.lock.show_lock_panel(user)
					else if (!master.locked)
						master.locked = 1
						boutput(user, "<span class='alert'>The lock mechanism clunks locked.</span>")
					else if (master.locked)
						master.locked = 0
						boutput(user, "<span class='alert'>The ship mechanism clicks unlocked.</span>")
			if ("set_code")
				if (master.lock)
					master.lock.configure_mode = 1
					if (master)
						master.locked = 0
					master.lock.code = ""
					boutput(user, "<span class='notice'>Code reset.  Please type new code and press enter.</span>")
					master.lock.show_lock_panel(user)
			if ("return_to_station")
				if(master.com_system)
					if(master.com_system.active)
						master.going_home = 1
					else
						boutput(user, "[master.ship_message("SYSTEM OFFLINE")]")
				else
					boutput(user, "[master.ship_message("System not installed in ship!")]")
			if ("leave")
				master.leave_pod(user)
			if ("wormhole") //HEY THIS DOES SAMETHING AS CLIENT WORMHOLE PROC IN VEHICLE.DM
				if(master.engine && !istype(master,/obj/machinery/vehicle/tank/car))
					if(master.engine.active)
						if(master.engine.ready)
							var/turf/T = master.loc
							if (istype(T) && T.allows_vehicles)
								master.engine.Wormhole()
							else
								boutput(user, "[master.ship_message("Cannot create wormhole on this flooring!")]")
						else
							boutput(user, "[master.ship_message("Engine recharging wormhole capabilities!")]")
					else
						boutput(user, "[master.ship_message("SYSTEM OFFLINE")]")
				else
					boutput(user, "[master.ship_message("System not installed in ship!")]")
			if ("lights")
				if (master.lights)
					master.lights.toggle()
			if ("rcs")
				master.rcs = !master.rcs


		update_states()

//for some reason this was in the removed pod colloseum code, moved it here since it's still in use
/datum/healthBar
	var/list/barBits = list()
	var/image/health_overlay

	New(var/barLength = 4, var/is_left = 0)
		..()
		for (var/i = 1, i <= barLength, i++)
			var/atom/movable/screen/S = new /atom/movable/screen()
			var/edge = is_left ? "WEST" : "EAST"
			S.layer = HUD_LAYER
			S.name = "health"
			S.icon = 'icons/obj/colosseum.dmi'
			if (i == 1)
				S.icon_state = "health_bar_left"
				var/sl = barLength - i
				S.screen_loc = "NORTH+1,[edge]-[sl]"
			else if (i == barLength)
				S.icon_state = "health_bar_right"
				S.screen_loc = "NORTH+1,[edge]"
			else
				S.icon_state = "health_bar_center"
				var/sl = barLength - i
				S.screen_loc = "NORTH+1,[edge]-[sl]"
			barBits += S
		health_overlay = image('icons/obj/colosseum.dmi', "health")

	proc/add_to_hud(var/datum/hud/H)
		for (var/atom/movable/screen/S in barBits)
			H.add_object(S)

	proc/add_to(var/mob/M)
		if (M.client)
			for (var/atom/movable/screen/S in barBits)
				M.client.screen += S

	proc/remove_from(var/mob/M)
		if (M.client)
			for (var/atom/movable/screen/S in barBits)
				M.client.screen -= S

	proc/update_health_overlay(var/health_value, var/health_max, var/shield_value, var/shield_max)
		for (var/atom/movable/screen/S in barBits)
			S.overlays.len = 0
		add_overlay(health_value, health_max, 204, 0, 0, 0, 204, 0)
		if (shield_value > 0)
			add_overlay(shield_value, shield_max, 0, 255, 255, 0, 102, 102)
			add_counter(barBits.len, shield_value, "#000000")
		else
			add_counter(barBits.len, health_value, "#000000")

	proc/add_overlay(value, max_value, r0, g0, b0, r1, g1, b1)
		var/percentage = value / max_value
		var/remaining = round(percentage * 100)
		var/bars = length(barBits)
		var/eachBar = 100 / bars
		var/missingBars = 0
		health_overlay.color = rgb(lerp(r0, r1, percentage), lerp(g0, g1, percentage), lerp(b0, b1, percentage))
		while (100 - (missingBars * eachBar) >= remaining && missingBars <= bars)
			missingBars++
		missingBars--

		for (var/i = 1, i <= bars, i++)
			var/atom/movable/screen/S = barBits[i]
			if (i <= missingBars)
				continue
			else if (i == missingBars + 1)
				var/matrix/Mat = matrix()
				var/present = (bars - missingBars - 1) * eachBar
				var/mine = remaining - present
				var/scale = mine / eachBar
				var/move = 16 - (16 * scale)
				Mat.Scale(scale, 1)
				health_overlay.transform = Mat
				health_overlay.pixel_x = move + 1
				S.overlays += health_overlay
				health_overlay.transform = null
				health_overlay.pixel_x = 0
			else
				S.overlays += health_overlay

	proc/add_counter(var/bit, var/value, var/textcolor)
		var/atom/movable/screen/counter = barBits[bit]
		if (value < 0)
			counter.overlays += image('icons/obj/colosseum.dmi', "INF")
		else
			if (value > 999)
				value = 999
			if (value >= 100)
				var/R2 = round(value / 100)
				var/image/left = image('icons/obj/colosseum.dmi', "[R2]")
				left.color = textcolor
				left.pixel_x = -8
				counter.overlays += left
			if (value >= 10)
				var/R1 = round(value / 10) % 10
				var/image/center = image('icons/obj/colosseum.dmi', "[R1]")
				center.color = textcolor
				counter.overlays += center
			var/R0 = round(value % 10)
			var/image/right = image('icons/obj/colosseum.dmi', "[R0]")
			right.color = textcolor
			right.pixel_x = 8
			counter.overlays += right
