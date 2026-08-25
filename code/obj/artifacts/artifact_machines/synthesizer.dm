/obj/machinery/artifact/synthesizer
	name = "matter-energy synthesizer"
	associated_datum = /datum/artifact/synthesizer
	var/datum/light/light

	New()
		. = ..()
		light = new /datum/light/point
		light.set_brightness(0.8)
		light.attach(src)

	proc/lightset(var/state)
		if(state)
			src.light.enable()
		else
			src.light.disable()

///Primarily associated with Menhir (used in a random event)
/datum/artifact/synthesizer
	associated_object = /obj/machinery/artifact/synthesizer
	type_name = "Synthesizer"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 0
	validtypes = list("precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/cold)
	activ_text = "crackles with energy!"
	deact_text = "goes dark."
	react_xray = list(15,55,72,11,"COMPLEX")
	var/datum/powernet/drawsource = null
	var/drawn_energy = 0
	var/initial_draw = 10 KILO WATTS
	var/draw_cap = 10e7
	var/current_draw = 0
	examine_hint = "It is covered in very conspicuous markings."

	post_setup()
		. = ..()
		src.react_heat[2] = "NO TEMPERATURE CHANGE" //slurped it right up
		src.initial_draw = rand(10 KILO WATTS, 20 KILO WATTS)
		src.draw_cap = rand(10,12) * 1e7

	may_activate(var/obj/O)
		if (!..())
			return 0
		var/turf/T = get_turf(O.loc)
		var/obj/cable/C = locate() in T
		if(!C)
			O.visible_message(SPAN_ALERT("[O] emits a loud pop and lights up momentarily but nothing happens!"))
			return 0
		var/datum/powernet/PN = C.get_powernet()
		if(PN.newavail <= 50000 && PN.avail <= 50000)
			O.visible_message(SPAN_ALERT("[O] emits a loud pop and lights up momentarily but nothing happens!"))
			return 0
		src.drawsource = PN
		return 1

	effect_activate(var/obj/O)
		if(..())
			return
		ArtifactLogs(usr, null, O, "activated", "making it begin to draw electricity from [drawsource]", 1)
		O.anchored = ANCHORED
		O:lightset(TRUE)

	effect_process(var/obj/O)
		if (..())
			return
		var/obj/cable/C = locate() in get_turf(O)
		if(!C)
			O.ArtifactDeactivated()
			return
		var/datum/powernet/PN = C.get_powernet()
		if((PN.newavail <= 50000 && PN.avail <= 50000) || PN.number != drawsource.number)
			O.ArtifactDeactivated()
			return
		if(!current_draw)
			current_draw = initial_draw
		else
			current_draw = current_draw ** 1.02

		var/drained = min(current_draw, (PN.avail - PN.newload))
		PN.newload += drained
		drawn_energy += drained

		var/soundlevel = min(current_draw / 8000, 35)
		playsound(O.loc, 'sound/machines/interdictor_operate.ogg', soundlevel, 0, pitch = 0.55, extrarange = 8)

		if(drained < current_draw)
			//check how much power we need to hit the desired rate
			var/draw_we_still_need = current_draw - drained
			//and simulate an approximate load to sustain this (estimated based on ~100 APCs accessible), capped to 50/tick (powersink value)
			var/estimate_per_apc = min((draw_we_still_need / 100) * CELLRATE, 50)

			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						var/pre_draw = A.cell.charge
						var/post_draw = max(0, pre_draw - estimate_per_apc)
						A.cell.charge = post_draw
						drawn_energy += (pre_draw - post_draw) / CELLRATE

		if(drawn_energy >= draw_cap) //we've drawn as much as we seek to, wrap it up
			O.ArtifactDeactivated()
			return

	effect_deactivate(var/obj/O)
		if(..())
			return

		current_draw = 0
		O:lightset(FALSE)

		///Determine how close we got to the desired amount of energy; the closer we got, the better materials we get
		var/completion = drawn_energy / draw_cap
		///Quantity of materials produced depends on energy gathered
		var/pool_rolls = floor(drawn_energy / 1.9e7)

		var/list/lootpool = list(/obj/item/raw_material/cobryl = 1+completion,\
			/obj/item/raw_material/syreline = 1.5-completion,\
			/obj/item/raw_material/bohrum = 2*completion,\
			/obj/item/raw_material/claretine = 0.5+completion,\
			/obj/item/raw_material/uqill = 0.8*completion,\
			/obj/item/raw_material/miracle = 0.2+completion,\
			/obj/item/material_piece/cloth/carbon = 0.4*completion,\
			/obj/item/raw_material/veranium = 0.2*completion,\
			/obj/item/raw_material/yuranite = 0.2*completion,\
			/obj/item/material_piece/neutronium = 0.05*completion,\
			/obj/item/raw_material/starstone = 0.05*completion)

		drawn_energy = 0
		initial_draw += 1 KILO WATT

		SPAWN(rand(5,15))
			var/turf/home_turf = get_turf(O)
			if(pool_rolls)
				var/list/fancy_spawn_spots = list()
				for(var/D in alldirs)
					var/turf/proxturf = get_step(home_turf,D)
					if(!is_blocked_turf(proxturf))
						fancy_spawn_spots += proxturf
				if(length(fancy_spawn_spots) > 1)
					for(var/i = 1 to pool_rolls)
						var/turf/target_turf = pick(fancy_spawn_spots)
						var/lootitem = weighted_pick(lootpool)
						showswirl(target_turf)
						new lootitem(target_turf)
						sleep(2)
				else
					showswirl(home_turf)
					sleep(2)
					for(var/i = 1 to pool_rolls)
						var/lootitem = weighted_pick(lootpool)
						new lootitem(home_turf)

			O.anchored = UNANCHORED
			playsound(home_turf, 'sound/machines/click.ogg', 25, 1, pitch = 0.5)
