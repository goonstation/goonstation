/obj/machinery/power/nuke
	var/active = 1
	var/debug_heat = 0
	var/core_heat = T20C
	var/heat_transfer = 0

	var/obj/fluid_pipe/sink/n_input
	var/obj/fluid_pipe/source/n_output

	/* transfers heat from the n_input pipe of a fchamber or turbine into the core
	   we calculate the total thermal energy: (heat capcity) * (mass) * (temp)
	   of the incoming liquid and the core, and subtract them to make a delta.
	   the fluid LOSES heat and the core GAINS heat .. or vice versa if delta is negative */
	proc/transfer_heat_fp()
		var/datum/reagents/fp_holder/fp = src.n_input.network.pipe_cont
		var/fluid_mass = src.n_input.used_capacity * nuke_knobs.fluid_mass
		var/delta_t = fp.total_temperature - src.core_heat;
		var/fluid_composite_heat_capacity = 0
		var/delta_energy = 0
		var/fluid_energy_after = 0
		var/fluid_energy = 0
		var/fluid_energy_delta = 0
		var/core_energy = 0
		var/core_energy_after = 0
		var/core_temp_after = 0

		if(delta_t == 0) return

		for(var/rid in fp.reagent_list)
			var/datum/reagent/cur = fp.reagent_list[rid]
			var/part = cur.volume / fp.total_volume
			//DEBUG_MESSAGE("\[[src.type]\] reagent part vol: [cur.volume] \n total vol: [fp.total_volume]")
			fluid_composite_heat_capacity += part * cur.heat_capacity

		//DEBUG_MESSAGE("\[[src.type]\] fluid_composite_heat_capacity: [fluid_composite_heat_capacity]")

		fluid_energy = fp.total_temperature * fluid_composite_heat_capacity * fluid_mass
		core_energy  = src.core_heat * nuke_knobs.core_capacity * nuke_knobs.core_mass
		delta_energy = fluid_energy - core_energy

		fluid_energy_after = src.core_heat * fluid_composite_heat_capacity * fluid_mass
		fluid_energy_delta = fluid_energy - fluid_energy_after
		core_energy_after = core_energy + fluid_energy_delta
		core_temp_after = core_energy_after / (nuke_knobs.core_capacity * nuke_knobs.core_mass)

		if (nuke_knobs.stfu)
			DEBUG_MESSAGE("\[[src.type]\] delta_t: [delta_t] \n fluid_mass: [fluid_mass]")
			DEBUG_MESSAGE("\[[src.type]\] fluid energy: [fluid_energy]")
			DEBUG_MESSAGE("\[[src.type]\] core energy: [core_energy]")
			DEBUG_MESSAGE("\[[src.type]\] core energy after: [core_energy_after]")
			DEBUG_MESSAGE("\[[src.type]\] delta energy: [delta_energy]")
			DEBUG_MESSAGE("\[[src.type]\] fluid energy after: [fluid_energy_after]")
			DEBUG_MESSAGE("\[[src.type]\] fluid energy delta: [fluid_energy_delta]")
			DEBUG_MESSAGE("\[[src.type]\] core temp after: [core_temp_after], change: [core_temp_after - src.core_heat]")

		src.n_output.network.pipe_cont.total_temperature = src.core_heat
		src.core_heat = core_temp_after
		src.heat_transfer = delta_energy

		//delta_energy = fluid_composite_heat_capacity * fluid_mass * delta_t
		//src.heat_transfer = delta_energy

		//DEBUG_MESSAGE("delta_energy: [delta_energy]")

		//src.core_heat += (delta_energy / (nuke_knobs.core_capacity * nuke_knobs.core_mass))

		//src.n_output.network.pipe_cont.total_temperature += (delta_energy / (fluid_composite_heat_capacity * fluid_mass))
		fp.temperature_react()

/obj/machinery/power/nuke/fchamber
	name = "Nuclear Reactor Fission Chamber"
	desc = "todo"
	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "enginepoweredworking"
	anchored = 1
	density = 1
	layer = FLOOR_EQUIP_LAYER1

	var/obj/item/nuke/rod/fuel_array[9][9]
	var/debug = 1
	var/displayHtml = ""
	var/datum/nuke_knobset = null

	New()
		src.nuke_knobset = new /datum/nuke_knobset()
		nuke_core = src
		nuke_knobs = src.nuke_knobset

		SPAWN_DBG(0.5 SECONDS)
			debug_messages = 1 /* XXX */
			//make_fluid_networks()
			var/obj/fluid_pipe/sink/temp_i = locate(/obj/fluid_pipe/sink) in get_step(src,NORTH)
			var/obj/fluid_pipe/source/temp_o = locate(/obj/fluid_pipe/source) in get_step(src,SOUTH)
			//n_input = temp_i.network
			//n_output = temp_o.network
			n_input = temp_i
			n_output = temp_o

			//temp_i.network.pipe_cont.add_reagent("water", n_input.capacity, null)
			//temp_o.network.pipe_cont.add_reagent("water", n_input.capacity, null)

			..()

	attack_hand(mob/user as mob)
		displayHtml = buildHtml()
		user << browse(displayHtml,  "window=fissionchamber;size=550x700;can_resize=1;can_minimize=1;allow-html=1;show-url=1;statusbar=1;enable-http-images=1;can-scroll=1")
		return

	proc/buildHtml()
		var/html = ""

		html += "<html><head>"

		html += K_STYLE
		html += "</head><body>"
		html += "<div class=\"ib\">"
		html += "<h1>heat generated: [src.debug_heat] C</h1>"
		html += "<h1>core heat: [src.core_heat] C</h1>"
		html += "<h1>coolant flow: [src.n_input.used_capacity] mols/tick</h1>"
		html += "<h1>in  coolant temp: [src.n_input.network.pipe_cont.total_temperature] C</h1>"
		html += "<h1>out coolant temp: [src.n_output.network.pipe_cont.total_temperature] C</h1>"
		html += "<h1>heat delta: [src.heat_transfer] C</h1>"
		html += "</div>"
		html += "<div class=\"ib\">"
		html += "<table class=\"rs_table\">"

		for(var/i = 1, i <= 9, i++)
			html += "<tr id=\"r-[i]\">"

			for(var/j = 1, j <= 9, j++)
				html += "<td id=\"[i]-[j]\">"
				html += "<a href=\"?src=\ref[src];cell=1;r=[i];c=[j]\">"

				if(fuel_array[i][j] == null)
					html += "..."
				else
					html += fuel_array[i][j].material.name

				html += "</a>"
				html += "</td>"

			html += "</tr>"

		html += "</table>"
		html += "</div>"

		html += "</body></html>"
		return html

	Topic(href, href_list)
		src.add_dialog(usr)

		if(href_list["cell"])
			var/i = text2num_safe(href_list["r"])
			var/j = text2num_safe(href_list["c"])

			if(fuel_array[i][j] == null)
				var/obj/item/I = usr.equipped()
				if(istype(I,/obj/item/nuke/rod))
					usr.drop_item()
					I.set_loc(src)
					fuel_array[i][j] = I
					boutput(usr, "You insert the fuel rod into position [i],[j]")
					src.updateUsrDialog()
				else
					boutput(usr, "That does not fit into the reactor fuel array")
			else
				var/obj/item/I = fuel_array[i][j]
				usr.put_in_hand_or_drop(I)
				fuel_array[i][j] = null
				boutput(usr, "You remove the fuel rod")
				src.updateUsrDialog()

	proc/test_ff()
		ford_fulkerson(n_input.network)

	proc/gen_tick()
		if(!active) return
		var/debug_heat_c = 0

		if(src.n_input.network.last == REACTOR)
			return /* XXX make this sync */

		/* loop through the map and get each rod's cardinal (N/E/S/W) neighbor's flux contribution */
		for(var/i = 1, i <= 9, i++)
			for(var/j = 1, j <= 9, j++)
				var/obj/item/nuke/rod/cur = fuel_array[i][j]
				if(cur == null) continue

				var/inc_flux = cur.get_flux()

				var/obj/item/nuke/rod/north = null
				var/obj/item/nuke/rod/east = null
				var/obj/item/nuke/rod/south = null
				var/obj/item/nuke/rod/west = null

				if(i > 1)
					north = fuel_array[i - 1][j]
				if(i < 9)
					south = fuel_array[i + 1][j]
				if(j > 1)
					west = fuel_array[i][j - 1]
				if(j < 9)
					east = fuel_array[i][j + 1]

				if(north != null)
					inc_flux += north.get_flux()
				if(east != null)
					inc_flux += east.get_flux()
				if(south != null)
					inc_flux += south.get_flux()
				if(west != null)
					inc_flux += west.get_flux()

				var/datum/material/fissile/mat = cur.material
				debug_heat_c += mat.hpe * inc_flux

		debug_heat = debug_heat_c

		core_heat += (debug_heat)

		//src.test_ff()

		/*var/heat_before = n_input.network.pipe_cont.total_temperature
		n_output.network.pipe_cont.temperature_reagents(debug_heat + core_heat, n_output.used_capacity, 2, 300) /* XXX fix this */
		var/heat_delta = n_output.network.pipe_cont.total_temperature - heat_before
		heat_transfer = heat_delta

		core_heat += (debug_heat - heat_delta)*/

		transfer_heat_fp()

		src.n_output.network.last = REACTOR

		src.updateUsrDialog()

	process()
		gen_tick()





