/datum/buildmode/precipitation
	name = "Precipitation"
	desc = {"**************************************************************<br>
Right Click on Buildmode Button 	   - Select precipitation effect<br>
Left Click on turf 			   		   - Add preciptation effect to tile<br>
Right Click on turf	  	  	   	   	   - Clear effect from tile<br>
Alt + Left Click                       - Add Reagent to Precipitation<br>
Alt + Right Click                      - Clear Reagents from Preciptation<br>
Ctrl + Left/Right Click		   		   - Whole Area<br>
Ctrl + Alt + Shift Left Click          - Open Particool for Precipitation<br>
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
				P.generate_controller()
			usr.client.open_particle_editor(P)
			return

		if (ctrl)
			var/area/A = get_area(T)
			for(var/turf/AT in A)
				new effect_type(AT)
				blink(AT)
		else if(alt)
			var/obj/effects/precipitation/P = locate() in T
			if(P)
				if(!P.PC)
					P.generate_controller()
				add_reagents(P.PC)
				P.PC.update()
			else
				boutput(usr, "<span class='notice'>This doesn't have any precipitation.</span>")
		else
			new effect_type(T)
			blink(T)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = get_turf(object)
		var/obj/effects/precipitation/P

		if (ctrl)
			var/area/A = get_area(T)
			for(var/turf/AT in A)
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



