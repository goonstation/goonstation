/obj/item/pocketwatch
	name = "Monitor Watch"
	desc = "A high-tech pocketwatch with an electronic ink display. Hooked into the station's monitoring systems, it can provide personnel with important financial information instantly from far away, and also tell the time with a faux-analog display."
	icon = 'icons/obj/objects.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "watch_closed"
	item_state = "pocketwatch"
	force = 0
	throwforce = 0
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER
	inventory_counter_enabled = TRUE
	var/list/clock_modes = list("Time Keeping", "Total Station Budget Monitor", "Payroll Budget Monitor", "Cargo Budget Monitor", "Research Budget Monitor", "Total PTL Net Income")
	var/current_clock_mode = "Time Keeping"
	var/hour_minute_divider = ":" //used to make the colon in the time blink like a clock display
	var/display_type = "clock" //used to show analog or screen displays on sprite
	var/text_to_display

	New()
		processing_items.Add(src)
		create_inventory_counter()
		..()

	dropped()
		icon_state = "watch_closed"
		flick("watch_close_animation_[display_type]", src)
		..()

	attack_hand(mob/user)
		icon_state = "watch_open_[display_type]"
		flick("watch_open_animation_[display_type]", src)
		process()
		..()

	attack_self(mob/user as mob)
		var/new_mode = tgui_input_list(usr, "What mode should the watch be set to?", "Watch Mode", clock_modes)
		if (new_mode)
			current_clock_mode = new_mode
			if(current_clock_mode == "Time Keeping")
				display_type = "clock"
			else
				display_type = "screen"
			icon_state = "watch_open_[display_type]"
			update_clock()

	proc/update_clock()
		if(current_clock_mode == "Time Keeping")
			if(hour_minute_divider == ":")
				hour_minute_divider = " "
			else
				hour_minute_divider = ":"
			var/hour_display = text2num(time2text(world.timeofday, "hh"))
			var/minute_display
			if(text2num(time2text(world.timeofday, "mm")) < 10)
				minute_display = "0[text2num(time2text(world.timeofday, "mm"))]" //to avoid the time being "12:3 ever"
			else
				minute_display = text2num(time2text(world.timeofday, "mm"))
			text_to_display = "[hour_display] [hour_minute_divider] [minute_display]"

		else if(current_clock_mode == "Total Station Budget Monitor")
			text_to_display = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget

		else if(current_clock_mode == "Payroll Budget Monitor")
			text_to_display = wagesystem.station_budget

		else if(current_clock_mode == "Cargo Budget Monitor")
			text_to_display = wagesystem.shipping_budget

		else if(current_clock_mode == "Research Budget Monitor")
			text_to_display = wagesystem.research_budget

		else if(current_clock_mode == "Total PTL Net Income")
			var/total_PTL_money = 0
			for(var/obj/machinery/power/pt_laser/PTL in machine_registry[MACHINES_POWER])
				total_PTL_money += PTL.lifetime_earnings
			text_to_display = total_PTL_money


		src.inventory_counter.update_text(text_to_display)


	process()
		update_clock()
		..()

