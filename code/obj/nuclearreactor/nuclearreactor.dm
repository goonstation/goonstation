/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine
/////////////////////////////////////////////////////////////////
#define REACTOR_GRID_WIDTH 7
#define REACTOR_GRID_HEIGHT 7

/obj/machinery/atmospherics/binary/nuclear_reactor
	name = "Model NTBMK Nuclear Reactor"
	desc = "A nuclear reactor vessel, with slots for fuel rods and other components. Hey wait, didn't one of these explode once?"
//	icon = 'icons/obj/atmospherics/pipes.dmi'
//	icon_state = "circ1-off"
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
	var/list/obj/item/reactor_component/component_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	var/list/list/datum/neutron/flux_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	var/radiationLevel = 0
	var/datum/gas_mixture/current_gas = null
	var/temperature = T20C
	var/datum/projectile/neutron_projectile = new /datum/projectile/neutron

	var/reactor_vessel_gas_volume=200
	var/obj/machinery/power/terminal/terminal = null
	var/net_id = null

	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src

		src.setMaterial(getMaterial("steel"))
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				src.flux_grid[x][y] = list()

	process()
		. = ..()
		var/output_starting_pressure = MIXTURE_PRESSURE(air2)
		var/input_starting_pressure = MIXTURE_PRESSURE(air1)
		var/tmpRads = 0
		boutput(world,"REACTOR: input=[input_starting_pressure] [air1.temperature]K output=[output_starting_pressure] [air2.temperature]K")

		//PV=nRT
		//We're using volume because that makes sense
		//but we need to express that in moles so,  1/n = RT/PV .. n = PV/RT
		var/transfer_moles = 0
		if(input_starting_pressure)
			transfer_moles = (air1.volume*input_starting_pressure)/(R_IDEAL_GAS_EQUATION*air1.temperature)
		var/datum/gas_mixture/gas_input = air1.remove(transfer_moles)
		var/datum/gas_mixture/gas_output = air2
		var/total_gas_volume = 0

		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					//flow gas through components
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					total_gas_volume += comp.gas_volume
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
					if((x+xmod >= 1 & y+ymod >= 1) & (x+xmod <= REACTOR_GRID_WIDTH & y+ymod <= REACTOR_GRID_HEIGHT))
						src.flux_grid[x+xmod][y+ymod]+=N
						src.flux_grid[x][y]-=N
					else
						src.flux_grid[x][y]-=N
						tmpRads++ //neutrons hitting the casing get blasted in to the room - have fun with that engineers!

		var/datum/gas_mixture/gas = src.processCasingGas(gas_input) //the reactor has some inherent gas cooling channels
		if(gas)
			gas_output.merge(gas)

		//if we somehow ended up with input gas still
		gas_output.merge(gas_input)

		src.radiationLevel = tmpRads
		processCaseRadiation(tmpRads)
		total_gas_volume += src.reactor_vessel_gas_volume
		src.air1.volume = total_gas_volume
		src.air2.volume = total_gas_volume
		src.network1?.update = TRUE
		src.network2?.update = TRUE

	proc/processCasingGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			var/heat_transfer_mult = 0.01
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(null, src.material)
			if(hTC>0)
				var/gas_shc_factor = HEAT_CAPACITY(current_gas)/(420*7700*2.5/0.055)
				src.current_gas.temperature += heat_transfer_mult*-deltaT*hTC
				src.temperature += gas_shc_factor*heat_transfer_mult*deltaT*hTC
			. = src.current_gas
		if(inGas)
			src.current_gas = inGas.remove((src.reactor_vessel_gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))


	proc/processCaseRadiation(var/rads)
		if(rads <= 0)
			return
		neutron_projectile.power = rads
		for(var/i = min(rads,10),i>0,i--)
			shoot_projectile_XY(src, neutron_projectile, rand(-10,10), rand(-10,10)) //for once, rand(range) returning int is useful
		rads -= min(rads,10)

		if(rads <= 0)
			return

		src.AddComponent(/datum/component/radioactive, min(rads,100), TRUE, FALSE, 5)




	proc/getGridNeighbors(var/x,var/y)
		. = list()
		if(x-1 < 1)
			. += null
		else
			. += src.component_grid[x-1][y]
		if(x+1 > REACTOR_GRID_WIDTH)
			. += null
		else
			. += src.component_grid[x+1][y]
		if(y-1 < 1)
			. += null
		else
			. += src.component_grid[x][y-1]
		if(y+1 > REACTOR_GRID_HEIGHT)
			. += null
		else
			. += src.component_grid[x][y+1]

	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node1_connect,3))
			if(target.initialize_directions & node2_connect)
				if(target != src)
					node1 = target
					//target.node2 = src
					break

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node2_connect,3))
			if(target.initialize_directions & node1_connect)
				if(target != src)
					node2 = target
					//target.node1 = src
					break

		UpdateIcon()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "NuclearReactor")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"gridW" = REACTOR_GRID_WIDTH,
			"gridH" = REACTOR_GRID_HEIGHT,
			"emptySlotIcon" = icon2base64(icon('icons/misc/reactorcomponents.dmi',"empty"))
		)

	ui_data()
		var/comps[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
		var/control_rod_level = 0
		var/control_rod_count = 0
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					if(istype(comp,/obj/item/reactor_component/control_rod))
						var/obj/item/reactor_component/control_rod/CR = comp
						control_rod_count++
						control_rod_level+=CR.configured_insertion_level
					comps[x][y]=list(
							"x" = x,
							"y" = y,
							"name" = comp.name,
							"img" = comp.ui_image,
							"temp" = comp.temperature,
							"extra" = comp.extra_info()
 						)

		. = list(
			"components" = comps,
			"reactorTemp" = src.temperature,
			"reactorRads" = src.radiationLevel,
			"controlRodLevel" = (control_rod_level/max(1,control_rod_count))*100
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return

		switch(action)
			if("adjustCR")
				for(var/x=1 to REACTOR_GRID_WIDTH)
					for(var/y=1 to REACTOR_GRID_HEIGHT)
						if(src.component_grid[x][y])
							if(istype(src.component_grid[x][y],/obj/item/reactor_component/control_rod))
								var/obj/item/reactor_component/control_rod/CR = src.component_grid[x][y]
								CR.configured_insertion_level = text2num(params["crvalue"])/100
			if("slot")
				var/x = params["x"]
				var/y = params["y"]
				if(src.component_grid[x][y])
					if(issilicon(ui.user))
						boutput(ui.user,"Your clunky robot hands can't grip the [src.component_grid[x][y]]!")
						return

					if(src.component_grid[x][y].melted)
						boutput(ui.user, "The component is melted! It's stuck.")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts removing a [component_grid[x][y]]!</span>", "<span class='alert'>You start removing the [component_grid[x][y]]!</span>")
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 2 SECONDS, .proc/remove_comp_callback, list(x,y,ui.user), component_grid[x][y].icon, component_grid[x][y].icon_state,\
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
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 2 SECONDS, .proc/insert_comp_callback, list(x,y,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
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

/datum/neutron //this is literally just a tuple
	var/dir = NORTH
	var/velocity = 1

	New(var/dir,var/velocity)
		..()
		src.dir = dir
		src.velocity = velocity

/obj/machinery/atmospherics/binary/nuclear_reactor/prefilled
	New()
		..()
		src.component_grid[3][1] = new /obj/item/reactor_component/gas_channel
		src.component_grid[3][3] = new /obj/item/reactor_component/gas_channel
		src.component_grid[3][5] = new /obj/item/reactor_component/gas_channel
		src.component_grid[3][7] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][1] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][3] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][5] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][7] = new /obj/item/reactor_component/gas_channel

		src.component_grid[3][2] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[3][4] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[3][6] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[5][2] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[5][4] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[5][6] = new /obj/item/reactor_component/heat_exchanger

		src.component_grid[4][1] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[4][7] = new /obj/item/reactor_component/heat_exchanger

		src.component_grid[4][3] = new /obj/item/reactor_component/control_rod("bohrum")
		src.component_grid[4][5] = new /obj/item/reactor_component/control_rod("bohrum")
		/*src.component_grid[3][2] = new /obj/item/reactor_component/gas_channel
		src.component_grid[2][3] = new /obj/item/reactor_component/gas_channel
		src.component_grid[3][6] = new /obj/item/reactor_component/gas_channel
		src.component_grid[2][5] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][2] = new /obj/item/reactor_component/gas_channel
		src.component_grid[6][3] = new /obj/item/reactor_component/gas_channel
		src.component_grid[6][5] = new /obj/item/reactor_component/gas_channel
		src.component_grid[5][6] = new /obj/item/reactor_component/gas_channel

		src.component_grid[3][3] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[2][4] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[3][5] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[5][3] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[6][4] = new /obj/item/reactor_component/heat_exchanger
		src.component_grid[5][5] = new /obj/item/reactor_component/heat_exchanger*/


#undef REACTOR_GRID_WIDTH
#undef REACTOR_GRID_HEIGHT

/datum/projectile/neutron //neutron projectile for radiation shooting from reactor
	name = "neutron"
	icon_state = ""
	icon = null
	power = 100
	cost = 0
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//Kill/Stun ratio
	ks_ratio = 1.0
//name of the projectile setting, used when you change a guns setting
	sname = "neutron"
//file location for the sound you want it to play
	shot_sound = null
	shot_number = 1
	damage_type = D_RADIOACTIVE
	//With what % do we hit mobs laying down
	hit_ground_chance = 50
	window_pass = FALSE
	silentshot = TRUE

	on_hit(atom/hit, angle, var/obj/projectile/O)
		. = FALSE //default to doing normal hit behaviour
		if(hit.material)
			if(prob(hit.material.getProperty("hardness")))
				//reflect
				shoot_reflected_bounce(O, hit)

			if(prob(hit.material.getProperty("n_radioactive")))
				hit.AddComponent(/datum/component/radioactive, min(power,20), TRUE, TRUE, 1)
			if(prob(hit.material.getProperty("radioactive")))
				hit.AddComponent(/datum/component/radioactive, min(power,20), TRUE, FALSE, 1)
		hit.AddComponent(/datum/component/radioactive, min(power,5), TRUE, FALSE, 1)
		return

	on_pre_hit(atom/hit, angle, var/obj/projectile/O)
		. = FALSE //default to doing normal hit behaviour
		if(hit.material && !prob(hit.material.getProperty("density")))
			O.power /= 2
			. = TRUE
