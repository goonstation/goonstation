/obj/item/pocketwatch
	name = "pocket watch"
	desc = "write this later"
	icon = 'icons/obj/objects.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "watch_closed"
	item_state = "pocketwatch"
	force = 0
	throwforce = 0
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER
	inventory_counter_enabled = TRUE
	var/list/clock_modes = list("Time Keeping", "Budget Monitoring")
	var/current_clock_mode = "Time Keeping"
	var/hour_minute_divider = ":" //used to make the colon in the time blink like a clock display

	New()
		processing_items.Add(src)
		create_inventory_counter()
		..()

	dropped()
		icon_state = "watch_closed"
		flick("watch_close_animation_clock", src)
		..()

	attack_hand(mob/user)
		icon_state = "watch_open_clock"
		flick("watch_open_animation_clock", src)
		process()
		..()

	attack_self(mob/user as mob)
		var/new_mode = tgui_input_list(usr, "What mode should the watch be set to?", "Watch Mode", clock_modes)
		if (new_mode)
			current_clock_mode = new_mode
			update_clock()
			UpdateIcon()

	proc/update_clock()
		if(current_clock_mode == "Time Keeping")
			if(hour_minute_divider == ":")
				hour_minute_divider = " "
			else
				hour_minute_divider = ":"
			src.inventory_counter.update_text("[text2num(time2text(world.timeofday, "hh"))] [hour_minute_divider] [text2num(time2text(world.timeofday, "mm"))]")

	process()
		update_clock()
		..()

