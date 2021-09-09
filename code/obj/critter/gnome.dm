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
	//butcherable = 2
	//min_quality = -60
	flags = FPRINT | CONDUCT | USEDELAY | TABLEPASS | FLUID_SUBMERGE | FLUID_SUBMERGE

	var/plant_check = 10
	var/plant_plan

	ai_think()
		if (task != "attacking")
			if (--plant_check < 1)
				plant_check = initial(plant_check)
				for (var/obj/machinery/plantpot/planter in view(7, src))
					// Gnomes mostly just water trays
					if (planter.current && !planter.dead)
						if (prob(50-(planter.water_level*10))) // The less water in a tray, the more likely a gnome is to water it
							plant_plan = "water"
							src.target = planter
							return
					// Rarely you might see gnomes keeping the place clean
					if (planter.dead && prob(10))
						plant_plan = "clear"
						src.target = planter
						return
					// VERY rarely you might see them plant something, usually strange seeds
					if (planter.current && prob(1))
						plant_plan = "plant"
						src.target = planter
						return
		return ..()

	CritterAttack(mob/M)
		src.attacking = 1
		if (istype(M, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/planter = M
			if (plant_plan == "clear")
				if (planter.current && planter.dead)
					// TODO: interrupt flags, busy variable
					src.visible_message("<span class='alert'><b>[src] begins clearing [planter].</b></span>")

					SETUP_GENERIC_ACTIONBAR(src, planter, 10 SECONDS, planter.HYPdestroyplant(), null,
					'icons/obj/hydroponics/items_hydroponics.dmi', "trowel",
					"<span class='alert'>[src] [pick("succesfully", "skilfully", ", with regret,")] clears the [planter].</span>\
					[prob(50) ? "The tray is now [pick("nice and clean", "ready for another plant")].</span>" : ""]", null)

					src.task = "thinking"
					src.attacking = 0
					return

			if (plant_plan == "water")
				if (planter.current && !planter.dead)
					// I believe this does not need any chat messages
					//var/R = planter.reagents
					//C.reagents.add_reagent("methanol", 0.5 / length(mobs_affected))
					src.visible_message("<span class='alert'><b>[src] waters [planter].</b></span>")
					//obj/
					//SETUP_GENERIC_ACTIONBAR(src, planter, 2 SECONDS, /obj/critter/garden_gnome/proc/water_plant, list(planter),
					//'icons/obj/hydroponics/items_hydroponics.dmi', "wateringcan", "Hello", null)
					src.water_plant(planter)
					src.task = "thinking"
					src.attacking = 0
					return
			if (plant_plan == "plant")
				if (!planter.current)
					// Half of the time regular plants, half of the time strange seeds and some mutations
					//var/seed
					//var/species
					src.visible_message("Seed!")
					if (prob(100))
						for (var/A in concrete_typesof(/datum/plant))
							return
						//species = pick(concrete_typesof(/datum/plant))
					else
						//species = null
						return
					src.task = "thinking"
					src.attacking = 0
					return
				else
					/*
					TODO: make the gnome say something angry. Here is how critters speak to someone high in THC.
					var/text = pick_smart_string("shit_bees_say_when_youre_high.txt", "strings", list("M"="[M]", "beeMom"=bee.beeMom ? bee.beeMom : "Mom", "other_bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Seabee" : "Spacebee"), bee)
					if(!M.client.preferences.flying_chat_hidden)
					var/speechpopupstyle = "font-family: 'Comic Sans MS'; font-size: 8px;"
					chat_text = make_chat_maptext(bee, text, "color: [rgb(194,190,190)];" + speechpopupstyle, alpha = 140)
					M.show_message("[bee] buzzes \"[text]\"",2, assoc_maptext = chat_text)
					break
					*/
					src.task = "thinking"
					src.attacking = 0
					src.plant_plan = ""
					return

	proc/water_plant(var/obj/machinery/plantpot/planter)
		if (planter.current && !planter.dead && planter.water_level < 2)
			// Sorry for this, but I can't come up with a better solution
			var/datum/reagents/reagents_temp = new/datum/reagents(60)
			src.visible_message("<span class='alert'><b>[src] here did his job [planter].</b></span>")
			reagents_temp.my_atom = src
			reagents_temp.add_reagent("water", 60)
			reagents_temp.trans_to(planter, 60)
			qdel(reagents_temp)
		src.task = "thinking"
		src.attacking = 0

