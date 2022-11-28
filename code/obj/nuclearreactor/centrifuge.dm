/obj/machinery/centrifuge_nuclear
	name = "Centrifuge"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "centrifuge0"
	desc = "A large machine that can be used to separate radioactive isotopes from spent fuel."
	anchored = 1
	density = 1
	var/doing_stuff = FALSE
	var/active_icon_state = "centrifuge1"
	var/inactive_icon_state = "centrifuge0"

	var/obj/item/reactor_component/fuel_rod = null
	var/extracted_fuel = 0
	var/fuel_to_extract = 0

	//thanks portable reclaimer
	var/static/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/static/sound/sound_process = sound('sound/effects/pop.ogg')
	var/static/sound/sound_grump = sound('sound/machines/buzz-two.ogg')

	process()
		. = ..()
		if(doing_stuff && icon_state != active_icon_state)
			icon_state = active_icon_state
			UpdateIcon()
		else if(!doing_stuff && icon_state != inactive_icon_state)
			icon_state = inactive_icon_state
			UpdateIcon()

		if(doing_stuff && fuel_rod)
			if(fuel_to_extract > 0)
				var/delta = min(fuel_to_extract, 0.5)
				extracted_fuel += delta
				fuel_to_extract -= delta
			else
				//we done here, spit out results
				var/obj/item/material_piece/slag/waste = new(get_turf(src))
				if(round(extracted_fuel/2.0) > 1)
					var/obj/item/material_piece/plutonium/goodstuff = new(get_turf(src))
					goodstuff.amount = round(extracted_fuel/2.0)
					playsound(src, sound_process, 40, 1)
				else
					waste.amount+=1
					playsound(src, sound_grump, 40, 1)
				qdel(fuel_rod)
				doing_stuff = FALSE


	attackby(obj/item/W, mob/user)
		if(doing_stuff)
			boutput(user, "The [src] is busy. Try again later.")
			return

		if (istype(W, /obj/item/reactor_component) && W.material && W.material.hasProperty("spent_fuel"))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, 1)
			W.set_loc(src)
			user?.u_equip(W)
			W.dropped(user)
			fuel_rod = W
			fuel_to_extract = W.material.getProperty("spent_fuel")
			doing_stuff = TRUE
		else
			boutput(user, "You can't put \a [W] in here![istype(W, /obj/item/reactor_component) ? " It isn't ready for reprocessing!":""]")
