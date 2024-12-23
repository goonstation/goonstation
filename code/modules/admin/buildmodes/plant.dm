/datum/buildmode/plant
	name = "Plant"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf       = Plant the plant on that thing<br>
Right Mouse Button on buildmode    	    = Select plant type<br>
Shift + Right Mouse Button on buildmode = Select mutation<br>
Ctrl + Right Mouse Button on buildmode  = Toggle density<br>
***********************************************************"}
	icon_state = "buildmode_transmute"
	var/datum/plant/plant = null
	var/datum/plantmutation/mutation = null
	var/density = FALSE

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (shift)
			if (!src.plant)
				boutput(usr, "No plant type selected")
				return
			if (!length(src.plant.mutations))
				boutput(usr, "No mutations found")
				return
			var/list/mutations = list()
			for (var/datum/plantmutation/mutation in src.plant.mutations)
				mutations[mutation.name] = mutation

			var/selected = tgui_input_list(usr, "Pick mutation", "Mutation select", mutations)
			src.mutation = mutations[selected]
			boutput(usr, "Set mutation to [src.mutation.name]")
		else if (ctrl)
			src.density = !src.density
			boutput(usr, "Plant density toggled [src.density ? "on" : "off"]")
		else
			var/datum/plant/old_plant = src.plant
			var/planttype = tgui_input_list(usr, "Pick plant type", "Plant select", concrete_typesof(/datum/plant))
			if (!planttype)
				return
			src.plant = HY_get_species_from_path(planttype)
			if (old_plant != src.plant)
				src.mutation = null
			boutput(usr, "Set plant to [src.plant.name]")
		src.update_button_text("[src.mutation.name] [src.plant.name]")

	click_left(atom/object, var/ctrl, var/alt, var/shift) //component crime :)
		var/datum/component/arable/component = object.AddComponent(/datum/component/arable/single_use)
		var/obj/item/seed/seed = new
		seed.dont_mutate = TRUE
		seed.generic_seed_setup(src.plant)
		seed.plantgenes.mutation = src.mutation
		component.plant_seed(object, seed, null)
		component.P.density = src.density
		component.P.growth = seed.planttype.harvtime //set it to just matured
		SPAWN(1) //look someone else did SPAWN(0) elsewhere in the chain and I just need this to work
			component.P.ProcessMachine()
