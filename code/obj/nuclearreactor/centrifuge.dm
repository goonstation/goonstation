/obj/machinery/centrifuge_nuclear
	name = "Centrifuge"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "centrifuge0"
	desc = "A large machine that can be used to separate radioactive isotopes from spent fuel."
	anchored = ANCHORED
	density = TRUE
	var/doing_stuff = FALSE
	var/active_icon_state = "centrifuge1"
	var/inactive_icon_state = "centrifuge0"

	var/extracted_fuel = 0
	var/fuel_to_extract = 0

	//thanks portable reclaimer
	var/static/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/static/sound/sound_process = sound('sound/machines/ding.ogg')
	var/static/sound/sound_grump = sound('sound/machines/buzz-two.ogg')

	process()
		. = ..()
		if(doing_stuff && icon_state != active_icon_state)
			icon_state = active_icon_state
			UpdateIcon()
		else if(!doing_stuff && icon_state != inactive_icon_state)
			icon_state = inactive_icon_state
			UpdateIcon()

		if(doing_stuff)
			if(fuel_to_extract > 0)
				//still got stuff to process
				var/delta = min(fuel_to_extract, 0.5)
				extracted_fuel += delta
				fuel_to_extract -= delta
			else
				//we done here, spit out results
				var/obj/item/nuclear_waste/waste = new(get_turf(src))
				if(round(extracted_fuel) >= 1)
					var/obj/item/material_piece/plutonium/goodstuff = new(get_turf(src))
					goodstuff.amount = round(extracted_fuel)
					goodstuff.UpdateStackAppearance()
					extracted_fuel -= goodstuff.amount
					playsound(src, sound_process, 40, 1)
				else
					playsound(src, sound_grump, 40, 1)
				waste.material.setProperty("spent_fuel", extracted_fuel)
				extracted_fuel = 0
				doing_stuff = FALSE


	attackby(obj/item/W, mob/user)
		if(!istype(W, /obj/item/reactor_component) && !istype(W, /obj/item/nuclear_waste))
			boutput(user, "You can't put [W] in here, it doesn't fit!")
			return

		if (W.material && W.material.hasProperty("spent_fuel"))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, 1)
			W.set_loc(src)
			user?.u_equip(W)
			W.dropped(user)
			fuel_to_extract += W.material.getProperty("spent_fuel")
			doing_stuff = TRUE
			qdel(W)
		else
			boutput(user, "[W] isn't ready for reprocessing!")
