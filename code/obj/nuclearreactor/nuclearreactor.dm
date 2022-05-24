/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine
/////////////////////////////////////////////////////////////////

/obj/machinery/nuclear_reactor
	name = "Model NTBMK Nuclear Reactor"
	desc = "A nuclear reactor vessel, with slots for fuel rods and other components. Hey wait, didn't one of these explode once?"
	icon = 'icons/misc/nuclearreactor.dmi'
	icon_state = "reactor_empty"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	anchored = 1
	density = 1

	var/list/obj/item/reactor_component/component_grid[6][6]

	New()
		..()

	process()
		. = ..()
		for(var/i=1 to 6)
			for(var/j=1 to 6)
				if(src.component_grid[i][j])
					var/obj/item/reactor_component/comp = src.component_grid[i][j]
					comp.processGas()
					comp.processHeat()
					comp.processNeutrons()


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "NuclearReactor")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"gridW" = length(src.component_grid),
			"gridH" = length(src.component_grid[1])
		)

	ui_data()
		var/comps = list()
		for(var/i=1 to 6)
			for(var/j=1 to 6)
				if(src.component_grid[i][j])
					var/obj/item/reactor_component/comp = src.component_grid[i][j]
					comps += list(
						list(
							"x" = i,
							"y" = j,
							"name" = comp.name,
							"img" = comp.ui_image,
						)
					)
		. = list(
			"components" = comps,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return

		switch(action)
			if("slot")
				var/i = params["x"]
				var/j = params["y"]
				if(src.component_grid[i][j])
					if(issilicon(ui.user))
						boutput(ui.user,"Your clunky robot hands can't grip the [src.component_grid[i][j]]!")
						return
					ui.user.visible_message("<span class='alert'>[ui.user] starts removing a [component_grid[i][j]]!</span>", "<span class='alert'>You start removing the [component_grid[i][j]]!</span>")
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/remove_comp_callback, list(i,j,ui.user), component_grid[i][j].icon, component_grid[i][j].icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
				else
					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/reactor_component))
						ui.user.visible_message("<span class='alert'>[ui.user] tries to shove \a [equipped] into the reactor. Silly [ui.user]!</span>", "<span class='alert'>You try to put \a [equipped] into the reactor. You feel very foolish.</span>")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts inserting \a [equipped]!</span>", "<span class='alert'>You start inserting the [equipped]!</span>")
					SETUP_GENERIC_ACTIONBAR(ui.user, src, 5 SECONDS, .proc/insert_comp_callback, list(i,j,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)

	proc/insert_comp_callback(var/x,var/y,var/mob/user,var/obj/item/reactor_component/equipped)
		if(src.component_grid[x][y])
			return FALSE
		src.component_grid[x][y]=equipped
		user.u_equip(equipped)
		equipped.set_loc(src)
		playsound(src, "sound/machines/law_insert.ogg", 80)
		user.visible_message("<span class='alert'>[user] slides \a [equipped] into the reactor</span>", "<span class='alert'>You slide the [equipped] into the reactor.</span>")
		tgui_process.update_uis(src)

	proc/remove_comp_callback(var/x,var/y,var/mob/user)
		playsound(src, "sound/machines/law_remove.ogg", 80)
		user.visible_message("<span class='alert'>[user] slides \a [src.component_grid[x][y]] out of the reactor</span>", "<span class='alert'>You slide the [src.component_grid[x][y]] out of the reactor.</span>")
		user.put_in_hand_or_drop(src.component_grid[x][y])
		src.component_grid[x][y] = null
		tgui_process.update_uis(src)
