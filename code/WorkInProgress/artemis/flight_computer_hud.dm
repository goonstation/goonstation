#ifdef ENABLE_ARTEMIS

/datum/hud/flight_computer
	var/atom/movable/screen/hud
		leave
		scan
		toggle_tracking
		toggle_nav
		launch_nav_sat
		big_hud

		throttle_slide
		throttle_stick
		killswitch
		killswitch_close
		radar
		radar_ping
		tracking_light
		buoy_counter
		coffee
		tele_ok
		control_lock
		control_light
		maint_panel

		engine_health_one
		engine_health_two
		engine_health_three
		engine_health_four
		engine_health_five
		engine_health_six
		engine_health_seven
		engine_health_eight


	click_check = 0
	var/obj/machinery/sim/vr_bed/flight_chair/master
	var/coffee_level = 3

	New(P)
		..()
		var/throttle_slide_xy = "[round(17/32)+1]:[17%32],[round(2/32)+1]:[2%32]"
		var/throttle_stick_xy = "[round(2/32)+1]:[2%32],[round(6/32)+1]:[6%32]"
		var/engine_health_xy = "[round(97/32)+1]:[97%32],[round(4/32)+1]:[4%32]"
		var/nav_term_xy = "[round(170/32)+1]:[170%32],[round(2/32)+1]:[2%32]"
		var/killswitch_xy = "[round(55/32)+1]:[55%32],[round(5/32)+1]:[5%32]"
		var/radar_xy = "[round(231/32)+1]:[231%32],[round(6/32)+1]:[6%32]"
		var/scanner_xy = "[round(266/32)+1]:[266%32],[round(6/32)+1]:[6%32]"
		var/tracking_switch_xy = "[round(268/32)+1]:[268%32],[round(26/32)+1]:[26%32]"
		var/tracking_light_xy = "[round(330/32)+1]:[330%32],[round(21/32)+1]:[21%32]"
		var/buoy_counter_xy = "[round(355/32)+1]:[355%32],[round(28/32)+1]:[28%32]"
		var/buoy_button_xy = "13:3,1:23" //"[round(390/32)+1]:[390%32],[round(21/32)+1]:[21%32]"
		var/coffee_xy = "[round(406/32)+1]:[406%32],[round(10/32)+1]:[10%32]"
		var/tele_ok_xy = "[round(469/32)+1]:[469%32],[round(22/32)+1]:[22%32]"
		var/control_lock_key_xy = "[round(545/32)+1]:[545%32],[round(11/32)+1]:[11%32]"
		var/control_lock_light_xy = "[round(576/32)+1]:[576%32],[round(3/32)+1]:[3%32]"
		var/maint_panel_xy = "[round(469/32)+1]:[469%32],[round(2/32)+1]:[2%32]"
		var/exit_button_xy = "[round(626/32)+1]:[626%32],[round(2/32)+1]:[2%32]"

		master = P

		leave = create_screen("leave", "Leave Pod", 'icons/misc/artemis/manta_hud-elements.dmi', "exit", exit_button_xy, tooltip_options = list("theme" = "pod-alt"))
		scan = create_screen("scan","Scan Object", 'icons/misc/artemis/manta_hud-elements.dmi', "sonarbutton", scanner_xy, tooltip_options = list("theme" = "pod-alt"))
		toggle_tracking = create_screen("toggle_tracking","Toggle Tracking Arrows", 'icons/misc/artemis/manta_hud-elements.dmi', "tracking-on", tracking_switch_xy, tooltip_options = list("theme" = "pod-alt"))
		toggle_nav = create_screen("toggle_nav","Toggle Long Distance Navigation", 'icons/misc/artemis/manta_hud-elements.dmi', "nav-off", nav_term_xy, tooltip_options = list("theme" = "pod-alt"))
		launch_nav_sat = create_screen("launch_nav_sat","Launch Navigation Satellite", 'icons/misc/artemis/manta_hud-elements.dmi', "buoybutton", buoy_button_xy, tooltip_options = list("theme" = "pod-alt"))

		throttle_slide = create_screen("slide", "Throttle", 'icons/misc/artemis/manta_hud-elements.dmi', "throttle_slide", throttle_slide_xy, tooltip_options = list("theme" = "pod-alt"))
		throttle_stick = create_screen("throttle", "Throttle", 'icons/misc/artemis/manta_hud-elements.dmi', "throttle_stick", throttle_stick_xy, tooltip_options = list("theme" = "pod-alt"))
		killswitch = create_screen("killswitch", "Engine Killswitch", 'icons/misc/artemis/manta_hud-elements.dmi', "killswitch_closed", killswitch_xy, tooltip_options = list("theme" = "pod-alt"))
		killswitch_close = create_screen("killswitch_close", "Engine Killswitch", 'icons/misc/artemis/manta_hud-elements.dmi', null, killswitch_xy, tooltip_options = list("theme" = "pod-alt"))
		radar = create_screen("radar", "Radar", 'icons/misc/artemis/manta_hud-elements.dmi', "radar_on", radar_xy, tooltip_options = list("theme" = "pod-alt"))
		radar_ping = create_screen("radar_ping", "Radar", 'icons/misc/artemis/manta_hud-elements.dmi', null, radar_xy, tooltip_options = list("theme" = "pod-alt"))
		tracking_light = create_screen("tracking_light", "Tracking Indicator", 'icons/misc/artemis/manta_hud-elements.dmi', "tracking_light-on", tracking_light_xy, tooltip_options = list("theme" = "pod-alt"))
		buoy_counter = create_screen("buoy_counter", "Buoy Counter", 'icons/misc/artemis/manta_hud-elements.dmi', "buoy-3", buoy_counter_xy, tooltip_options = list("theme" = "pod-alt"))
		coffee = create_screen("coffee", "Coffee", 'icons/misc/artemis/manta_hud-elements.dmi', "coffee3", coffee_xy, tooltip_options = list("theme" = "pod-alt"))
		tele_ok = create_screen("tele_ok", "LRT Lock On Indictor", 'icons/misc/artemis/manta_hud-elements.dmi', "lrt-nok", tele_ok_xy, tooltip_options = list("theme" = "pod-alt"))
		control_lock = create_screen("control_lock", "Control Lock", 'icons/misc/artemis/manta_hud-elements.dmi', "key_unlocked", control_lock_key_xy, tooltip_options = list("theme" = "pod-alt"))
		control_light = create_screen("control_light", "Control Lock Indicator", 'icons/misc/artemis/manta_hud-elements.dmi', "control_unlocked", control_lock_light_xy, tooltip_options = list("theme" = "pod-alt"))
		maint_panel = create_screen("maint_panel", "Maintenance Panel", 'icons/misc/artemis/manta_hud-elements.dmi', "panel_closed", maint_panel_xy, tooltip_options = list("theme" = "pod-alt"))

		engine_health_one = create_screen("engine_health_one", "Engine One Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_1", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_two = create_screen("engine_health_two", "Engine Two Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_2", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_three = create_screen("engine_health_three", "Engine Three Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_3", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_four = create_screen("engine_health_four", "Engine Four Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_4", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_five = create_screen("engine_health_five", "Engine Five Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_5", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_six = create_screen("engine_health_six", "Engine Six Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_6", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_seven = create_screen("engine_health_seven", "Engine Seven Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_7", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))
		engine_health_eight = create_screen("engine_health_eight", "Engine Eight Health", 'icons/misc/artemis/manta_hud-elements.dmi', "engine_8", engine_health_xy, tooltip_options = list("theme" = "pod-alt"))


		big_hud = create_screen("big_hud","Dashboard",'icons/misc/artemis/manta_hud-background.dmi',"BG","SOUTH,WEST", tooltip_options = list("theme" = "pod-alt"))
		src.big_hud.layer = src.big_hud.layer - 0.01


	proc/detach_all_clients()
		for (var/client/C in clients)
			remove_client(C)

	proc/check_clients()
		for (var/client/C in clients)
			var/mob/M = C.mob
			if (M.loc != master)
				remove_client(C)

	proc/update()
		var/tele_locked = FALSE
		for(var/obj/background_star/galactic_object/G in src.master.ship.my_galactic_objects)
			if(G.has_ship_body && G.my_ship_body?.landing_zones)
				tele_locked = TRUE
		src.tele_ok.icon_state = "lrt-[tele_locked ? "ok" : "nok"]"
		src.buoy_counter.icon_state = "buoy-[master.ship.buoy_count]"

	relay_click(id, mob/user, list/params)
		if (user.loc != master)
			boutput(user, SPAN_ALERT("You're not in the pod doofus. (Call 1-800-CODER.)"))
			remove_client(user.client)
			return
		if (is_incapacitated(user))
			boutput(user, SPAN_ALERT("Not when you are incapacitated."))
			return
		switch (id)

			if ("leave")
				FLICK("exit_push",leave)
				SPAWN(0.7 SECONDS)
					master.go_out()

			if ("scan")
				FLICK("sonarbutton_push",scan)
				if(master.ship.control_lock)
					user.show_message(SPAN_ALERT("The controls are locked!"))
					return
				user.show_message(SPAN_NOTICE("Click what you want to scan!"))
				var/datum/targetable/artemis_active_scanning/A = new()
				user.targeting_ability = A
				user.update_cursor()
				A.my_chair = master
				A.my_ship = master.ship
				A.my_hud = src

			if("toggle_tracking")
				if(toggle_tracking.icon_state == "tracking-on")
					toggle_tracking.icon_state = "tracking-off"
				else
					toggle_tracking.icon_state = "tracking-on"

				if(master.ship.control_lock)
					user.show_message(SPAN_ALERT("The controls are locked!"))
					SPAWN(0.3 SECONDS)
						if(toggle_tracking.icon_state == "tracking-on")
							toggle_tracking.icon_state = "tracking-off"
						else
							toggle_tracking.icon_state = "tracking-on"
						return

				if(tracking_light.icon_state == "tracking_light-on")
					tracking_light.icon_state = "tracking_light-off"
				else
					tracking_light.icon_state = "tracking_light-on"

				if(radar.icon_state == "radar_on")
					radar.icon_state = "radar_off"
				else
					radar.icon_state = "radar_on"

				if(master.ship.show_tracking)
					master.ship.remove_arrows(user)
					master.ship.show_tracking = 0
					user.show_message(SPAN_NOTICE("Tracking arrows disabled."))
				else
					master.ship.apply_arrows(user)
					master.ship.show_tracking = 1
					user.show_message(SPAN_NOTICE("Tracking arrows enabled."))

			if("toggle_nav")
				if(master.ship.control_lock)
					user.show_message(SPAN_ALERT("The controls are locked!"))
					return

				if(master.ship.navigating)
					master.ship.remove_nav_arrow(user)
					master.ship.navigating = 0
					user.show_message(SPAN_NOTICE("No longer navigating."))
					FLICK("nav-turn-off",toggle_nav)
					toggle_nav.icon_state = "nav-off"
				else
					var/list/navigable_bodies = list()
					for(var/datum/galactic_object/G in GALAXY.bodies)
						if(G.navigable)
							navigable_bodies += G
					var/datum/galactic_object/target = input(user, "Which waypoint would you like to navigate to?", "Target:", null) in navigable_bodies

					if(target)

						if(master.ship in target.nearby_ships)
							user.show_message(SPAN_NOTICE("You are already at waypoint [target]!"))
							return
						master.ship.nav_arrow = master.ship.create_nav_arrow(target)
						master.ship.apply_nav_arrow(user)
						master.ship.navigating = 1
						user.show_message(SPAN_NOTICE("Now navigating to waypoint [target]."))
						FLICK("nav-turn-on",toggle_nav)
						toggle_nav.icon_state = "nav-on"


			if("launch_nav_sat")
				FLICK("buoybutton_push",src.launch_nav_sat)

				if(master.ship.control_lock)
					user.show_message(SPAN_ALERT("The controls are locked!"))
					return

				if(!master.ship.buoy_count)
					user.show_message(SPAN_ALERT("Out of navigation probes!"))
					return

				var/satellite_name = input(user,"What would you like to name this satellite?", "Name:",null)
				if(satellite_name)
					var/datum/galactic_object/nav_sat/new_nav_sat = new
					new_nav_sat.name += " ([satellite_name])"
					new_nav_sat.my_satellite_name = satellite_name
					new_nav_sat.galactic_x = master.ship.galactic_x
					new_nav_sat.galactic_y = master.ship.galactic_y
					GALAXY.bodies += new_nav_sat
					var/obj/background_star/galactic_object/map_body = new_nav_sat.load_map_body(master.ship)
					master.ship.my_galactic_objects += map_body

					master.ship.my_galactic_objects[map_body] = master.ship.track_object(map_body) // feeds it the tracking arrow icon nom nom

					if(master.ship.my_pilot && master.ship.show_tracking)
						if(!(master.ship.my_galactic_objects[map_body] in master.ship.my_pilot.client.images))
							master.ship.my_pilot.client.images += master.ship.my_galactic_objects[map_body]

					map_body.loc = get_turf(master.ship.loc)
					map_body.actual_x = 0
					map_body.actual_y = 0
					map_body.pixel_x = 0
					map_body.pixel_y = 0

					map_body.stars_update(master.ship.vel_mag,master.ship.rot_mag,master.ship.vel_angle,master.ship.ship_angle)

					master.ship.buoy_count--
					src.buoy_counter.icon_state = "buoy-[master.ship.buoy_count]"

			if("coffee")
				user.visible_message(SPAN_NOTICE("[user] takes a sip of coffee."))
				if(src.coffee_level)
					src.coffee_level--
					src.coffee.icon_state = null
					playsound(get_turf(user),'sound/items/drink.ogg', rand(10,50), 1)
					SPAWN(0.5 SECONDS)
						src.coffee.icon_state = "coffee[coffee_level]"
				else
					user.show_message(SPAN_ALERT("Oh no! Out of coffee!"))

			if("control_lock")
				if(master.ship.control_lock)
					FLICK("key_unlocking",control_lock)
					control_lock.icon_state = "key_unlocked"
					control_light.icon_state = "control_unlocked"
				else
					FLICK("key_locking",control_lock)
					control_lock.icon_state = "key_locked"
					control_light.icon_state = "control_locked"
				master.ship.control_lock = !master.ship.control_lock

#endif
