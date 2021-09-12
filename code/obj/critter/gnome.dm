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

	var/laugh_cooldown = FALSE
	var/time_between_laughs = 50
	var/plant_check = 10
	var/plant_plan

	ai_think()
		if (task != "attacking")
			if (--plant_check < 1)
				plant_check = initial(plant_check)
				for (var/obj/machinery/plantpot/planter in view(7, src))
					// Gnomes mostly just water trays
					// The less water there is in a tray, the more likely a gnome is to water it. water_level range is 1-5
					if (planter.current && !planter.dead && prob(50-(planter.water_level*10)))
						plant_plan = "water"
						src.target = planter
						return
					// Sometimes you may see gnomes keeping its garden clean
					if (planter.dead && prob(10))
						plant_plan = "clear"
						src.target = planter
						return
		return ..()

	CritterAttack(mob/M)
		src.attacking = 1
		if (istype(M, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/planter = M
			if (plant_plan == "clear" && planter.current && planter.dead)
				src.visible_message("<span class='alert'><b>[src] begins clearing [planter].</b></span>")
				// This is a bit buggy, in a way that it ends too quick because the critter stops it prematurely
				// could make it sleep, and then at the end of action bar awaken it
				SETUP_GENERIC_ACTIONBAR(src, planter, 10 SECONDS, planter.HYPdestroyplant(), null,
				'icons/obj/hydroponics/items_hydroponics.dmi', "trowel",
				"<span class='alert'>[src] [pick("succesfully", "skilfully", ", with regret,")] clears the [planter].</span>\
				[prob(50) ? "The tray is now [pick("nice and clean", "ready for another plant")].</span>" : ""]", null)

				src.task = "thinking"
				src.attacking = 0
				src.plant_plan = ""
				return
			if (plant_plan == "water" && planter.current && !planter.dead)
				src.visible_message("<span class='alert'><b>[src] waters [planter].</b></span>")
				src.water_plant(planter)

				src.task = "thinking"
				src.attacking = 0
				src.plant_plan = ""
				return

	attack_hand(mob/user as mob)
		. = ..()
		if (src.alive && user.a_intent == INTENT_HELP && !src.laugh_cooldown)
			src.laugh_cooldown = TRUE
			playsound(src.loc, "sound/misc/gnomechuckle.ogg", 50, 1)
			SPAWN_DBG(src.time_between_laughs)
				src.laugh_cooldown = FALSE

	on_damaged(mob/user)
		. = ..()
		if (prob(50))
			playsound(src.loc, "sound/misc/gnomeoof.ogg", 50, 1)
		else if (prob(10))
			playsound(src.loc, "sound/misc/gnomecry.ogg", 50, 1)

	CritterDeath()
		..()
		src.desc = "Body is still warm. Looks like there is a killer about."

	proc/water_plant(var/obj/machinery/plantpot/planter)
		// Sorry for this, but I can't come up with a better solution
		if (planter.current && !planter.dead && planter.water_level < 5)
			var/datum/reagents/reagents_temp = new/datum/reagents(60)
			src.visible_message("<span class='alert'><b>[src] here did his job [planter].</b></span>")
			reagents_temp.my_atom = src
			reagents_temp.add_reagent("water", 60)
			reagents_temp.trans_to(planter, 60)
			qdel(reagents_temp)
		src.task = "thinking"
		src.attacking = 0
		src.plant_plan = ""

