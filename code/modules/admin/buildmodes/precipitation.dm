/datum/buildmode/precipitation
	name = "Precipitation"
	desc = {"**************************************************************<br>
Right Click on Buildmode Button 	   - Select precipitation effect<br>
Left Click on turf 			   		   - Add precipitation effect to tile<br>
Right Click on turf	  	  	   	   	   - Clear effect from tile<br>
Alt + Left Click                       - Add Reagent to Precipitation<br>
Alt + Right Click                      - Clear Reagents from Precipitation<br>
Ctrl + Left/Right Click		   		   - Whole Area<br>
Ctrl + Alt + Shift Left Click          - Edit Precipitation Controller<br>
**************************************************************"}
	icon_state = "precip_rain"
	var/effect_type = /obj/effects/precipitation/rain/sideways/tile

	click_mode_right(ctrl, alt, shift)
		var/target = input(usr, "Which kind?", "Precipitation Type", "rain") in list("rain", "snow")
		switch(target)
			if("rain")
				effect_type = /obj/effects/precipitation/rain/sideways/tile
			if("snow")
				effect_type = /obj/effects/precipitation/snow/grey/tile

		boutput(usr, "<span class='notice'>Now placing [target].</span>")

		update_icon_state("precip_[effect_type==/obj/effects/precipitation/rain/sideways/tile ? "rain" : "snow"]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = get_turf(object)

		if(ctrl && alt && shift)
			var/obj/effects/precipitation/P = locate() in T
			if(!P.PC)
				update_button_text("Connecting...")
				P.generate_controller()
			var/datum/precipitation_editor = new /datum/precipitation_editor(P.PC)
			precipitation_editor.ui_interact(usr)

			update_button_text()
			return

		if (ctrl)
			update_button_text("Spawning...")
			var/area/A = get_area(T)
			for(var/turf/AT in A)
				if(T.z != AT.z) continue
				new effect_type(AT)
				blink(AT)
		else if(alt)
			var/obj/effects/precipitation/P = locate() in T
			if(P)
				if(!P.PC)
					update_button_text("Connecting...")
					P.generate_controller()
				add_reagents(P.PC)
				P.PC.update()
			else
				boutput(usr, "<span class='notice'>This doesn't have any precipitation.</span>")
		else
			new effect_type(T)
			blink(T)
		update_button_text()

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = get_turf(object)
		var/obj/effects/precipitation/P

		if (ctrl)
			var/area/A = get_area(T)
			update_button_text("Clearing...")
			for(var/turf/AT in A)
				if(T.z != AT.z) continue
				P = locate() in AT
				if(P)
					blink(AT)
					qdel(P)
		else if(alt)
			P = locate() in T
			if(P && P.PC)
				P.PC.reagents.clear_reagents()
				P.PC.update()
		else
			P = locate() in T
			if(P)
				blink(T)
				qdel(P)
		update_button_text()

	proc/add_reagents(datum/precipitation_controller/PC)
		var/list/L = list()
		var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
		if(searchFor)
			for(var/R in concrete_typesof(/datum/reagent))
				if(findtext("[R]", searchFor)) L += R
		else
			L = concrete_typesof(/datum/reagent)

		var/type
		if(L.len == 1)
			type = L[1]
		else if(L.len > 1)
			type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
		else
			usr.show_text("No reagents matching that name", "red")
			return

		if(!type) return
		var/datum/reagent/reagent = new type()

		var/amount = input(usr,"Amount:","Amount",50) as null|num
		if(!amount) return

		PC.reagents.add_reagent(reagent.id, amount)

/datum/precipitation_editor
	var/datum/precipitation_controller/PC

/datum/precipitation_editor/New(datum/precipitation_controller/controller)
	..()
	PC = controller

/datum/precipitation_editor/disposing()
	PC = null
	..()


/datum/precipitation_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/precipitation_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Precipitation")
		ui.open()

/datum/precipitation_editor/ui_static_data(mob/user)
	. = list()

/datum/precipitation_editor/ui_data()
	. = list()
	.["probability"] = PC.probability
	.["cooldown"] = PC.cooldown
	.["poolDepth"] = PC.max_pool_depth
	.["reagent"] = PC.reagents

	var/list/containerData
	if(PC.reagents)
		var/datum/reagents/R = PC.reagents
		containerData = list(
			name = "Precipitation",
			maxVolume = R.maximum_volume,
			totalVolume = R.total_volume,
			temperature = R.total_temperature,
			contents = list(),
			finalColor = "#000000"
		)

		var/list/contents = containerData["contents"]
		if(istype(R) && R.reagent_list.len>0)
			containerData["finalColor"] = R.get_average_rgb()
			// Reagent data
			for(var/reagent_id in R.reagent_list)
				var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

				contents.Add(list(list(
					name = reagents_cache[reagent_id],
					id = reagent_id,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					volume = current_reagent.volume
				)))
		.["containerData"] = containerData


/datum/precipitation_editor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("set-cooldown")
			var/target = params["value"]
			if(isnum(target))
				PC.cooldown = target
				. = TRUE

		if("set-probability")
			var/target = params["value"]
			if(isnum(target))
				PC.probability = target
				. = TRUE

		if("set-poolDepth")
			var/target = params["value"]
			if(isnum(target))
				PC.max_pool_depth = target
				. = TRUE

		if("particle_editor")
			if(length(PC.effects))
				ui.user.client.open_particle_editor(PC.effects[1])

		if("flush_reagent")
			var/datum/reagents/R = PC.reagents
			var/id = params["reagent_id"]
			if(istype(R))
				R.remove_reagent(id, 500)
				PC.update()
				. = TRUE
		if("isolate")
			var/datum/reagents/R = PC.reagents
			var/id = params["reagent_id"]
			if(istype(R))
				R.isolate_reagent(id)
				PC.update()
				. = TRUE

		if("flush")
			var/datum/reagents/R = PC.reagents
			if(istype(R))
				R.clear_reagents()
				PC.update()
				. = TRUE
		if("add_reagents")
			add_reagents(PC)
			PC.update()
			. = TRUE


/datum/precipitation_editor/proc/add_reagents(datum/precipitation_controller/PC)
	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in concrete_typesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = concrete_typesof(/datum/reagent)

	var/type
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return

	if(!type) return
	var/datum/reagent/reagent = new type()

	var/amount = input(usr,"Amount:","Amount",50) as null|num
	if(!amount) return

	PC.reagents.add_reagent(reagent.id, amount)
