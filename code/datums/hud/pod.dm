#define POD_BAR_HEALTH "health"
#define POD_BAR_FUEL "fuel"

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
		comms_system
		leave
		rcs
		lights
		tracking
		sensor_lock

	click_check = 0
	var/image/missing
	var/datum/healthBar/health_bar
	var/datum/healthBar/fuel_bar
	var/obj/machinery/vehicle/master

	New(P)
		..()
		master = P
		missing = image('icons/mob/hud_pod.dmi', "marker")

		var/list/zone_coords = list(x_low = 1, y_low = TILE_HEIGHT-1, x_high = 14, y_high = TILE_HEIGHT) // Top left, two rows
		var/datum/hud_zone/mainpanel = src.create_hud_zone(zone_coords, "primary_ui", vertical_edge = NORTH)

		//oh lordy
		mainpanel.register_element(new /datum/hud_element(src.create_screen("engine", "Engine", 'icons/mob/hud_pod.dmi', "engine-off",\
			tooltipTheme = "pod-alt", desc = "Turn the pod's engine on or off.")),"engine")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("wormhole", "Create Wormhole", 'icons/mob/hud_pod.dmi', "wormhole",\
			tooltipTheme = "pod", desc = "Open a wormhole to a beacon that you can fly through")),"wormhole")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("life_support", "Life Support", 'icons/mob/hud_pod.dmi', "life_support-off",\
			tooltipTheme = "pod-alt", desc = "Turn life support on or off")),"life_support")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("comms", "Comms", 'icons/mob/hud_pod.dmi', "comms-off",\
			tooltipTheme = "pod-alt", desc = "Turn the pod's communications system on or off")),"comms")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("comms_system", "Use Comms System", 'icons/mob/hud_pod.dmi', "comms_system",\
			tooltipTheme = "pod", desc = "Use the communications system to talk or whatever")),"comms_system")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("sensors", "Sensors", 'icons/mob/hud_pod.dmi', "sensors-off",\
			tooltipTheme = "pod-alt", desc = "Turn the pod's sensors on or off")),"sensors")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("sensors_use", "Activate Sensors", 'icons/mob/hud_pod.dmi', "sensors-use",\
			tooltipTheme = "pod", desc = "Use the pod's sensors to search for vehicles and lifeforms nearby")),"sensors_use")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("weapon", "Main Weapon", 'icons/mob/hud_pod.dmi', "weapon-off",\
			tooltipTheme = "pod-alt", desc = "Turn the main weapon on or off, if the pod is equipped with one")),"weapon")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("lights", "Toggle Lights", 'icons/mob/hud_pod.dmi', "lights-off",\
			tooltipTheme = "pod", desc = "Turn the pod's external lights on or off")),"lights")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("secondary", "Secondary System", 'icons/mob/hud_pod.dmi', "blank",\
			tooltipTheme = "pod", desc = "Enable or disable the secondary system installed in the pod, if there is one")),"secondary")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("lock", "Lock", 'icons/mob/hud_pod.dmi', "lock-locked",\
			tooltipTheme = "pod-alt", desc = "LOCK YOUR PODS YOU DOOFUSES")),"lock")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("set_code", "Set Lock code", 'icons/mob/hud_pod.dmi', "set-code",\
			tooltipTheme = "pod", desc = "Set the code used to unlock the pod")),"set_code")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("rts", "Return To [capitalize(station_or_ship())]", 'icons/mob/hud_pod.dmi', "return-to-station",\
			tooltipTheme = "pod", desc = "Using this will place you on the station Z-level the next time you fly off the edge of the current level")),"rts")

		mainpanel.register_element(new /datum/hud_element(src.create_screen("rcs", "Toggle RCS", 'icons/mob/hud_pod.dmi', "rcs-off",\
			tooltipTheme = "pod-alt", desc = "Reduce the pod's relative velocity")),"rcs")

		leave = create_screen("leave", "Leave Pod", 'icons/mob/hud_pod.dmi', "leave", "SOUTH,EAST", tooltipTheme = "pod-alt", desc = "Get out of the pod")
		tracking = create_screen("tracking", "Tracking Indicator", 'icons/mob/hud_pod.dmi', "off", "CENTER, CENTER")
		tracking.mouse_opacity = 0
		sensor_lock = create_screen("sensor_lock", "Sensor Lock", 'icons/mob/hud_pod.dmi', "off", "SOUTH+1,EAST")
		sensor_lock.mouse_opacity = 0	//maybe set to one, so that clicking on it will explain what it is
		health_bar = new /datum/healthBar(barLength=3, index_from_top=1, bar_name=POD_BAR_HEALTH)
		health_bar.add_to_hud(src)
		fuel_bar = new /datum/healthBar(barLength=3, index_from_top=2, bar_name=POD_BAR_FUEL)
		fuel_bar.add_to_hud(src)
		if (master)
			update_health()
			update_systems()
			update_states()
			update_fuel()

	disposing()
		src.delete_hud_zone("primary_ui")
		..()

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

	proc/update_fuel()
		check_clients()
		if(istype(master.fueltank))
			fuel_bar.update_health_overlay(MIXTURE_PRESSURE(master.fueltank.air_contents), PORTABLE_ATMOS_MAX_RELEASE_PRESSURE, 0, 0)
		else
			fuel_bar.update_health_overlay(0, 100, 0, 0)

	proc/update_states()
		check_clients()

		var/comms_on = FALSE
		if(master.com_system?.active) comms_on = TRUE

		var/element_list = src.get_hudzone("primary_ui").elements
		for(var/listkey in element_list)
			var/datum/hud_element/our_element = element_list[listkey]
			switch(listkey)
				if("engine")
					our_element.screen_obj.icon_state = master.engine?.active ? "engine-on" : "engine-off"
				if("wormhole")
					if (master.engine?.active && master.sensors?.active)
						our_element.screen_obj.overlays.len = 0
					else if(!our_element.screen_obj.overlays.len)
						our_element.screen_obj.overlays += missing
				if("life_support")
					our_element.screen_obj.icon_state = master.life_support?.active ? "life_support-on" : "life_support-off"
				if("comms")
					our_element.screen_obj.icon_state = master.com_system?.active ? "comms-on" : "comms-off"
				if("comms_system")
					if (comms_on)
						our_element.screen_obj.overlays.len = 0
					else if(!our_element.screen_obj.overlays.len)
						our_element.screen_obj.overlays += missing
				if("sensors")
					our_element.screen_obj.icon_state = master.sensors?.active ? "sensors-on" : "sensors-off"
				if("sensors_use")
					if (master.sensors?.active)
						our_element.screen_obj.overlays.len = 0
					else if(!our_element.screen_obj.overlays.len)
						our_element.screen_obj.overlays += missing
				if("weapon")
					our_element.screen_obj.icon_state = master.m_w_system?.active ? "weapon-on" : "weapon-off"
				if("lights")
					if(master.lights)
						our_element.screen_obj.icon_state = master.lights?.active ? "[master.lights.hud_state]-on" : "[master.lights.hud_state]-off"
					else
						our_element.screen_obj.icon_state = "blank"
				if("secondary")
					if(master.sec_system?.f_active)
						our_element.screen_obj.icon_state = master.sec_system.hud_state
					else if(master.sec_system)
						our_element.screen_obj.icon_state = master.sec_system?.active ? "[master.sec_system.hud_state]-on" : "[master.sec_system.hud_state]-off"
					else
						our_element.screen_obj.icon_state = "blank"
				if("lock")
					if(master.lock?.code)
						our_element.screen_obj.icon_state = master.locked ? "lock-locked" : "lock-unlocked"
				if("rts")
					if (comms_on)
						our_element.screen_obj.overlays.len = 0
					else if(!our_element.screen_obj.overlays.len)
						our_element.screen_obj.overlays += missing
				if("rcs")
					our_element.screen_obj.icon_state = master.rcs ? "rcs-on" : "rcs-off"

	proc/update_systems()
		check_clients()

		var/datum/hud_element/engine_elem = src.get_hudzone("primary_ui").get_element("engine")
		if (master.engine)
			engine_elem?.screen_obj.name = master.engine.name
			engine_elem?.screen_obj.overlays.len = 0
		else
			engine_elem?.screen_obj.name = "Engine"
			if (!engine_elem?.screen_obj.overlays.len)
				engine_elem?.screen_obj.overlays += missing

		var/datum/hud_element/life_support_elem = src.get_hudzone("primary_ui").get_element("life_support")
		if (master.life_support)
			life_support_elem?.screen_obj.name = master.life_support.name
			life_support_elem?.screen_obj.overlays.len = 0
		else
			life_support_elem?.screen_obj.name = "Life Support"
			if (!life_support_elem?.screen_obj.overlays.len)
				life_support_elem?.screen_obj.overlays += missing

		var/datum/hud_element/comms_elem = src.get_hudzone("primary_ui").get_element("comms")
		var/datum/hud_element/rts_elem = src.get_hudzone("primary_ui").get_element("rts")
		var/datum/hud_element/comms_system_elem = src.get_hudzone("primary_ui").get_element("comms_system")
		if (master.com_system)
			comms_elem?.screen_obj.name = master.com_system.name
			comms_elem?.screen_obj.overlays.len = 0
			if (!master.com_system.active)
				if (!rts_elem?.screen_obj.overlays.len)
					rts_elem?.screen_obj.overlays += missing
				if (!comms_system_elem?.screen_obj.overlays.len)
					comms_system_elem?.screen_obj.overlays += missing
			else
				rts_elem?.screen_obj.overlays.len = 0
				comms_system_elem?.screen_obj.overlays.len = 0
		else
			comms_elem?.screen_obj.name = "Comms"
			if (!comms_elem?.screen_obj.overlays.len)
				comms_elem?.screen_obj.overlays += missing
			if (!rts_elem?.screen_obj.overlays.len)
				rts_elem?.screen_obj.overlays += missing
			if (!comms_system_elem?.screen_obj.overlays.len)
				comms_system_elem?.screen_obj.overlays += missing

		var/datum/hud_element/weapon_elem = src.get_hudzone("primary_ui").get_element("weapon")
		if (master.m_w_system)
			weapon_elem?.screen_obj.name = master.m_w_system.name
			weapon_elem?.screen_obj.overlays.len = 0
		else
			weapon_elem?.screen_obj.name = "Main Weapon"
			if (!weapon_elem?.screen_obj.overlays.len)
				weapon_elem?.screen_obj.overlays += missing

		var/datum/hud_element/secondary_elem = src.get_hudzone("primary_ui").get_element("secondary")
		if (master.sec_system)
			secondary_elem?.screen_obj.name = master.sec_system.name
			secondary_elem?.screen_obj.overlays.len = 0
		else
			secondary_elem?.screen_obj.name = "Secondary System"
			if (!secondary_elem?.screen_obj.overlays.len)
				secondary_elem?.screen_obj.overlays += missing
			secondary_elem?.screen_obj.icon_state = "blank"

		var/datum/hud_element/sensors_elem = src.get_hudzone("primary_ui").get_element("sensors")
		var/datum/hud_element/sensors_use_elem = src.get_hudzone("primary_ui").get_element("sensors_use")
		if (master.sensors)
			sensors_elem?.screen_obj.name = master.sensors.name
			sensors_elem?.screen_obj.overlays.len = 0
			if (!master.sensors.active)
				sensors_use_elem?.screen_obj.overlays.len = 0
			else
				if (!sensors_use_elem?.screen_obj.overlays.len)
					sensors_use_elem?.screen_obj.overlays += missing
		else
			sensors_elem?.screen_obj.name = "Sensors"
			if (!sensors_elem?.screen_obj.overlays.len)
				sensors_elem?.screen_obj.overlays += missing
			if (!sensors_use_elem?.screen_obj.overlays.len)
				sensors_use_elem?.screen_obj.overlays += missing

		var/datum/hud_element/lock_elem = src.get_hudzone("primary_ui").get_element("lock")
		var/datum/hud_element/set_code_elem = src.get_hudzone("primary_ui").get_element("set_code")
		if (master.lock)
			lock_elem?.screen_obj.name = master.lock.name
			lock_elem?.screen_obj.overlays.len = 0
			set_code_elem?.screen_obj.overlays.len = 0
			if (master && master.locked)
				lock_elem?.screen_obj.icon_state = "lock-locked"
			else
				lock_elem?.screen_obj.icon_state = "lock-unlocked"
		else
			lock_elem?.screen_obj.name = "Lock"
			lock_elem?.screen_obj.icon_state = "lock-locked"
			if (!lock_elem?.screen_obj.overlays.len)
				lock_elem?.screen_obj.overlays += missing
			if (!set_code_elem?.screen_obj.overlays.len)
				set_code_elem?.screen_obj.overlays += missing

		var/datum/hud_element/lights_elem = src.get_hudzone("primary_ui").get_element("lights")
		if (master.lights)
			lights_elem?.screen_obj.name = master.lights.name
			lights_elem?.screen_obj.overlays.len = 0
		else
			lights_elem?.screen_obj.name = "Lights"
			if (!lights_elem?.screen_obj.overlays.len)
				lights_elem?.screen_obj.overlays += missing

	proc/switch_sound()
		for (var/mob/M in src.master)
			M.playsound_local(src.master, 'sound/machines/pod_switch.ogg', 60, TRUE, ignore_flag = SOUND_IGNORE_SPACE)

	relay_click(id, mob/user, list/params)
		if (user.loc != master)
			boutput(user, SPAN_ALERT("You're not in the pod doofus. (Call 1-800-CODER.)"))
			remove_client(user.client)

			if (user.client.tooltipHolder)
				user.client.tooltipHolder.inPod = 0

			return
		if (is_incapacitated(user))
			boutput(user, SPAN_ALERT("Not when you are incapacitated."))
			return
		// WHAT THE FUCK PAST MARQUESAS
		// GET IT TOGETHER
		// - Future Marquesas
		// switch ("id")
		switch (id)
			if ("engine")
				if (master.engine)
					if (user != master.pilot)
						boutput(user, SPAN_ALERT("Only the pilot may do that!"))
						return
					master.engine.toggle()
					src.switch_sound()
			if ("life_support")
				if (master.life_support)
					master.life_support.toggle()
					src.switch_sound()
			if ("comms")
				if (master.com_system)
					master.com_system.toggle()
					src.switch_sound()
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
					src.switch_sound()
			if ("secondary")
				if (master.sec_system)
					master.sec_system.toggle()
					src.switch_sound()
			if ("sensors")
				if (master.sensors)
					master.sensors.toggle()
					src.switch_sound()
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

						boutput(user, SPAN_NOTICE("Code reset.  Please type new code and press enter."))
						master.lock.show_lock_panel(user)
					else if (!master.locked)
						master.locked = 1
						boutput(user, SPAN_ALERT("The lock mechanism clunks locked."))
					else if (master.locked)
						master.locked = 0
						boutput(user, SPAN_ALERT("The ship mechanism clicks unlocked."))
			if ("set_code")
				if (master.lock)
					master.lock.configure_mode = 1
					if (master)
						master.locked = 0
					master.lock.code = ""
					boutput(user, SPAN_NOTICE("Code reset.  Please type new code and press enter."))
					master.lock.show_lock_panel(user)
			if ("rts")
				master.return_to_station()
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
					src.switch_sound()
			if ("rcs")
				master.rcs = !master.rcs
				src.switch_sound()


		update_states()

//for some reason this was in the removed pod colloseum code, moved it here since it's still in use
/datum/healthBar
	var/list/barBits = list()
	var/atom/movable/screen/bar_icon
	var/image/health_overlay

	New(barLength = 4, is_left = 0, index_from_top = 1, bar_name=POD_BAR_HEALTH)
		..()
		var/edge = is_left ? "WEST" : "EAST"
		var/top_offset = 1.75 - (index_from_top * 0.5)

		src.bar_icon = new /atom/movable/screen()
		src.bar_icon.layer = HUD_LAYER
		src.bar_icon.screen_loc = "NORTH+[top_offset+0.25],[edge]-[barLength-0.4]"
		src.bar_icon.icon = 'icons/ui/vehicle16x16.dmi'
		src.bar_icon.icon_state = bar_name

		for (var/i = 1, i <= barLength, i++)
			var/atom/movable/screen/S = new /atom/movable/screen()
			S.layer = HUD_LAYER
			S.name = bar_name
			S.icon = 'icons/obj/colosseum.dmi'
			if (i == 1)
				S.icon_state = "health_bar_left"
				var/sl = barLength - i
				S.screen_loc = "NORTH+[top_offset],[edge]-[sl]"
			else if (i == barLength)
				S.icon_state = "health_bar_right"
				S.screen_loc = "NORTH+[top_offset],[edge]"
			else
				S.icon_state = "health_bar_center"
				var/sl = barLength - i
				S.screen_loc = "NORTH+[top_offset],[edge]-[sl]"
			barBits += S
		health_overlay = image('icons/obj/colosseum.dmi', "health")

	proc/add_to_hud(var/datum/hud/H)
		H.add_object(src.bar_icon)
		for (var/atom/movable/screen/S in barBits)
			H.add_object(S)

	proc/add_to(var/mob/M)
		if (M.client)
			M.client.screen += src.bar_icon
			for (var/atom/movable/screen/S in barBits)
				M.client.screen += S

	proc/remove_from(var/mob/M)
		if (M.client)
			M.client.screen -= src.bar_icon
			for (var/atom/movable/screen/S in barBits)
				M.client.screen -= S

	proc/update_health_overlay(var/health_value, var/health_max, var/shield_value, var/shield_max)
		for (var/atom/movable/screen/S in barBits)
			S.overlays.len = 0
		add_overlay(health_value, health_max, 204, 0, 0, 0, 204, 0)
		if (shield_value > 0)
			add_overlay(shield_value, shield_max, 0, 255, 255, 0, 102, 102)
			add_counter(barBits.len, shield_value, "#000000")
			return
		if ((health_value/health_max) > 0.5)
			add_counter(barBits.len, health_value, "#000000")
		else
			add_counter(barBits.len, health_value, "#d9e8f2")

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

#undef POD_BAR_HEALTH
#undef POD_BAR_FUEL
