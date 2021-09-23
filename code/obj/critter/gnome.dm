/obj/critter/garden_gnome
	name = "garden gnome"
	desc = "Space gnomes are a good omen in your garden. "
	icon = 'icons/misc/critter.dmi'
	icon_state = "gnome"
	density = 0
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 0.5
	brutevuln = 0.8
	angertext = "chants unintelligible gibberish at"
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE | FLUID_SUBMERGE

	var/plant_check = 20
	var/working_range = 1
	var/plant_plan
	var/obj/machinery/plantpot/work_target
	var/work_bore = 40

	ai_think()
		switch(src.task)
			if ("work idea")
				if ((get_dist(src, src.work_target) > src.working_range))
					src.anchored = initial(src.anchored)
					src.task = "chasing pot" // Yes, really
				else
					src.task = "work begin"
					return 0
			if ("chasing pot")
				if (!src.work_target)
					src.reset_plant_plan()
				else if (get_dist(src, src.work_target) <= src.working_range)
					src.task = "work begin"
				else if (src.mobile && --work_bore > 1)
					walk_to(src, src.work_target,1,4)
				else
					src.reset_plant_plan()
			if ("work begin")
				if (!src.work_target || get_dist(src, src.work_target) > src.working_range)
					src.task = "thinking"
				else
					src.task = "working"
					if (!src.work_plantpot())
						src.reset_plant_plan()
				return 0
			if ("working")
				if (--work_bore < 1)
					src.reset_plant_plan()
				return 0
			if ("attacking")
				..()
			else
				if (--plant_check < 1)
					plant_check = initial(plant_check)
					for (var/obj/machinery/plantpot/planter in view(7, src))
						// Gnomes mostly just water trays
						// The less water there is in a tray, the more likely a gnome is to water it. water_level range is 1-5
						if (planter.current && !planter.dead && prob(50-(planter.water_level*10)))
							plant_plan = "water"
							src.work_target = planter
							src.task = "work idea"
							return 0
						// Sometimes you may see gnomes keeping its garden clean
						if (planter.dead && prob(20))
							plant_plan = "clear"
							src.work_target = planter
							src.task = "work idea"
							return 0
						if (!planter.current && prob(5))
							plant_plan = "plant seed"
							src.work_target = planter
							src.task = "work idea"
							return 0
		..()

	CritterDeath()
		..()
		src.desc = "Body is still warm. Looks like there is a killer about."

	proc/work_plantpot()
		var/msg = "<span class='alert'><b>[src]</b> looks a bit confused, but then goes about its business.</span>"
		var/obj/machinery/plantpot/planter = work_target
		switch (src.plant_plan)
			if ("clear")
				if(planter.current && planter.dead)
					src.visible_message("<span class='alert'><b>[src]</b> begins clearing [planter].</span>")
					msg = "[src][pick(" succesfully", " skilfully", ", with regret,")] clears the [planter].\
					[prob(50) ? "The tray is now [pick("nice and clean", "ready for another plant")]." : ""]"
					SETUP_GENERIC_ACTIONBAR(src, src, 8 SECONDS, /obj/critter/garden_gnome/proc/clear_plant, list(),
					'icons/obj/hydroponics/items_hydroponics.dmi', "trowel", msg, null)
					return 1
				else
					src.visible_message(msg)
			if ("water")
				if (planter.current && !planter.dead)
					msg = ("<b>[src]</b> waters [planter].")
					SETUP_GENERIC_ACTIONBAR(src, src, 5 SECONDS, /obj/critter/garden_gnome/proc/water_plant, list(),
					'icons/obj/hydroponics/items_hydroponics.dmi', "wateringcan", msg, null)
					return 1
				else
					src.visible_message(msg)
			if ("plant seed")
				if (!planter.current)
					src.visible_message("<span class='alert'><b>[src] is planting something in [planter].</b></span>")
					SETUP_GENERIC_ACTIONBAR(src, src, 5 SECONDS, /obj/critter/garden_gnome/proc/seed_plant, list(),
					'icons/obj/hydroponics/items_hydroponics.dmi', "seeds", "", null)
					return 1


	proc/water_plant()
		// Sorry about this, but I can't come up with a better solution
		var/obj/machinery/plantpot/planter = work_target
		if (src.task == "working" && planter && get_dist(src, planter) <= src.working_range)
			if (planter.current && !planter.dead && planter.water_level < 5)
				var/datum/reagents/reagents_temp = new/datum/reagents(60)
				reagents_temp.my_atom = src
				reagents_temp.add_reagent("water", 60)
				reagents_temp.trans_to(planter, 60)
				qdel(reagents_temp)
		src.reset_plant_plan()

	proc/clear_plant()
		var/obj/machinery/plantpot/planter = work_target
		if (task == "working" && planter && planter.dead && get_dist(src, planter) <= src.working_range)
			planter.HYPdestroyplant()
		src.reset_plant_plan()

	proc/seed_plant()
		var/obj/machinery/plantpot/planter = work_target
		if (src.task == "working" && planter && get_dist(src, src.work_target) <= src.working_range)
			var/obj/item/seed/S
			if (prob(50)) // 50-50 if it is a strange seed or a random regular plant
				var/species = pick(hydro_controls.plant_species)
				S = unpool(/obj/item/seed)
				S.removecolor()
				S.generic_seed_setup(species)
			else
				S = unpool(/obj/item/seed/alien) // Strange seed
			// now plant the generated seed
			S.set_loc(planter.loc)
			if(S.planttype && !planter.current)
				planter.HYPnewplant(S)
				src.visible_message("<b>[src]</b> plants [S] in a tray.")
			else
				src.visible_message("<b>[src]</b> tried to plant [S] in [planter], but it already had something in!")
				pool(S)
		src.reset_plant_plan()

	proc/reset_plant_plan()
		task = "thinking"
		attacking = 0
		plant_plan = ""
		work_bore = initial(work_bore)
