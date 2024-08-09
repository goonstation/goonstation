/datum/pixel_offset
	var/atom/thing = null

	New(atom/thing, mob/user)
		. = ..()
		src.thing = thing
		src.ui_interact(user)

	disposing()
		src.thing = null
		..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "PixelOffset")
			ui.open()

	ui_status(mob/user, datum/ui_state/state)
		return UI_INTERACTIVE

	ui_close(mob/user)
		qdel(src)

	ui_data(mob/user)
		return list("x" = thing.pixel_x, "y" = thing.pixel_y, "thing_name" = "[src.thing]")

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		switch(action)
			if ("set_x")
				thing.pixel_x = params["x"]
				return TRUE
			if ("set_y")
				thing.pixel_y = params["y"]
				return TRUE
