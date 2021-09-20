/obj/critter/garden_gnome
	name = "garden gnome"
	desc = "Space gnomes are a good omen in your garden. "
	icon = 'icons/obj/junk.dmi'
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

	var/plant_check = 10
	var/working_range = 1
	var/plant_plan
	var/obj/machinery/plantpot/work_target


	ai_think()
		src.visible_message("DEBUG [src.task]")
		switch(src.task)
			if ("work begin")
				if ((get_dist(src, src.work_target) > src.working_range))
					src.anchored = initial(src.anchored)
					src.task = "chasing pot" // Yes, really
				else
					src.task = "working"
					return 0
			if ("chasing pot")
				if (!src.work_target)
					src.task = "thinking"
				else if (get_dist(src, src.work_target) <= src.working_range)
					src.task = "working"
				else if (src.mobile)
					walk_to(src, src.work_target,1,4)
			if ("working") // Critter does not continue the work if it is interrupted
				if (!src.work_target || get_dist(src, src.work_target) > src.working_range)
					src.visible_message("DEBUG_ work fail")
					src.task = "thinking"
				else
					src.visible_message("DEBUG_ work yes")
					src.task = "working2"
					src.work_plantpot()
				return 0
			if ("working2")
				return 0
			if ("attacking")
				..()
			else
				if (--plant_check < 1)
					src.visible_message("DEBUG perse thinking")
					plant_check = initial(plant_check)
					for (var/obj/machinery/plantpot/planter in view(7, src))
						// Gnomes mostly just water trays
						// The less water there is in a tray, the more likely a gnome is to water it. water_level range is 1-5
						if (planter.current && !planter.dead && prob(50-(planter.water_level*10)))
							plant_plan = "water"
							src.work_target = planter
							src.task = "work begin"
							return 0
						// Sometimes you may see gnomes keeping its garden clean
						if (planter.dead && prob(100))
							plant_plan = "clear"
							src.work_target = planter
							src.task = "work begin"
							return 0
		..()

	CritterDeath()
		..()
		src.desc = "Body is still warm. Looks like there is a killer about."

	proc/work_plantpot()
		src.visible_message("<span class='alert'><b>DEBUG [src] got in work_plantpot.</b></span>")
		var/obj/machinery/plantpot/planter = work_target
		switch (src.plant_plan)
			if ("clear")
				if(planter.current && planter.dead)
					src.visible_message("<span class='alert'><b>[src] begins clearing [planter].</b></span>")
					var/msg = "<span class='alert'>[src][pick(" succesfully", " skilfully", ", with regret,")] clears the [planter].</span>\
					[prob(50) ? "The tray is now [pick("nice and clean", "ready for another plant")].</span>" : ""]"
					// This is a bit buggy, in a way that it ends too quick because the critter stops it prematurely
					// could make the gnome "sleep" while acting, and then at the end of action bar awaken it
					SETUP_GENERIC_ACTIONBAR(src, planter, 5 SECONDS, /obj/critter/garden_gnome/proc/clear_plant, list(),
					'icons/obj/hydroponics/items_hydroponics.dmi', "trowel", msg, null)
				else
					src.visible_message("<span class='alert'><b>[src] looks a bit confused, but then goes about its business.</b></span>")
					src.task = "thinking"
					src.plant_plan = ""
					src.work_target = null
			if ("water")
				if (planter.current && !planter.dead)
					src.visible_message("<span class='alert'><b>[src] waters [planter].</b></span>")
					src.water_plant()
				else
					src.task = "thinking"
					src.plant_plan = ""
					src.work_target = null
			else
				src.task = "thinking"
				src.plant_plan = ""
				src.work_target = null


	proc/water_plant()
		// Sorry for this, but I can't come up with a better solution
		var/obj/machinery/plantpot/planter = work_target
		if (src.task == "working2" && planter)
			if (planter.current && !planter.dead && planter.water_level < 5)
				var/datum/reagents/reagents_temp = new/datum/reagents(60)
				reagents_temp.my_atom = src
				reagents_temp.add_reagent("water", 60)
				reagents_temp.trans_to(planter, 60)
				qdel(reagents_temp)
				/obj/machinery/r_door_control
			src.task = "thinking"
			src.attacking = 0
			src.plant_plan = ""

	proc/clear_plant()
		src.visible_message("<span class='alert'><b>DEBUG [src] got in clear_plant.</b></span>")
		var/obj/machinery/plantpot/planter = work_target
		if (src.task == "working2")
			planter.HYPdestroyplant()
		src.task = "thinking"
		src.attacking = 0
		src.plant_plan = ""
