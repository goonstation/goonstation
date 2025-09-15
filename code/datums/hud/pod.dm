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
		use_comms
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
		engine = create_screen("engine", "Engine", 'icons/mob/hud_pod.dmi', "engine-off", "NORTH+1,WEST", tooltip_options = list("theme" = "pod-alt"), desc = "Turn the pod's engine on or off.")
		wormhole = create_screen("wormhole", "Create Wormhole", 'icons/mob/hud_pod.dmi', "wormhole", "NORTH+1,WEST+1", tooltip_options = list("theme" = "pod"), desc = "Open a wormhole to a beacon that you can fly through")
		life_support = create_screen("life_support", "Life Support", 'icons/mob/hud_pod.dmi', "life_support-off", "NORTH+1,WEST+2", tooltip_options = list("theme" = "pod-alt"), desc = "Turn life support on or off")
		comms = create_screen("comms", "Comms", 'icons/mob/hud_pod.dmi', "comms-off", "NORTH+1,WEST+3", tooltip_options = list("theme" = "pod-alt"), desc = "Turn the pod's communications system on or off")
		use_comms = create_screen("comms_system", "Use Comms System", 'icons/mob/hud_pod.dmi', "comms_system", "NORTH+1,WEST+4", tooltip_options = list("theme" = "pod"), desc = "Use the communications system to talk or whatever")
		sensors = create_screen("sensors", "Sensors", 'icons/mob/hud_pod.dmi', "sensors-off", "NORTH+1,WEST+5", tooltip_options = list("theme" = "pod-alt"), desc = "Turn the pod's sensors on or off")
		sensors_use = create_screen("sensors_use", "Activate Sensors", 'icons/mob/hud_pod.dmi', "sensors-use", "NORTH+1,WEST+6", tooltip_options = list("theme" = "pod"), desc = "Use the pod's sensors to search for vehicles and lifeforms nearby")
		weapon = create_screen("weapon", "Main Weapon", 'icons/mob/hud_pod.dmi', "weapon-off", "NORTH+1,WEST+7", tooltip_options = list("theme" = "pod-alt"), desc = "Turn the main weapon on or off, if the pod is equipped with one")
		lights = create_screen("lights", "Toggle Lights", 'icons/mob/hud_pod.dmi', "lights-off", "NORTH+1, WEST+8", tooltip_options = list("theme" = "pod"), desc = "Turn the pod's external lights on or off")
		secondary = create_screen("secondary", "Secondary System", 'icons/mob/hud_pod.dmi', "blank", "NORTH+1,WEST+9", tooltip_options = list("theme" = "pod"), desc = "Activate the secondary system installed in the pod, if there is one")
		lock = create_screen("lock", "Lock", 'icons/mob/hud_pod.dmi', "lock-locked", "NORTH+1,WEST+10", tooltip_options = list("theme" = "pod-alt"), desc = "Lock or unlock the pod.")
		set_code = create_screen("set_code", "Set Lock code", 'icons/mob/hud_pod.dmi', "set-code", "NORTH+1,WEST+11", tooltip_options = list("theme" = "pod"), desc = "Set the code used to unlock the pod")
		rts = create_screen("return_to_station", "Return To [capitalize(station_or_ship())]", 'icons/mob/hud_pod.dmi', "return-to-station", "NORTH+1,WEST+12", tooltip_options = list("theme" = "pod"), desc = "Using this will place you on the station Z-level the next time you fly off the edge of the current level")
		leave = create_screen("leave", "Leave Pod", 'icons/mob/hud_pod.dmi', "leave", "SOUTH,EAST", tooltip_options = list("theme" = "pod-alt", "align" = TOOLTIP_TOP | TOOLTIP_RIGHT), desc = "Get out of the pod")
		rcs = create_screen("rcs", "Toggle RCS", 'icons/mob/hud_pod.dmi', "rcs-off", "NORTH+1,WEST+13", tooltip_options = list("theme" = "pod-alt"), desc = "Reduce the pod's relative velocity")
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

	clear_master()
		master = null
		..()

	proc/detach_all_clients()
		for (var/client/C in clients)
			remove_client(C)

	proc/check_clients()
		for (var/client/C in clients)
			var/mob/M = C.mob
			if (M.loc != master)
				remove_client(C)

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
		var/obj/item/shipcomponent/engine_part = master.get_part(POD_PART_ENGINE)
		var/obj/item/shipcomponent/life_support_part = master.get_part(POD_PART_LIFE_SUPPORT)
		var/obj/item/shipcomponent/comms_part = master.get_part(POD_PART_COMMS)
		var/obj/item/shipcomponent/sensors_part = master.get_part(POD_PART_SENSORS)
		var/obj/item/shipcomponent/pod_lights/lights_part = master.get_part(POD_PART_LIGHTS)
		var/obj/item/shipcomponent/main_weapon_part = master.get_part(POD_PART_MAIN_WEAPON)
		var/obj/item/shipcomponent/secondary_system/sec_part = master.get_part(POD_PART_SECONDARY)
		var/obj/item/shipcomponent/secondary_system/lock/lock_part = master.get_part(POD_PART_LOCK)

		if (engine_part)
			if (engine_part.active)
				engine.icon_state = "engine-on"
			else
				engine.icon_state = "engine-off"

		if (engine_part?.active && sensors_part?.active)
			wormhole.overlays.len = 0
		else
			if (!wormhole.overlays.len)
				wormhole.overlays += missing

		if (life_support_part)
			if (life_support_part.active)
				life_support.icon_state = "life_support-on"
			else
				life_support.icon_state = "life_support-off"

		if (comms_part)
			if (comms_part.active)
				comms.icon_state = "comms-on"
				rts.overlays.len = 0
				use_comms.overlays.len = 0
			else
				comms.icon_state = "comms-off"
				if (!rts.overlays.len)
					rts.overlays += missing
				if (!use_comms.overlays.len)
					use_comms.overlays += missing

		if (main_weapon_part)
			if (main_weapon_part.active)
				weapon.icon_state = "weapon-on"
			else
				weapon.icon_state = "weapon-off"

		if (sec_part)
			if (sec_part.f_active)
				secondary.icon_state = sec_part.hud_state
			else if (sec_part.active)
				secondary.icon_state = "[sec_part.hud_state]-on"
			else
				secondary.icon_state = "[sec_part.hud_state]-off"

		if (sensors_part)
			if (sensors_part.active)
				sensors.icon_state = "sensors-on"
				sensors_use.overlays.len = 0
			else
				sensors.icon_state = "sensors-off"
				if (!sensors_use.overlays.len)
					sensors_use.overlays += missing

		if (lock_part)
			if (lock_part.is_set() && master.locked)
				lock.icon_state = "lock-locked"
			else
				lock.icon_state = "lock-unlocked"

		if (lights_part)
			if (lights_part.active)
				lights.icon_state = "[lights_part.hud_state]-on"
			else
				lights.icon_state = "[lights_part.hud_state]-off"

		if (master.rcs)
			rcs.icon_state = "rcs-on"
		else
			rcs.icon_state = "rcs-off"


	proc/update_systems()
		var/obj/item/shipcomponent/engine_part = master.get_part(POD_PART_ENGINE)
		var/obj/item/shipcomponent/life_support_part = master.get_part(POD_PART_LIFE_SUPPORT)
		var/obj/item/shipcomponent/comms_part = master.get_part(POD_PART_COMMS)
		var/obj/item/shipcomponent/sensors_part = master.get_part(POD_PART_SENSORS)
		var/obj/item/shipcomponent/lights_part = master.get_part(POD_PART_LIGHTS)
		var/obj/item/shipcomponent/main_weapon_part = master.get_part(POD_PART_MAIN_WEAPON)
		var/obj/item/shipcomponent/sec_part = master.get_part(POD_PART_SECONDARY)
		var/obj/item/shipcomponent/lock_part = master.get_part(POD_PART_LOCK)

		check_clients()
		if (engine_part)
			engine.name = engine_part.name
			engine.overlays.len = 0
		else
			engine.name = "Engine"
			if (!engine.overlays.len)
				engine.overlays += missing

		if (life_support_part)
			life_support.name = life_support_part.name
			life_support.overlays.len = 0
		else
			life_support.name = "Life Support"
			if (!life_support.overlays.len)
				life_support.overlays += missing

		if (comms_part)
			comms.name = comms_part.name
			comms.overlays.len = 0
			if (!comms_part.active)
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

		if (main_weapon_part)
			weapon.name = main_weapon_part.name
			weapon.overlays.len = 0
		else
			weapon.name = "Main Weapon"
			if (!weapon.overlays.len)
				weapon.overlays += missing

		if (sec_part)
			secondary.name = sec_part.name
			secondary.overlays.len = 0
		else
			secondary.name = "Secondary System"
			if (!secondary.overlays.len)
				secondary.overlays += missing
			secondary.icon_state = "blank"

		if (sensors_part)
			sensors.name = sensors_part.name
			sensors.overlays.len = 0
			if (!sensors_part.active)
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

		if (lock_part)
			lock.name = lock_part.name
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
		if (lights_part)
			lights.name = lights_part.name
			lights.overlays.len = 0
		else
			lights.name = "Lights"
			if (!lights.overlays.len)
				lights.overlays += missing

	proc/switch_sound()
		for (var/mob/M in src.master)
			M.playsound_local(src.master, 'sound/machines/pod_switch.ogg', 60, TRUE, ignore_flag = SOUND_IGNORE_SPACE)

	relay_click(id, mob/user, list/params)
		if (user.loc != master)
			boutput(user, SPAN_ALERT("You're not in the pod doofus. (Call 1-800-CODER.)"))
			remove_client(user.client)

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
				var/obj/item/shipcomponent/engine_part = master.get_part(POD_PART_ENGINE)
				if (engine_part)
					if (user != master.pilot)
						boutput(user, SPAN_ALERT("Only the pilot may do that!"))
						return
					engine_part.toggle()
					src.switch_sound()
			if ("life_support")
				var/obj/item/shipcomponent/life_support_part = master.get_part(POD_PART_LIFE_SUPPORT)
				if (life_support_part)
					life_support_part.toggle()
					src.switch_sound()
			if ("comms")
				var/obj/item/shipcomponent/comms_part = master.get_part(POD_PART_COMMS)
				if (comms_part)
					comms_part.toggle()
					src.switch_sound()
					update_systems()
			if ("comms_system")
				var/obj/item/shipcomponent/communications/comms_part = master.get_part(POD_PART_COMMS)
				if(comms_part)
					if(comms_part.active)
						comms_part.External()
					else
						boutput(user, "[master.ship_message("SYSTEM OFFLINE")]")
				else
					boutput(user, "[master.ship_message("System not installed in ship!")]")
			if ("weapon")
				var/obj/item/shipcomponent/main_weapon_part = master.get_part(POD_PART_MAIN_WEAPON)
				if (main_weapon_part)
					main_weapon_part.toggle()
					src.switch_sound()
			if ("secondary")
				var/obj/item/shipcomponent/secondary_system/sec_part = master.get_part(POD_PART_SECONDARY)
				if (sec_part)
					sec_part.toggle()
					src.switch_sound()
			if ("sensors")
				var/obj/item/shipcomponent/sensors_part = master.get_part(POD_PART_SENSORS)
				if (sensors_part)
					sensors_part.toggle()
					src.switch_sound()
			if ("sensors_use")
				var/obj/item/shipcomponent/sensors_part = master.get_part(POD_PART_SENSORS)
				if (sensors_part && sensors_part.active)
					sensors_part.opencomputer(user)
			if ("lock")
				var/obj/item/shipcomponent/secondary_system/lock/lock_part = master.get_part(POD_PART_LOCK)
				if (lock_part)
					if (!lock_part.is_set())
						lock_part.configure_mode = 1
						if (master)
							master.locked = 0
						lock_part.code = ""
						lock_part.show_lock_panel(user)
					else if (!master.locked)
						master.locked = 1
						boutput(user, SPAN_ALERT("The lock mechanism clunks locked."))
					else if (master.locked)
						master.locked = 0
						boutput(user, SPAN_ALERT("The ship mechanism clicks unlocked."))
			if ("set_code")
				var/obj/item/shipcomponent/secondary_system/lock/lock_part = master.get_part(POD_PART_LOCK)
				if (lock_part)
					if (lock_part.is_set())
						if (!lock_part.can_reset)
							boutput(user, SPAN_NOTICE("This lock cannot have its code reset."))
							return
						boutput(user, SPAN_NOTICE("Code reset. Please type new code and press enter."))
					lock_part.configure_mode = 1
					if (master)
						master.locked = 0
					lock_part.code = ""
					lock_part.show_lock_panel(user)
			if ("return_to_station")
				master.return_to_station()
			if ("leave")
				master.leave_pod(user)
			if ("wormhole")
				master.create_wormhole()
			if ("lights")
				var/obj/item/shipcomponent/pod_lights/lights_part = master.get_part(POD_PART_LIGHTS)
				if (lights_part)
					lights_part.toggle()
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
