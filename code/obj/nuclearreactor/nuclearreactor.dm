/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine
/////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/binary/nuclear_reactor
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
	anchored = TRUE
	density = TRUE
	mat_changename = FALSE
	dir = EAST
	var/list/obj/item/reactor_component/component_grid[6][6]
	var/list/list/datum/neutron/flux_grid[6][6]
	var/radiationLevel = 0
	var/datum/gas_mixture/current_gas = null
	var/temperature = T20C


	New()
		..()
		src.setMaterial(getMaterial("steel"))
		for(var/x=1 to 6)
			for(var/y=1 to 6)
				src.flux_grid[x][y] = list()

	process()
		. = ..()
		var/datum/gas_mixture/gas_input = air1
		var/datum/gas_mixture/gas_output = air2
		for(var/x=1 to 6)
			for(var/y=1 to 6)
				if(src.component_grid[x][y])
					//flow gas through components
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					var/datum/gas_mixture/gas = comp.processGas(gas_input)
					if(gas) gas_output.merge(gas)

					//balance heat between components
					comp.processHeat(src.getGridNeighbors(x,y))

					//calculate neutron flux
					src.flux_grid[x][y] = comp.processNeutrons(src.flux_grid[x][y])
					for(var/datum/neutron/N in src.flux_grid[x][y])
						var/xmod = 0
						var/ymod = 0
						xmod += ((N.dir & EAST) == EAST)
						xmod -= ((N.dir & WEST) == WEST)
						ymod += ((N.dir & SOUTH) == SOUTH)
						ymod -= ((N.dir & NORTH) == NORTH)
						if((x+xmod >= 1 & y+ymod >= 1) & (x+xmod <= 6 & y+ymod <= 6))
							src.flux_grid[x+xmod][y+ymod]+=N
							src.flux_grid[x][y]-=N
						else
							src.radiationLevel++ //neutrons hitting the casing get blasted in to the room - have fun with that engineers!

		var/datum/gas_mixture/gas = src.processCasingGas(gas_input) //the reactor has some inherent gas cooling channels
		if(gas) gas_output.merge(gas)
		//spawn radioactivity then reset level
		src.radiationLevel = 0
		src.network1?.update = TRUE
		src.network2?.update = TRUE

	proc/processCasingGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			var/heat_transfer_mult = 0.01
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = TOTAL_MOLES(src.current_gas)/src.material.getProperty("density")
			if(hTC>0)
				src.current_gas.temperature += heat_transfer_mult*-deltaT*hTC
				src.temperature += heat_transfer_mult*deltaT*(1/hTC)
			. = src.current_gas
		src.current_gas = inGas.remove(R_IDEAL_GAS_EQUATION * inGas.temperature)


	proc/getGridNeighbors(var/x,var/y)
		. = list()
		if(x-1 < 1)
			. += null
		else
			. += src.component_grid[x-1][y]
		if(x+1 > length(src.component_grid))
			. += null
		else
			. += src.component_grid[x+1][y]
		if(y-1 < 1)
			. += null
		else
			. += src.component_grid[x][y-1]
		if(y+1 > length(src.component_grid[1]))
			. += null
		else
			. += src.component_grid[x][y+1]

	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_step(src,node1_connect))
			if(target.initialize_directions & node2_connect)
				if(target != src)
					node1 = target
					target.node2 = src
					break

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_step(src,node2_connect))
			if(target.initialize_directions & node1_connect)
				if(target != src)
					node2 = target
					target.node1 = src
					break

		UpdateIcon()

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
		var/comps[6][6]
		for(var/x=1 to 6)
			for(var/y=1 to 6)
				if(src.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					comps[x][y]=list(
							"x" = x,
							"y" = y,
							"name" = comp.name,
							"img" = comp.ui_image,
							"temp" = comp.temperature
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
				var/x = params["x"]
				var/y = params["y"]
				if(src.component_grid[x][y])
					if(issilicon(ui.user))
						boutput(ui.user,"Your clunky robot hands can't grip the [src.component_grid[x][y]]!")
						return
					ui.user.visible_message("<span class='alert'>[ui.user] starts removing a [component_grid[x][y]]!</span>", "<span class='alert'>You start removing the [component_grid[x][y]]!</span>")
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 5 SECONDS, .proc/remove_comp_callback, list(x,y,ui.user), component_grid[x][y].icon, component_grid[x][y].icon_state,\
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)

				else
					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/reactor_component))
						ui.user.visible_message("<span class='alert'>[ui.user] tries to shove \a [equipped] into the reactor. Silly [ui.user]!</span>", "<span class='alert'>You try to put \a [equipped] into the reactor. You feel very foolish.</span>")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts inserting \a [equipped]!</span>", "<span class='alert'>You start inserting the [equipped]!</span>")
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 5 SECONDS, .proc/insert_comp_callback, list(x,y,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)

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

/datum/neutron
	var/dir = NORTH
	var/velocity = 1

	New(var/dir,var/velocity)
		..()
		src.dir = dir
		src.velocity = velocity
