/obj/machinery/power/nuke/nuke_turbine
	name = "Large Turbine"
	desc = "A large assembly of fan blades rotated by steam pressure to generate electricity."
	icon = 'icons/obj/machinery/fusion.dmi'
	icon_state = "cab3"
	anchored = 1
	density = 1
	layer = FLOOR_EQUIP_LAYER1

	var/debug = 1
	var/displayHtml = ""
	var/genlast = 0

	New()
		nturbine = src
		SPAWN_DBG(5 DECI SECONDS)
			var/obj/fluid_pipe/sink/temp_i = locate(/obj/fluid_pipe/sink) in get_step(src,SOUTH)
			var/obj/fluid_pipe/source/temp_o = locate(/obj/fluid_pipe/source) in get_step(src,NORTH)
			//n_input = temp_i.network
			//n_output = temp_o.network
			n_input = temp_i
			n_output = temp_o
			..()

	attack_hand(mob/user as mob)
		displayHtml = buildHtml()
		user << browse(displayHtml,  "window=fissionchamber;size=550x700;can_resize=1;can_minimize=1;allow-html=1;show-url=1;statusbar=1;enable-http-images=1;can-scroll=1")
		return

	proc/gen_tick()
		if(!active) return

		if(src.n_input.network.last == TURBINE)
			return /* XXX make this sync */

		//var/heat_inc = n_input.network.pipe_cont.total_temperature

		//if(heat_inc > src.core_heat)
			/*var/delta = heat_inc - src.core_heat
			src.genlast = delta * nuke_knobs.joules_per_heat
			add_avail(src.genlast)
			src.core_heat += delta/10
			n_output.network.pipe_cont.temperature_reagents(heat_inc - delta, n_output.used_capacity, 2, 300) /* XXX fix this */
			*/

		var/before = src.core_heat
		transfer_heat_fp()
		if(before > src.core_heat)
			src.n_output.network.last = TURBINE
			return

		src.genlast = src.heat_transfer * nuke_knobs.joules_per_heat
		add_avail(src.genlast)
		src.n_output.network.last = TURBINE

		src.updateUsrDialog()

	process()
		gen_tick()


	proc/buildHtml()
		var/html = ""

		html += "<html><head>"

		html += K_STYLE
		html += "</head><body>"
		html += "<div class=\"ib\">"
		html += "<h1>core heat: [src.core_heat] C</h1>"
		html += "<h1>coolant flow: [src.n_input.used_capacity] mols/tick</h1>"
		html += "<h1>in  coolant temp: [src.n_input.network.pipe_cont.total_temperature] C</h1>"
		html += "<h1>out coolant temp: [src.n_output.network.pipe_cont.total_temperature] C</h1>"
		html += "<h1>heat delta: [src.heat_transfer] C</h1>"
		html += "<h1>power generated: [nturbine.genlast] \"E\"?</h1>"
		html += "</div>"

		html += "</body></html>"
		return html
