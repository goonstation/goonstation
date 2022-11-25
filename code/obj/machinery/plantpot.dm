// This file is arguably the "main" file where all of the central hydroponics shit goes down.
// Most of the actual content itself is found in other files, but the plantpot does just about
// all of the actual work, so if you're looking to see how Hydro works at the very base level
// this is the file you want to be looking in.
//
// Other files you'll want if you're looking up on Hydroponics stuff:
// obj/item/plants_food_etc.dm: Most of the seed and produce items are in here.
// obj/item/hydroponics.dm: The tools players use to do hydro work are here.
// datums/plants.dm: The plant species, mutations and genetics are kept here.
// obj/submachine/seed.dm: The splicer and reagent extractor are in here.

/obj/machinery/plantpot/hightech
	name = "high-tech hydroponics tray"
	desc = "A mostly debug-only plant tray that is capable of revealing more information about your plants."

	New()
		..()

	proc/update_maptext()
		if (!src.current)
			src.maptext = "<span class='pixel ol c vb'></span>"
			return
		maptext_width = 96
		maptext_y = 32
		maptext_x = -32
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/growth_pct = round(src.growth / (growing.harvtime - (DNA ? DNA.harvtime : 0)) * 100)
		var/hp_pct = 0
		var/hp_text = ""
		if (growing.starthealth != 0)
			hp_pct = round(health / growing.starthealth * 100)
			hp_text = "[hp_pct]%"
		else
			hp_pct = round(health / 10 * 100)
			hp_text = "[health]*"

		var/hp_col = "#ffffff"
		switch (hp_pct)
			if(400 to INFINITY)
				hp_col = "#88ffff"
			if(200 to 400)
				hp_col = "#88ff88"
			if(100 to 200)
				hp_col = "#ffffff"
			if(50 to 100)
				hp_col = "#ffff00"
			if(25 to 50)
				hp_col = "#ff8000"
			else
				hp_col = "#ff0000"

		src.maptext = "<span class='pixel ol sh c vt'>GR [growth_pct]%\n<span style='color: [hp_col];'>HP [hp_text]</span></span>"

	get_desc()
		if(!src.current)
			return

		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/growthlimit = growing.harvtime - DNA.harvtime
		return "Generation [src.generation] - Health: [src.health] / [growing.starthealth] - Growth: [src.growth] / [growthlimit] - Harvests: [src.harvests] left."

	process()
		..()
		update_maptext()

/obj/machinery/plantpot/kudzu
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife... Made of plants."
	icon_state = "kudzutray"
	power_usage = 0

	attackby(var/obj/item/W, var/mob/user)
		//Can only attempt to destroy the plant pot if the plant in it is dead or empty.
		if(!src.current || src.dead)
			if (destroys_kudzu_object(src, W, user))
				if (prob(40))
					user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W]!</span>")
				else
					user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W], destroying it!</span>")
					qdel(src)
					return
			else
				return ..()
		..()

/obj/machinery/plantpot/bareplant
	name = "arable soil"
	desc = "A small mound of arable soil for planting and plant based activities."
	anchored = 1
	mats = 0
	deconstruct_flags = 0
	icon_state = null
	power_usage = 0
	growth_rate = 1
	/// plant to grow
	var/datum/plant/spawn_plant = null
	/// growth level to spawn with
	var/spawn_growth = null
	/// list of commuts to apply to plant
	var/list/datum/plant_gene_strain/spawn_commuts = list()
	var/auto_water = TRUE

	New(newLoc, obj/item/seed/initial_seed)
		SPAWN(0) // delay for prefab attribute assignment
			var/datum/plant/P
			//Adjust processing tier to slow down server burden unless necessary
			if(spawn_plant)
				P = new spawn_plant()
				if(!P.special_proc)
					processing_tier = PROCESSING_32TH
			..()
			status |= BROKEN

			if(initial_seed)
				src.HYPnewplant(initial_seed)
				UpdateIcon()
			else if(P)
				var/obj/item/seed/S = new /obj/item/seed

				S.generic_seed_setup(P)
				src.HYPnewplant(S)

				for(var/commutes in spawn_commuts)
					HYPaddCommut(src.current, src.plantgenes, commutes)

				if(spawn_growth)
					src.grow_level = spawn_growth
				else
					src.grow_level = pick(3,4,4)
				switch(grow_level)
					if(2)
						src.growth = (src.current.growtime - src.plantgenes.growtime) / 2
					if(3)
						src.growth = src.current.growtime - src.plantgenes.growtime
					if(4)
						src.growth = src.current.harvtime - src.plantgenes.harvtime
				UpdateIcon()
			else
				if(!src.current)
					qdel(src)

	attackby(obj/item/W, mob/user)
		// Filter out the following item interactions
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			boutput(user, "<span class='alert'>[W] does not seem like the right tool for the job.</span>")
		else if(istype(W, /obj/item/seed/) || istype(W, /obj/item/seedplanter/))
			boutput(user, "<span class='alert'>Something is already growing there.</span>")
		else
			..()

	attack_hand(var/mob/user)

		if(isAI(user) || isobserver(user)) return // naughty AIs used to be able to harvest plants
		src.add_fingerprint(user)
		if(src.current)
			if(src.dead)
				boutput(user, "<span class='notice'>You clear the dead plant.</span>")
				HYPdestroyplant()
				return

			if(HYPcheck_if_harvestable())
				HYPharvesting(user,null)


	HYPdestroyplant()
		..()
		qdel(src)

	update_water_icon()
		return

	process()
		..()
		if(auto_water)
			if(src.reagents && !src.reagents.has_reagent("water", 50))
				src.reagents.add_reagent("water", 200)

	flower
		New()
			spawn_plant = pick(/datum/plant/flower/rose)
			..()

	crop
		New()
			spawn_plant = pick(/datum/plant/crop/cotton, /datum/plant/crop/oat, /datum/plant/crop/peanut, /datum/plant/veg/soy)
			..()

	tree
		New()
			spawn_plant = pick(/datum/plant/crop/tree, /datum/plant/fruit/cherry, /datum/plant/fruit/apple, /datum/plant/fruit/peach)
			..()

	weed
		New()
			spawn_plant = pick(/datum/plant/weed/creeper, /datum/plant/weed/lasher, /datum/plant/weed/slurrypod, /datum/plant/artifact/pukeplant)
			..()


/obj/machinery/plantpot
	// The central object for Hydroponics. All plant growing and most of everything goes on in
	// this object - that said you don't want to have too many of them on the map because they
	// get kind of resource intensive past a certain point.
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "tray"
	anchored = 0
	density = 1
	mats = 2
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR
	flags = NOSPLASH|ACCEPTS_MOUSEDROP_REAGENTS
	processing_tier = PROCESSING_SIXTEENTH
	machine_registry_idx = MACHINES_PLANTPOTS
	power_usage = 25
	var/datum/plant/current = null // What is currently growing in the plant pot
	var/datum/plantgenes/plantgenes = null // Set this up in New
	var/tickcount = 0  // Automatic. Tracks how many ticks have elapsed, for CPU efficiency things.
	var/dead = 0       // Automatic. If the plant is dead.
	var/growth = 0     // Automatic. How developed the plant is.
	var/health = 0     // Set this when you plant a seed. Plant dies when this hits 0.
	var/harvests = 0   // Set this when you plant a seed. How many times you can harvest it before it dies. Plant dies when it hits 0.
	var/recently_harvested = 0 // Automatic. A time delay between harvests.
	var/generation = 0 // Automatic. Just a fun thing to track how many generations a plant has been bred.
	var/weedproof = 0  // Does this tray block weeds from appearing in it? (Won't stop deliberately planted weeds)
	var/list/contributors = list() // Who helped grow this plant? Mainly used for critters.

	var/report_freq = FREQ_HYDRO //Radio channel to report plant status/death/whatever.
	var/net_id = null

	var/health_warning = 0
	var/harvest_warning = 0
	var/water_level = 4 // Used for efficiency in the UpdateIcon proc with water level changing
	var/total_volume = 4 // How much volume total is actually in the tray because why the fuck was water the only reagent being counted towards the level
	var/image/water_sprite = null
	var/image/water_meter = null
	var/image/plant_sprite = null
	var/grow_level = 1 // Same as the above except for current plant growth
	var/do_update_water_icon = 1 // this handles the water overlays specifically (water and water level) It's set to 1 by default so it'll update on spawn
	var/growth_rate = 2
		// We have this here as a check for whether or not the plant needs to update its sprite.
		// Originally plantpots updated constantly but this was found to be rather expensive, so
		// now it only does that if it needs to.
	var/actionpassed 	//holds defines for action bar harvesting yay :D
	New()
		..()
		src.plantgenes = new /datum/plantgenes(src)
		src.create_reagents(400)
		// The plantpot can store 400 reagents in total, we want a bit more than the max water
		// level since we can put other additives in the pot for various effects.
		reagents.add_reagent("water", 200)
		// 200 is the exact maximum amount of water a plantpot can hold before it is considered
		// to have too much water, which stunts plant growth speed.
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi', "wat-[src.water_level]")
		src.plant_sprite = image('icons/obj/hydroponics/plants_weed.dmi', "")
		UpdateIcon()

		if(!net_id)
			net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, report_freq)

	proc/post_alert(var/alert_msg)
		if(status & (NOPOWER|BROKEN)) return
		if(!alert_msg) return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data["data"] = alert_msg
		signal.data["netid"] = net_id
		signal.data["address_tag"] = "plantpot_listener" // prevents unnecessarily sending to other plantpots

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	proc/update_water_level() //checks reagent contents of the pot, then returns the cuurent water level
		var/current_total_volume = (src.reagents ? src.reagents.total_volume : 0)
		var/current_water_level = (src.reagents ? src.reagents.get_reagent_amount("water") : 0)
		switch(current_water_level)
			if(0 to 0) current_water_level = 1
			if(0 to 40) current_water_level = 2
			if(40 to 100) current_water_level = 3
			if(100 to 200) current_water_level = 4
			if(200 to INFINITY) current_water_level = 5
		if(current_water_level != src.water_level)
			src.water_level = current_water_level
			src.do_update_water_icon = 1
		if(!current)
			switch(current_total_volume)
				if(0 to 0) current_total_volume = 1
				if(0 to 40) current_total_volume = 2
				if(40 to 100) current_total_volume = 3
				if(100 to 200) current_total_volume = 4
				if(200 to INFINITY) current_total_volume = 5
			if(current_total_volume != src.total_volume)
				src.total_volume = current_total_volume
				src.do_update_water_icon = 1

		if(src.do_update_water_icon)
			src.update_water_icon()
			src.do_update_water_icon = 0

		return current_water_level

	on_reagent_change()
		..()
		src.do_update_water_icon = 1
		src.update_water_level()

	power_change()
		. = ..()
		UpdateIcon()

	was_deconstructed_to_frame(mob/user)
		src.current = null // Dont think this would lead to any frustrations, considering like, youre chopping the machine up of course itd destroy the plant.
		boutput( user, "<span class='alert'>In the process of deconstructing the tray you destroy the plant.</span>" )

	process()
		..()

			// We skip every other tick. Another cpu-conserving measure.
		if(!src.current || src.dead)
			return
			// If the plantpot is empty or contains a dead plant, we don't need to do anything
			// more in the process loop since that'd be pointless and silly.

		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		// We obtain the current plant type in the plantpot, and the genes of the individual plant.
		// We'll be referencing these a lot!

		// REAGENT PROCESSING
		var/drink_rate = 1
		// drink_rate is how much reagent is consumed per tick. This used to be 0.5, but got bumped
		// up to 1 when the tick rate for plant pots was halved.
		if(growing.simplegrowth)
			src.growth++
			// Simplegrowth is used pretty much only for crystals. It essentially skips all
			// simulation whatsoever and just adds one growth point per tick, ignoring all
			// reagents and everything else going on.
		else
			var/current_water_level = src.update_water_level()

			// The above is pretty much to figure out whether or not the water level
			// icon on the plant pot needs to change.

			if(current_water_level)
				if(current_water_level <= 200) // max water limit!!
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/metabolism_slow) && prob(50))
						src.growth++
						drink_rate /= 2
						// If our plant has a slow metabolism, it will only gain growth 50% of
						// the time compared to usual. It consumes reagents a lot slower though.
						// This is essentially like putting the plant on slow-mo overall.
					else
						src.growth += growth_rate
						// If not, it grows 2 points per tick - the regular rate. Remember, the
						// tick rate is halved so 1 point would mean plants take AGES to grow.
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/metabolism_fast))
						drink_rate *= 2
						src.growth += growth_rate
						// The "growth rate on crack" mutation. Also causes it to take up
						// reagents a lot faster - it's like hitting fast forward for plants.
			else
				// If there's no water in the plant pot, we slowly damage the plant and prevent
				// it from gaining any growth if it's not a weed.
				if(!growing.nothirst)
					HYPdamageplant("drought",1)
				else
					src.growth++

			// Now we look through every reagent currently in the plantpot and call the reagent's
			// on_plant_life proc. These are defined in the chemistry reagents file on each reagent
			// for the sake of efficiency.
			if(src.reagents) //Wire: Fix for: Cannot read null.reagent_list
				for(var/current_id in src.reagents.reagent_list)
					var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
					if(current_reagent)
						current_reagent.on_plant_life(src)

			if(DNA.commuts)
				for (var/datum/plant_gene_strain/X in DNA.commuts)
					X.on_process(src)

		src.reagents?.remove_any_except(drink_rate, "nectar")
		// This is where drink_rate does its thing. It will remove a bit of all reagents to meet
		// it's quota, except nectar because that's supposed to stay in the plant pot.

		//We give off nectar and should check our nectar levels
		if(growing.nectarlevel)
			var/current_level = src.reagents.get_reagent_amount("nectar")
			if(current_level < growing.nectarlevel)
				src.reagents.add_reagent("nectar", rand(growing.nectarlevel * 0.2, growing.nectarlevel * 0.5) )
		// This keeps the nectar at the amount specified in the plant's datum.

		// Special procs now live in the plant datums file! These are for plants that will
		// occasionally do special stuff on occasion, such as radweeds, lashers, and the like.
		if(growing.special_proc)
			if(plantgenes.mutation)
				// If we've got a mutation, we want to check if the mutation has its own special
				// proc that overrides the regular one.
				var/datum/plantmutation/MUT = plantgenes.mutation
				switch (MUT.special_proc_override)
					if(FALSE)
						// There's no special proc for this mutation, so just use the regular one.
						growing.HYPspecial_proc(src)
					if(TRUE)
						// The mutation overrides the base proc to use its own.
						MUT.HYPspecial_proc_M(src)
					else
						// Any other value means we use BOTH procs.
						growing.HYPspecial_proc(src)
						MUT.HYPspecial_proc_M(src)
			else
				// If there's no mutation we just use the base special proc, obviously!
				growing.HYPspecial_proc(src)

		// Have we lost all health or growth, or used up all available harvests? If so, this plant
		// should now die. Sorry, that's just life! Didn't they teach you the curds and the peas?
		if((src.health < 1 || src.growth < 0) || (growing.harvestable && src.harvests < 1))
			HYPkillplant()
			return

		var/current_growth_level = 0
		// This is entirely for updating the icon. Check how far the plant has grown and update
		// if it's gone a level beyond what the tracking says it is.

		if(src.growth >= growing.harvtime - DNA.harvtime)
			current_growth_level = 4
		else if(src.growth >= growing.growtime - DNA.growtime)
			current_growth_level = 3
		else if(src.growth >= (growing.growtime - DNA.growtime) / 2)
			current_growth_level = 2
		else
			current_growth_level = 1

		var/do_update_icon = FALSE
		if(current_growth_level != src.grow_level)
			src.grow_level = current_growth_level
			do_update_icon = TRUE

		if(!harvest_warning && HYPcheck_if_harvestable())
			src.harvest_warning = 1
			do_update_icon = TRUE
		else if(harvest_warning && !HYPcheck_if_harvestable())
			src.harvest_warning = 0
			do_update_icon = TRUE

		if(!health_warning && src.health <= growing.starthealth / 2)
			src.health_warning = 1
			do_update_icon = TRUE
		else if(health_warning && src.health > growing.starthealth / 2)
			src.health_warning = 0
			do_update_icon = TRUE

		if(do_update_icon)
			UpdateIcon()
			update_name()

		if(!HAS_FLAG(status, NOPOWER))
			use_power(power_usage)

	attackby(obj/item/W, mob/user)
		if(src.current)
			// Inside this if block we'll handle reactions for specific kinds of plant.
			// General reactions from the plantpot itself come after these.
			if(istype(src.current,/datum/plant/maneater))
				// We want to be able to feed stuff to maneaters, such as meat, people, etc.
				if(istype(W, /obj/item/grab) && iscarbon(W:affecting) && istype(src.current,/datum/plant/maneater))
					if(src.growth < 60)
						boutput(user, "<span class='alert'>It's not big enough to eat that yet.</span>")
						return
						// It doesn't make much sense to feed a full man to a dinky little plant.
					var/mob/living/carbon/C = W:affecting
					user.visible_message("<span class='alert'>[user] starts to feed [C] to the plant!</span>")
					logTheThing(LOG_COMBAT, user, "attempts to feed [constructTarget(C,"combat")] to a man-eater at [log_loc(src)].") // Some logging would be nice (Convair880).
					message_admins("[key_name(user)] attempts to feed [key_name(C, 1)] ([isdead(C) ? "dead" : "alive"]) to a man-eater at [log_loc(src)].")
					src.add_fingerprint(user)
					if(!(user in src.contributors))
						src.contributors += user
					if(do_after(user, 3 SECONDS)) // Same as the gibber and reclaimer. Was 20 (Convair880).
						if(src && W && W.loc == user && C)
							user.visible_message("<span class='alert'>[src.name] grabs [C] and devours them ravenously!</span>")
							logTheThing(LOG_COMBAT, user, "feeds [constructTarget(C,"combat")] to a man-eater at [log_loc(src)].")
							message_admins("[key_name(user)] feeds [key_name(C, 1)] ([isdead(C) ? "dead" : "alive"]) to a man-eater at [log_loc(src)].")
							if(C.mind)
								C.ghostize()
								qdel(C)
							else
								qdel(C)
							playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
							src.reagents.add_reagent("blood", 120)
							SPAWN(2.5 SECONDS)
								if(src)
									playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
							return
						else
							user.show_text("You were interrupted!", "red")
							return
					else
						user.show_text("You were interrupted!", "red")
						return
				else if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat))
					if(src.growth > 60) boutput(user, "<span class='alert'>It's going to need something more substantial than that now...</span>")
					else
						src.reagents.add_reagent("blood", 5)
						boutput(user, "<span class='alert'>You toss the [W] to the plant.</span>")
						qdel (W)
						if(!(user in src.contributors))
							src.contributors += user
				else if(istype(W, /obj/item/organ/brain) || istype(W, /obj/item/clothing/head/butt))
					src.reagents.add_reagent("blood", 20)
					boutput(user, "<span class='alert'>You toss the [W] to the plant.</span>")
					qdel (W)
					if(!(user in src.contributors))
						src.contributors += user

		// From here on out we handle item reacions of the plantpot itself rather than specific
		// special kinds of plant.

		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			// These allow you to unanchor the plantpots to move them around, or re-anchor them.
			if(src.anchored)
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor.")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				src.anchored = 0
			else
				user.visible_message("<b>[user]</b> secures the [src] to the floor.")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				src.anchored = 1

		else if(isweldingtool(W) || istype(W, /obj/item/device/light/zippo) || istype(W, /obj/item/device/igniter))
			// These are for burning down plants with.
			if(isweldingtool(W) && !W:try_weld(user, 3, noisy = 0, burn_eyes = 1))
				return
			else if(istype(W, /obj/item/device/light/zippo) && !W:on)
				boutput(user, "<span class='alert'>It would help if you lit it first, dumbass!</span>")
				return
			if(src.current)
				var/datum/plant/growing = src.current
				if(growing.attacked_proc)
					// It will fight back if possible, and halts the attack if it returns
					// anything other than zero from the attack proc.
					if(plantgenes.mutation)
						// If we've got a mutation, we want to check if the mutation has its own special
						// proc that overrides the regular one.
						var/datum/plantmutation/MUT = plantgenes.mutation
						switch (MUT.attacked_proc_override)
							if(0)
								// There's no attacked proc for this mutation, so just use the regular one.
								if(growing.HYPattacked_proc(src,user,W)) return
							if(1)
								// The mutation overrides the base proc to use its own.
								if(MUT.HYPattacked_proc_M(src,user,W)) return
							else
								// Any other value means we use BOTH procs.
								if(growing.HYPattacked_proc(src,user,W) || MUT.HYPattacked_proc_M(src,user,W)) return
					else
						if(growing.HYPattacked_proc(src,user,W)) return

				if(src.dead)
					src.visible_message("<span class='alert'>[src] goes up in flames!</span>")
					src.reagents.add_reagent("ash", src.growth)
					HYPdestroyplant()
					// Ashes in the plantpot I guess.
				else
					if(!HYPdamageplant("fire",150)) src.visible_message("<span class='alert'>[src] resists the fire!</span>")

		else if(istype(W,/obj/item/saw))
			// Allows you to cut down plants. Never really saw the point in chainsaws considering
			// I already had burn procs in, but whatever.
			if(src.current)
				var/datum/plant/growing = src.current
				if(growing.attacked_proc)
					// It will fight back if possible, and halts the attack if it returns
					// anything other than zero from the attack proc.
					if(plantgenes.mutation)
						// If we've got a mutation, we want to check if the mutation has its own special
						// proc that overrides the regular one.
						var/datum/plantmutation/MUT = plantgenes.mutation
						switch (MUT.attacked_proc_override)
							if(0)
								// There's no attacked proc for this mutation, so just use the regular one.
								if(growing.HYPattacked_proc(src,user,W)) return
							if(1)
								// The mutation overrides the base proc to use its own.
								if(MUT.HYPattacked_proc_M(src,user,W)) return
							else
								// Any other value means we use BOTH procs.
								if(growing.HYPattacked_proc(src,user,W) || MUT.HYPattacked_proc_M(src,user,W)) return
					else
						if(growing.HYPattacked_proc(src,user,W)) return

				if(src.dead)
					src.visible_message("<span class='alert'>[src] is is destroyed by [user.name]'s [W]!</span>")
					HYPdestroyplant()
					return
				else
					HYPdamageplant("physical",150,1)
					src.visible_message("<span class='alert'>[user.name] cuts at [src] with [W]!</span>")

		else if(istype(W, /obj/item/seed/))
			// Planting a seed in the tray. This one should be self-explanatory really.
			var/obj/item/seed/SEED = W
			if(src.current)
				boutput(user, "<span class='alert'>Something is already in that tray.</span>")
				return
			user.visible_message("<span class='notice'>[user] plants a seed in the [src].</span>")
			user.u_equip(SEED)
			SEED.set_loc(src)
			if(SEED.planttype)
				src.HYPnewplant(SEED)
				if(SEED && istype(SEED.planttype,/datum/plant/maneater)) // Logging for man-eaters, since they can't be harvested (Convair880).
					logTheThing(LOG_STATION, user, "plants a [SEED.planttype] seed at [log_loc(src)].")
				if(!(user in src.contributors))
					src.contributors += user
			else
				boutput(user, "<span class='alert'>You plant the seed, but nothing happens.</span>")
				qdel(SEED)
			return

		else if(istype(W, /obj/item/seedplanter/))
			var/obj/item/seedplanter/SP = W
			if(src.current)
				boutput(user, "<span class='alert'>Something is already in that tray.</span>")
				return
			if(!SP.selected)
				boutput(user, "<span class='alert'>You need to select something to plant first.</span>")
				return
			user.visible_message("<span class='notice'>[user] plants a seed in the [src].</span>")
			var/obj/item/seed/SEED
			if(SP.selected.unique_seed)
				SEED = new SP.selected.unique_seed
			else
				SEED = new /obj/item/seed
			SEED.generic_seed_setup(SP.selected)
			SEED.set_loc(src)
			if(SEED.planttype)
				src.HYPnewplant(SEED)
				if(SEED && istype(SEED.planttype,/datum/plant/maneater)) // Logging for man-eaters, since they can't be harvested (Convair880).
					logTheThing(LOG_STATION, user, "plants a [SEED.planttype] seed at [log_loc(src)].")
				if(!(user in src.contributors))
					src.contributors += user
			else
				boutput(user, "<span class='alert'>You plant the seed, but nothing happens.</span>")
				qdel(SEED)

		else if(istype(W, /obj/item/reagent_containers/glass/))
			// Not just watering cans - any kind of glass can be used to pour stuff in.
			if(!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")
				return
			else
				user.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if(!(user in src.contributors))
					src.contributors += user
				if(!W.reagents.total_volume) boutput(user, "<span class='alert'><b>[W] is now empty.</b></span>")
				UpdateIcon()
				return


		else if(istype(W, /obj/item/raw_material/shard/plasmacrystal) && !current)
			// Planting a crystal shard simply puts a crystal seed inside the plant pot for
			// a moment, spawns a new plant from it, then deletes both the seed and the shard.
			user.visible_message("<span class='notice'>[user] plants [W] in the tray.</span>")
			var/obj/item/seed/crystal/WS = new /obj/item/seed/crystal
			WS.set_loc(src)
			HYPnewplant(WS)
			qdel(W)
			sleep(0.5 SECONDS)
			qdel(WS)
			if(!(user in src.contributors))
				src.contributors += user

		else if(istype(W, /obj/item/satchel/hydro))
			// Harvesting directly into a satchel.
			if(!src.current)
				boutput(user, "<span class='alert'>There's no plant here to harvest!</span>")
				return
			if(src.dead)
				boutput(user, "<span class='alert'>The plant is dead and cannot be harvested!</span>")
				return
			var/datum/plant/growing = src.current
			if(!growing.harvestable)
				boutput(user, "<span class='alert'>You doubt this plant is going to grow anything worth harvesting...</span>")
				return

			if(HYPcheck_if_harvestable())
				HYPharvesting(user,W)
			else
				boutput(user, "<span class='alert'>The plant isn't ready to be harvested yet!</span>")
				return

		else ..()

	attack_ai(mob/user as mob)
		if(isrobot(user) && BOUNDS_DIST(src, user) == 0) return src.Attackhand(user)

	attack_hand(var/mob/user)
		if(isAI(user) || isobserver(user)) return // naughty AIs used to be able to harvest plants
		src.add_fingerprint(user)
		if(src.current)
			var/datum/plant/growing = src.current
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantmutation/MUT = DNA.mutation

			if(src.dead)
				boutput(user, "<span class='notice'>You clear the dead plant out of the tray.</span>")
				HYPdestroyplant()
				return

			if(HYPcheck_if_harvestable())
				HYPharvesting(user,null)

				// If the plant is ready for harvest, do that. Otherwise, check it's condition.
			else
				boutput(user, "You check [src.name] and the tray.")

				if(src.recently_harvested) boutput(user, "This plant has been harvested recently. It needs some time to regenerate.")
				if(!src.reagents.has_reagent("water")) boutput(user, "<span class='alert'>The tray is completely dry.</span>")
				else
					if(src.reagents.get_reagent_amount("water") > 200)  boutput(user, "<span class='alert'>The tray has too much water.</span>")
					if(src.reagents.get_reagent_amount("water") < 40) boutput(user, "<span class='alert'>The tray's water level looks a little low.</span>")
				if(src.health >= growing.starthealth * 4) boutput(user, "<span class='notice'>The plant is flourishing!</span>")
				else if(src.health >= growing.starthealth * 2) boutput(user, "<span class='notice'>The plant looks very healthy.</span>")
				else if(src.health <= growing.starthealth / 2) boutput(user, "<span class='alert'>The plant is in poor condition.</span>")
				if(MUT) boutput(user, "<span class='alert'>The plant looks strange...</span>")

				var/reag_list = ""
				for(var/current_id in src.reagents.reagent_list)
					var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
					reag_list += "[reag_list ? ", " : " "][current_reagent.name]"

				boutput(user, "There is a total of [src.reagents.total_volume] units of solution.")
				boutput(user, "The solution seems to contain [reag_list].")
		else
		// If there's no plant, just check what reagents are in there.
			boutput(user, "You check the solution in [src.name].")
			var/reag_list = ""
			for(var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				reag_list += "[reag_list ? ", " : " "][current_reagent.name]"

			boutput(user, "There is a total of [src.reagents.total_volume] units of solution.")
			boutput(user, "The solution seems to contain [reag_list].")
		return

	mouse_drop(over_object, src_location, over_location)
		..()
		if(!isliving(usr) || isintangible(usr)) return // ghosts killing plants fix
		if(BOUNDS_DIST(src, usr) > 0)
			boutput(usr, "<span class='alert'>You need to be closer to empty the tray out!</span>")
			return

		if(src.current)
			var/datum/plant/growing = src.current
			if(growing.attacked_proc)
				// It will fight back if possible, and halts the attack if it returns
				// anything other than zero from the attack proc.
				if(plantgenes.mutation)
					// If we've got a mutation, we want to check if the mutation has its own special
					// proc that overrides the regular one.
					var/datum/plantmutation/MUT = plantgenes.mutation
					switch (MUT.attacked_proc_override)
						if(0)
							// There's no attacked proc for this mutation, so just use the regular one.
							if(growing.HYPattacked_proc(src,usr,null)) return
						if(1)
							// The mutation overrides the base proc to use its own.
							if(MUT.HYPattacked_proc_M(src,usr,null)) return
						else
							// Any other value means we use BOTH procs.
							if(growing.HYPattacked_proc(src,usr,null) || MUT.HYPattacked_proc_M(src,usr,null)) return
				else
					if(growing.HYPattacked_proc(src,usr,null)) return

			if(growing.growthmode == "weed")
				if(tgui_alert(usr, "Clear this tray?", "Clear tray", list("Yes", "No")) == "Yes")
					if(!QDELETED(src))
						usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
						boutput(usr, "<span class='alert'>Weeds still infest the tray. You'll need something a bit more thorough to get rid of them.</span>")
						src.growth = 0
						src.reagents.clear_reagents()
						// The idea here is you gotta use weedkiller or something else to get rid of the
						// weeds since you can't just clear them out by hand.
			else
				if(tgui_alert(usr, "Clear this tray?", "Clear tray", list("Yes", "No")) == "Yes")
					if(!QDELETED(current) && !QDELETED(src))
						usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
						src.reagents.clear_reagents()
						logTheThing(LOG_COMBAT, usr, "cleared a hydroponics tray containing [current.name] at [log_loc(src)]")
						HYPdestroyplant()
		else
			if(tgui_alert(usr, "Clear this tray?", "Clear tray", list("Yes", "No")) == "Yes")
				if(!QDELETED(src))
					usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
					logTheThing(LOG_STATION, usr, "cleared a hydroponics tray containing [current.name] at [log_loc(src)]")
					src.reagents.clear_reagents()
					UpdateIcon()
					update_name()

	MouseDrop_T(atom/over_object as obj, mob/user as mob) // ty to Razage for the initial code
		if(BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, over_object) > 0 || is_incapacitated(user) || isAI(user))
			return
		if(istype(over_object, /obj/item/seed))  // Checks to make sure it's a seed being dragged onto the tray.
			if(BOUNDS_DIST(user, src) > 0)
				boutput(user, "<span class='alert'>You need to be closer to the tray!</span>")
				return
			if(BOUNDS_DIST(user, over_object) > 0)
				boutput(user, "<span class='alert'>[over_object] is too far away!</span>")
				return
			src.Attackby(over_object, user)  // Activates the same command as would be used with a seed in hand on the tray.
			return
		else // if it's not a seed...
			return ..() // call our parents and ask what to do.

	temperature_expose(null, temp, volume)
		if(reagents) reagents.temperature_reagents(temp, volume)
		if(temp >= 360)
			if(src.current)
				if(src.dead)
					src.reagents.add_reagent("saltpetre", src.growth)
					HYPdestroyplant()
				else HYPdamageplant("fire",temp - 360)

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN))
			return

		if(!signal || signal.encryption)
			return

		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			var/datum/signal/pingsignal = get_free_signal()
			pingsignal.source = src
			pingsignal.data["device"] = "WNET_[pick("GENERIC", "PACKETSPY", "DETECTOR", "SYN%%^#FF")]" //Todo: Set this as something appropriate when complete.
			pingsignal.data["netid"] = src.net_id
			pingsignal.data["address_1"] = signal.data["sender"]
			pingsignal.data["command"] = "ping_reply"

			SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal)

		return //Just toss out the rest of the signal then I guess

	// Procs specific to the plantpot start here.

	proc/update_water_icon()
		var/datum/color/average
		src.water_sprite = image('icons/obj/hydroponics/machines_hydroponics.dmi',"wat-[src.total_volume]")
		src.water_sprite.layer = 3
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
		if(src.reagents.total_volume)
			average = src.reagents.get_average_color()
			src.water_sprite.color = average.to_rgba()

		UpdateOverlays(src.water_sprite, "water_fluid")
		UpdateOverlays(src.water_meter, "water_meter")

	update_icon() //plant icon stuffs
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
		UpdateOverlays(water_meter, "water_meter")
		if(!src.current)
			UpdateOverlays(null, "harvest_display")
			UpdateOverlays(null, "health_display")
			UpdateOverlays(null, "plant")
			UpdateOverlays(null, "plantdeath")
			if(status & (NOPOWER|BROKEN))
				UpdateOverlays(null, "water_meter")
			return

		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantmutation/MUT = DNA.mutation

		var/iconname = 'icons/obj/hydroponics/plants_weed.dmi'
		if(growing.plant_icon)
			iconname = growing.plant_icon
		else if(MUT?.iconmod)
			if(MUT.plant_icon)
				iconname = MUT.plant_icon
			else
				iconname = growing.plant_icon

		if(src.dead)
			UpdateOverlays(hydro_controls.pot_death_display, "plantdeath")
			UpdateOverlays(null, "harvest_display")
			UpdateOverlays(null, "health_display")
		else
			UpdateOverlays(null, "plantdeath")
			if(src.harvest_warning)
				UpdateOverlays(hydro_controls.pot_harvest_display, "harvest_display")
			else
				UpdateOverlays(null, "harvest_display")

			if(src.health_warning)
				UpdateOverlays(hydro_controls.pot_health_display, "health_display")
			else
				UpdateOverlays(null, "health_display")

		var/planticon = growing.getIconState(src.grow_level, MUT)

		src.plant_sprite.icon = iconname
		src.plant_sprite.icon_state = planticon
		src.plant_sprite.layer = 4
		UpdateOverlays(plant_sprite, "plant")

		if(status & (NOPOWER|BROKEN))
			UpdateOverlays(null, "water_meter")
			UpdateOverlays(null, "harvest_display")
			UpdateOverlays(null, "health_display")
			UpdateOverlays(null, "plantdeath")

	proc/update_name()
		if(!src.current)
			src.name = "hydroponics tray"
			return
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantmutation/MUT = DNA.mutation
		if(growing?.cantscan) // what if we disable this for a bit, what will happen...
			src.name = "\improper strange plant"
		else
			if(istype(MUT,/datum/plantmutation/))
				if(!MUT.name_prefix && !MUT.name_prefix && MUT.name)
					src.name = "\improper [MUT.name] plant"
				else if(MUT.name_prefix || MUT.name_suffix)
					src.name = "\improper [MUT.name_prefix][growing.name][MUT.name_suffix] plant"
			else
				src.name = "\improper [growing.name] plant" //TODO: add optional suffix eg. "tree"
		if(src.dead)
			src.name = "dead " + src.name

	proc/HYPcheck_if_harvestable()
		// Pretty much figure out if we can harvest the plant yet or not. This is used for
		// updating the sprite and obviously handling harvesting when a player clicks
		// on the plant pot.
		if(!current || !plantgenes || health < 1 || harvests < 1 || recently_harvested) return FALSE
		if(plantgenes.mutation)
			var/datum/plantmutation/MUT = plantgenes.mutation
			if(MUT.harvest_override && MUT.crop)
				if(src.growth >= current.harvtime - plantgenes.harvtime) return TRUE
				else return FALSE
		if(!current.crop || !current.harvestable) return FALSE

		if(src.growth >= current.harvtime - plantgenes.harvtime) return TRUE
		else return FALSE

	proc/HYPharvesting(var/mob/living/user,var/obj/item/satchel/SA)
		// This proc is where the harvesting actually happens. Again it shouldn't need tweaking
		// with since i've tried to account for most special circumstances that might come up.
		if(!user) return
		var/satchelpick = 0
		if(SA)
			if(SA.contents.len >= SA.maxitems)
				boutput(user, "<span class='alert'>Your satchel is already full! Free some space up first.</span>")
				return
			else
				satchelpick = input(user, "What do you want to harvest into the satchel?", "[src.name]", 0) in list("Everything","Produce Only","Seeds Only","Never Mind")
				if(!HYPcheck_if_harvestable() || satchelpick == "Never Mind")
					return
				if(satchelpick == "Everything")
					satchelpick = null
		// it's okay if we don't have a satchel at all since it'll just harvest by hand instead
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantmutation/MUT = DNA.mutation
		if(!growing)
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controls</b>: Plant pot at \[[x],[y],[z]] used by ([user]) attempted a harvest without having a current plant.")
			return

		if(growing.harvested_proc)
			if(growing.HYPharvested_proc(src,user)) return
			if(MUT?.HYPharvested_proc_M(src,user)) return
			// Does this plant react to being harvested? If so, do it - it also functions as
			// a check since harvesting will stop here if this returns anything other than 0.

		if(hydro_controls)
			src.recently_harvested = 1
			src.harvest_warning = 0
			SPAWN(hydro_controls.delay_between_harvests)
				src.recently_harvested = 0
		else
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controls</b>: Could not access Hydroponics Controller to get Delay cap.")

		var/base_quality_score = 1
		// This is a modular thing suggested by Cogwerks that can affect the final quality
		// of produce such as making fruit make you sick or herbs have less reagents.

		var/harvest_cap = 10
		if(hydro_controls)
			harvest_cap = hydro_controls.max_harvest_cap
		else
			logTheThing(LOG_DEBUG, null, "<b>Hydro Controls</b>: Could not access Hydroponics Controller to get Harvest cap.")

		src.growth = max(0, growing.growtime - DNA.growtime)
		// Reset the growth back to the beginning of maturation so we can wait out the
		// harvest time again.
		var/getamount = growing.cropsize + DNA.cropsize
		if(src.health >= growing.starthealth * 2 && prob(30))
			boutput(user, "<span class='notice'>This looks like a good harvest!</span>")
			base_quality_score += 5
			var/bonus = rand(1,3)
			getamount += bonus
			harvest_cap += bonus
			// Good health levels bump the harvest amount up a bit and increase jumbo chances.
		if(src.health >= growing.starthealth * 4 && prob(30))
			boutput(user, "<span class='notice'>It's a bumper crop!</span>")
			base_quality_score += 10
			var/bonus = rand(2,5)
			getamount += bonus
			harvest_cap += bonus
			// This is if the plant health is absolutely excellent.
		if(src.health <= growing.starthealth / 2 && prob(70))
			boutput(user, "<span class='alert'>This is kind of a crappy harvest...</span>")
			base_quality_score -= 12
			// And this is if you've neglected the plant!

		var/getitem = null
		var/dont_rename_crop = false
		// Figure out what crop we use - the base crop or a mutation crop.
		if(growing.crop || MUT?.crop)
			if(MUT)
				if(MUT.crop)
					getitem = MUT.crop
					dont_rename_crop = MUT.dont_rename_crop
				else
					logTheThing(LOG_DEBUG, null, "<b>I Said No/Hydroponics:</b> Plant mutation [MUT] crop is not properly configured")
					getitem = growing.crop
			else
				getitem = growing.crop
				dont_rename_crop = growing.dont_rename_crop

		if(DNA.commuts)
			for(var/datum/plant_gene_strain/G in DNA.commuts)
				// And ones that mess with the quality of crops.
				// Unstable isn't here because it'd be less random outside the loop.
				if (istype(G, /datum/plant_gene_strain/quality))
					var/datum/plant_gene_strain/quality/Q = G
					if(Q.negative)
						base_quality_score -= Q.quality_mod
					else
						base_quality_score += Q.quality_mod
				// Gene strains that boost or penalize the cap.
				else if (istype(G, /datum/plant_gene_strain/yield))
					var/datum/plant_gene_strain/yield/Y = G
					if(Y.negative)
						if(harvest_cap == 0 || Y.yield_mult == 0)
							continue
						else
							harvest_cap /= Y.yield_mult
							harvest_cap -= Y.yield_mod
					else
						harvest_cap *= Y.yield_mult
						harvest_cap += Y.yield_mod

		var/extra_harvest_chance = 0

		if(getamount > harvest_cap)
			extra_harvest_chance += getamount - harvest_cap
			getamount = harvest_cap
			// Max harvest amount for all plants is capped. If we've got higher output
			// than the cap it's probably through gene manipulation, so reward the player
			// with greater chances for an extra harvest if this is the case.
			// The cap is defined in hydro_controls and can be edited by coders on the fly.

		getamount = round(max(getamount, 0))

		if(getamount < 1)
			boutput(user, "<span class='alert'>You aren't able to harvest anything worth salvaging.</span>")
			// We just don't bother if the output is below one.
		else if(!getitem)
			boutput(user, "<span class='alert'>You can't seem to find anything that looks harvestable.</span>")
			// mostly a fix for a runtime error if getitem was null
		else
			var/cropcount = getamount
			var/seedcount = 0

			for (var/_ in 1 to getamount)
				var/quality_score = base_quality_score
				quality_score += rand(-2,2)
				// Just a bit of natural variance to make it interesting
				if(DNA.potency)
					quality_score += round(DNA.potency / 6)
				if(DNA.endurance)
					quality_score += round(DNA.endurance / 6)
				if(HYPCheckCommut(DNA,/datum/plant_gene_strain/unstable))
					quality_score += rand(-7,7)
				var/quality_status = null

				// Marquesas: I thought of everything and couldn't find another way, but we need this for synthlimbs.
				// Okay, I meanwhile realized there might be another way but this looks cleaner. IMHO.
				var/itemtype = null
				if(istype(getitem, /list))
					itemtype = pick(getitem)
				else
					itemtype = getitem

				// Start up the loop of grabbing all our produce. Remember, each iteration of
				// this loop is for one item each.
				var/obj/CROP = new itemtype
				CROP.set_loc(src)
				// I bet this will go real well.
				if(!dont_rename_crop)
					CROP.name = growing.name
				/*
				if(istype(MUT,/datum/plantmutation/))
					if(!MUT.name_prefix && !MUT.name_prefix && MUT.name)
						CROP.name = "[MUT.name]"
					else if(MUT.name_prefix || MUT.name_suffix)
						CROP.name = "[MUT.name_prefix][growing.name][MUT.name_suffix]"
				*/
				if(istype(CROP, /obj/item/plant/))
					var/obj/item/plant/PLANT = CROP
					CROP.name = "[PLANT.crop_prefix][CROP.name][PLANT.crop_suffix]"

				else if(istype(CROP, /obj/item/reagent_containers/food/snacks/plant))
					var/obj/item/reagent_containers/food/snacks/plant/SNACK = CROP
					CROP.name = "[SNACK.crop_prefix][CROP.name][SNACK.crop_suffix]"

				CROP.name = lowertext(CROP.name)

				switch(quality_score)
					if(25 to INFINITY)
						// as quality approaches 115, rate of getting jumbo increases
						if(prob(min(100, quality_score - 15)))
							CROP.name = "jumbo [CROP.name]"
							quality_status = "jumbo"
						else
							CROP.name = "[pick("perfect","amazing","incredible","supreme")] [CROP.name]"
					if(20 to 24)
						if(prob(4))
							CROP.name = "jumbo [CROP.name]"
							quality_status = "jumbo"
						else
							CROP.name = "[pick("superior","excellent","exceptional","wonderful")] [CROP.name]"
					if(15 to 19)
						CROP.name = "[pick("quality","prime","grand","great")] [CROP.name]"
					if(10 to 14)
						CROP.name = "[pick("fine","large","good","nice")] [CROP.name]"
					if(-10 to -5)
						CROP.name = "[pick("feeble","poor","small","shrivelled")] [CROP.name]"
					if(-14 to -11)
						CROP.name = "[pick("bad","sickly","terrible","awful")] [CROP.name]"
						quality_status = "rotten"
					if(-99 to -15)
						CROP.name = "[pick("putrid","moldy","rotten","spoiled")] [CROP.name]"
						quality_status = "rotten"
					if(-9999 to -100)
						// this will never happen. but why not!
						CROP.name = "[pick("horrific","hideous","disgusting","abominable")] [CROP.name]"
						quality_status = "rotten"

				switch(quality_status)
					if("jumbo")
						CROP.quality = quality_score * 2
					if("rotten")
						CROP.quality = quality_score - 20
					else
						CROP.quality = quality_score

				if(!growing.stop_size_scaling) //Keeps plant sprite from scaling if variable is enabled.
					CROP.transform = matrix() * clamp((quality_score + 100) / 100, 0.35, 2)

				if(istype(CROP,/obj/item/reagent_containers/food/snacks/plant/))
					// If we've got a piece of fruit or veg that contains seeds. More often than
					// not this is fruit but some veg do this too.
					var/obj/item/reagent_containers/food/snacks/plant/F = CROP
					var/datum/plantgenes/FDNA = F.plantgenes

					HYPpassplantgenes(DNA,FDNA)
					F.generation = src.generation
					// Copy the genes from the plant we're harvesting to the new piece of produce.

					if(growing.hybrid)
						// We need to do special shit with the genes if the plant is a spliced
						// hybrid since they run off instanced datums rather than referencing
						// a specific already-existing one.
						var/plantType = growing.type
						var/datum/plant/hybrid = new plantType(F)
						for(var/V in growing.vars)
							if(issaved(growing.vars[V]) && V != "holder")
								hybrid.vars[V] = growing.vars[V]
						F.planttype = hybrid

					// Now we calculate the final quality of the item!
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/unstable) && prob(33))
						// The unstable gene can do weird shit to your produce.
						F.name = "[pick("awkward","irregular","crooked","lumpy","misshapen","abnormal","malformed")] [F.name]"
						F.heal_amt += rand(-2,2)
						F.bites_left += rand(-2,2)

					if(quality_status == "jumbo")
						F.heal_amt *= 2
						F.bites_left *= 2
					else if(quality_status == "rotten")
						F.heal_amt = 0

					HYPadd_harvest_reagents(F,growing,DNA,quality_status)
					// We also want to put any reagents the plant produces into the new item.

				else if(istype(CROP,/obj/item/plant/) || istype(CROP,/obj/item/reagent_containers))
					// If we've got a herb or some other thing like wheat or shit like that.
					HYPadd_harvest_reagents(CROP,growing,DNA,quality_status)

				else if(istype(CROP,/obj/item/seed/))
					// If the crop is just straight up seeds. Don't need reagents, but we do
					// need to pass genes and whatnot along like we did for fruit.
					var/obj/item/seed/S = CROP
					if(growing.unique_seed)
						S = new growing.unique_seed
						S.set_loc(src)
					else
						S = new /obj/item/seed
						S.set_loc(src)
						S.removecolor()

					var/datum/plantgenes/HDNA = src.plantgenes
					var/datum/plantgenes/SDNA = S.plantgenes
					if(!growing.unique_seed && !growing.hybrid)
						S.generic_seed_setup(growing)
					HYPpassplantgenes(HDNA,SDNA)
					S.generation = src.generation
					if(growing.hybrid)
						var/datum/plant/hybrid = new /datum/plant(S)
						for(var/V in growing.vars)
							if(issaved(growing.vars[V]) && V != "holder")
								hybrid.vars[V] = growing.vars[V]
						S.planttype = hybrid

				else if(istype(CROP,/obj/item/reagent_containers/food/snacks/mushroom/))
					// Mushrooms mostly act the same as herbs, except you can eat them.
					var/obj/item/reagent_containers/food/snacks/mushroom/M = CROP

					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/unstable) && prob(33))
						M.name = "[pick("awkward","irregular","crooked","lumpy","misshapen","abnormal","malformed")] [M.name]"
						M.heal_amt += rand(-2,2)
						M.bites_left += rand(-2,2)

					if(quality_status == "jumbo")
						M.heal_amt *= 2
						M.amount *= 2
					else if(quality_status == "rotten")
						M.heal_amt = 0

					HYPadd_harvest_reagents(CROP,growing,DNA,quality_status)

				else if(istype(CROP,/obj/critter/))
					// If it's a critter we don't need to do reagents or shit like that but
					// we do need to make sure they don't attack the botanist that grew it.
					var/obj/critter/C = CROP
					C.friends = C.friends | src.contributors

				else if (istype(CROP,/obj/item/organ))
					var/obj/item/organ/O = CROP
					if(istype(CROP,/obj/item/organ/heart))
						O.quality = quality_score
					O.max_damage += DNA.endurance
					O.fail_damage += DNA.endurance

				else if(istype(CROP,/obj/item/reagent_containers/balloon))
					var/obj/item/reagent_containers/balloon/B = CROP
					B.reagents.maximum_volume = B.reagents.maximum_volume + DNA.endurance // more endurance = larger and more sturdy balloons!
					HYPadd_harvest_reagents(CROP,growing,DNA,quality_status)

				else if(istype(CROP,/obj/item/spacecash)) // Ugh
					var/obj/item/spacecash/S = CROP
					S.amount = max(1, DNA.potency * rand(2,4))
					S.update_stack_appearance()
				else if (istype(CROP,/obj/item/device/light/glowstick))
					var/type = pick(concrete_typesof(/obj/item/device/light/glowstick/))
					var/obj/item/device/light/glowstick/newstick = new type(CROP.loc)
					newstick.light_c.a = clamp(DNA.potency/60, 0.33, 1) * 255
					newstick.turnon()
					qdel(CROP)
					CROP = newstick
				if(((growing.isgrass || growing.force_seed_on_harvest) && prob(80)) && !istype(CROP,/obj/item/seed/) && !HYPCheckCommut(DNA,/datum/plant_gene_strain/seedless))
					// Same shit again. This isn't so much the crop as it is giving you seeds
					// incase you couldn't get them otherwise, though.
					var/obj/item/seed/S
					if(growing.unique_seed)
						S = new growing.unique_seed
						S.set_loc(src)
					else
						S = new /obj/item/seed
						S.set_loc(src)
						S.removecolor()
					var/datum/plantgenes/HDNA = src.plantgenes
					var/datum/plantgenes/SDNA = S.plantgenes
					if(!growing.unique_seed && !growing.hybrid)
						S.generic_seed_setup(growing)

					var/seedname = "[growing.name]"
					if(istype(MUT,/datum/plantmutation/))
						if(!MUT.name_prefix && !MUT.name_suffix && MUT.name)
							seedname = "[MUT.name]"
						else if(MUT.name_prefix || MUT.name_suffix)
							seedname = "[MUT.name_prefix][growing.name][MUT.name_suffix]"

					S.name = "[seedname] seed"
					S.plant_seed_color(growing.seedcolor)
					HYPpassplantgenes(HDNA,SDNA)
					S.generation = src.generation
					if(growing.hybrid)
						var/plantType = growing.type
						var/datum/plant/hybrid = new plantType(S)
						for(var/V in growing.vars)
							if(issaved(growing.vars[V]) && V != "holder")
								hybrid.vars[V] = growing.vars[V]
						S.planttype = hybrid

					seedcount++

			// Give XP based on base quality of crop harvest. Will make better later, like so more plants harvasted and stuff, this is just for testing.
			// This is only reached if you actually got anything harvested.
			// (tmp_crop here was causing runtimes in a lot of cases, so changing to just use it like this)
			// Base quality score:
			//   1: base
			// -12: if HP <=  50% w/ 70% chance
			// + 5: if HP >= 200% w/ 30% chance
			// +10: if HP >= 400% w/ 30% chance
			// Mutations can add or remove this, of course
			// @TODO adjust this later, this is just to fix runtimes and make it slightly consistent
			if (base_quality_score >= 1 && prob(30))
				if (base_quality_score >= 11)
					JOB_XP(user, "Botanist", 4)
				else if (base_quality_score >= 6)
					JOB_XP(user, "Botanist", 2)
				else
					JOB_XP(user, "Botanist", 1)

			boutput(user, "<span class='notice'>You harvest [cropcount] item[s_es(cropcount)][seedcount ? " and [seedcount] seed[s_es(seedcount)]" : ""].</span>")

			// Mostly for dangerous produce (explosive tomatoes etc) that should show up somewhere in the logs (Convair880).
			if(istype(MUT,/datum/plantmutation/))
				logTheThing(LOG_STATION, user, "harvests [cropcount] items from a [MUT.name] plant ([MUT.type]) at [log_loc(src)].")
			else
				logTheThing(LOG_STATION, user, "harvests [cropcount] items from a [growing.name] plant ([growing.type]) at [log_loc(src)].")

			// At this point all the harvested items are inside the plant pot, and this is the
			// part where we decide where they're going and get them out.
			var/seeds_only = satchelpick == "Seeds Only"
			var/produce_only = satchelpick == "Produce Only"
			if(SA)
				// If we're putting stuff in a satchel, this is where we do it.
				for(var/obj/item/I in src.contents)
					if(SA.contents.len >= SA.maxitems)
						boutput(user, "<span class='alert'>Your satchel is full! You dump the rest on the floor.</span>")
						break
					if(istype(I,/obj/item/seed/))
						if(!satchelpick || seeds_only)
							I.set_loc(SA)
							I.add_fingerprint(user)
					else
						if(!satchelpick || produce_only)
							I.set_loc(SA)
							I.add_fingerprint(user)
				SA.UpdateIcon()

			// if the satchel got filled up this will dump any unharvested items on the floor
			// if we're harvesting by hand it'll just default to this anyway! truly magical~
			for(var/obj/I in src.contents)
				I.set_loc(user.loc)
				I.add_fingerprint(user)

		// Now we determine the harvests remaining or grant extra ones.
		if(!HYPCheckCommut(DNA,/datum/plant_gene_strain/immortal))
			// Immortal is a gene strain that means infinite harvests as long as the plant
			// is kept alive, it's on melons usually.
			if(src.health >= growing.starthealth * 4)
				// If we have excellent health, its a +20% chance for an extra harvest.
				extra_harvest_chance += 20
				extra_harvest_chance = clamp(extra_harvest_chance, 0, 100)
				if(prob(extra_harvest_chance))
					boutput(user, "<span class='notice'>The plant glistens with good health!</span>")
					// We got the bonus so don't reduce harvests.
				else
					// No bonus, harvest is decremented as usual.
					src.harvests--
			else
				src.harvests--
		if(growing.isgrass)
			// Vegetable-style plants always die after one harvest irregardless of harvests
			// remaining, though they do get bonuses for having a good harvests gene.
			HYPkillplant()

		//do we have to run the next life tick manually? maybe
		playsound(src.loc, "rustle", 50, 1, -5, 2)
		UpdateIcon()
		update_name()

	proc/HYPmutateplant(var/severity = 1)
		// This proc is for mutating the plant - gene strains, mutant variants and plain old
		// genetic bonuses and penalties are handled here.
		if(severity < 1 || !severity)
			severity = 1
			// Severity is basically a multiplier to odds and amounts.
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		if(!istype(growing) || !istype(DNA))
			return

		HYPmutateDNA(DNA,severity)
		HYPnewcommutcheck(growing,DNA)
		HYPnewmutationcheck(growing,DNA,src)

	proc/HYPnewplant(var/obj/item/seed/SEED)
		// This proc is triggered on the plantpot when we want to grow a new plant. Usually by
		// planting a seed - even weed growth briefly spawns a seed, uses it for this proc, then
		// deletes the seed.
		src.current = SEED.planttype
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantgenes/SDNA = SEED.plantgenes

		src.health = growing.starthealth

		// Now we deal with various health bonuses and penalties for the plant.

		if(growing.isgrass)
			src.health += src.plantgenes.harvests * 2
			// If we have a single-harvest vegetable plant, the harvests gene (which is otherwise
			// useless) adds 2 health for every point. This works negatively also!

		if(growing.cropsize + SDNA.cropsize > 30)
			src.health += (growing.cropsize + SDNA.cropsize) - 30
			// If we have a total crop yield above the maximum harvest size, we add it to the
			// plant's starting health.

		src.health += SEED.planttype.endurance + SDNA.endurance
		// Add the plant's total endurance score to the health.

		if(SEED.seeddamage > 0)
			src.health -= round(SEED.seeddamage / 5)
			// If the seed was damaged by infusions, knock off 5 health points for each point
			// of damage to the seed.

		if(src.health < 1)
			src.health = 1
			// And finally, if health has fallen below zero we put it back to 1 so the plant
			// doesn't instantly die. It still will if conditions in the pot aren't good though.

		src.generation = SEED.generation + 1
		DNA.growtime = SDNA.growtime
		DNA.harvtime = SDNA.harvtime
		DNA.cropsize = SDNA.cropsize
		DNA.harvests = SDNA.harvests
		DNA.potency = SDNA.potency
		DNA.endurance = SDNA.endurance
		// we use the same list as the seed here, as new lists are created only on mutation to avoid making way more lists than we need
		DNA.commuts = SDNA.commuts
		if(SDNA.mutation)
			DNA.mutation = HY_get_mutation_from_path(SDNA.mutation.type)
		// Copy over all genes, strains and mutations from the seed.

		// Finally set the harvests, make sure we always have at least one harvest,
		// then get rid of the seed, mutate the genes a little and update the pot sprite.
		if(growing.harvestable) src.harvests = growing.harvests + DNA.harvests
		if(src.harvests < 1) src.harvests = 1
		qdel(SEED)

		HYPmutateplant(1)
		post_alert("event_new")
		src.recently_harvested = 0
		UpdateIcon()
		update_name()
		growth_rate = 2

	proc/HYPkillplant()
		// Simple proc to kill the plant without clearing the plantpot out altogether.
		src.health = 0
		src.harvests = 0
		src.dead = 1
		src.recently_harvested = 0
		src.grow_level = 0
		post_alert("event_death")
		src.health_warning = 0
		src.harvest_warning = 0
		UpdateIcon()
		update_name()

	proc/HYPdestroyplant()
		// This resets the plantpot back to it's base state, apart from reagents.
		src.name = "hydroponics tray"
		src.current = null
		src.growth = 0
		src.grow_level = 1
		src.dead = 0
		src.harvests = 0
		src.recently_harvested = 0
		src.health_warning = 0
		src.harvest_warning = 0
		src.contributors = list()
		var/datum/plantgenes/DNA = src.plantgenes

		DNA.growtime = 0
		DNA.harvtime = 0
		DNA.cropsize = 0
		DNA.harvests = 0
		DNA.potency = 0
		DNA.endurance = 0
		DNA.commuts = null
		DNA.mutation = null

		src.generation = 0
		UpdateIcon()
		update_name()
		post_alert("event_cleared")

	proc/HYPdamageplant(var/damage_source, var/damage_amount, var/bypass_resistance = 0)
		// The proc to use for causing health damage to plants. You can just directly alter
		// the health var without much of an issue, but that would ignore resistances and
		// other stuff like that.
		if(!damage_source || damage_amount < 1 || !damage_amount) return 0
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		if(!growing || !DNA) return 0
		var/damage_prob = 100

		if(!bypass_resistance)
			switch(damage_source)
				if("poison")
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/immunity_toxin)) return 0
				if("radiation")
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/immunity_radiation)) return 0
				if("drought")
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/resistance_drought) && damage_prob > 0) damage_prob /= 2
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/metabolism_fast)) damage_amount *= 2
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/metabolism_slow) && damage_amount > 0) damage_amount /= 2
			// Various gene strains will eliminate or reduce damage from various sources.
			// In some cases damage is increased, like a fast metabolism plant dying faster
			// from lack of water.

			if(DNA.commuts)
				for (var/datum/plant_gene_strain/damage_res/D in DNA.commuts)
					if(D.negative)
						damage_amount += D.damage_mod
						damage_amount *= D.damage_mult
					else
						damage_amount -= D.damage_mod
						if(damage_amount && D.damage_mult)
							damage_amount /= D.damage_mult

			damage_prob -= growing.endurance + DNA.endurance
			if(damage_prob < 1) return 0
			if(damage_prob > 100) damage_prob = 100

		if(growing.endurance + DNA.endurance < 0) damage_amount -= growing.endurance + DNA.endurance
		if(prob(damage_prob))
			src.health -= damage_amount
			return 1
		else return 0

// Hydroponics procs not specific to the plantpot start here.

proc/HYPadd_harvest_reagents(var/obj/item/I,var/datum/plant/growing,var/datum/plantgenes/DNA,var/special_condition = null)
	// This is called during harvest to add reagents from the plant to a new piece of produce.
	if(!I || !DNA || !I.reagents) return

	var/datum/plantmutation/MUT = DNA.mutation

	var/basecapacity = 8
	if(istype(I,/obj/item/plant/)) basecapacity = 15
	else if(istype(I,/obj/item/reagent_containers/food/snacks/mushroom)) basecapacity = 5
	else if(istype(I,/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)) basecapacity = 2 //I foresee a growing if tree here, should probably break these values out.
	// First we decide how much reagents to begin with certain items should hold.

	if(DNA.commuts)
		for (var/datum/plant_gene_strain/quality/Q in DNA.commuts)
			if(Q.negative)
				if(basecapacity && Q.quality_mult)
					basecapacity /= Q.quality_mult
			else
				basecapacity *= Q.quality_mult

	if(special_condition == "jumbo")
		basecapacity *= 2

	var/to_add = basecapacity + DNA.potency
	I.reagents.maximum_volume = max(basecapacity + DNA.potency, I.reagents.maximum_volume)
	if(I.reagents.maximum_volume < 1)
		I.reagents.maximum_volume = 1
	// Now we add the plant's potency to their max reagent capacity. If this causes it to fall
	// below one, we allow them at least that much because otherwise what's the damn point!!!

	var/list/putreagents = list()
	putreagents = growing.assoc_reagents
	if(MUT)
		putreagents = putreagents | MUT.assoc_reagents
	// Build the list of all what reagents need to go into the new item.

	if(special_condition == "rotten")
		putreagents += "yuck"

	if(DNA.commuts)
		for (var/datum/plant_gene_strain/reagent_adder/R in DNA.commuts)
			putreagents |= R.reagents_to_add

	if(putreagents.len && I.reagents.maximum_volume)
		var/putamount = round(to_add / putreagents.len)
		for(var/X in putreagents)
			I?.reagents?.add_reagent(X,putamount,,, 1) // ?. runtime fix
	// And finally put them in there. We figure out the max volume and add an even amount of
	// all reagents into the item.

proc/HYPpassplantgenes(var/datum/plantgenes/PARENT,var/datum/plantgenes/CHILD)
	// This is a proc used to copy genes from PARENT to CHILD. It's used in a whole bunch
	// of places, usually when seeds or fruit are created and need to get their genes from
	// the thing that spawned them.
	var/datum/plantmutation/MUT = PARENT.mutation
	CHILD.growtime = PARENT.growtime
	CHILD.harvtime = PARENT.harvtime
	CHILD.harvests = PARENT.harvests
	CHILD.cropsize = PARENT.cropsize
	CHILD.potency = PARENT.potency
	CHILD.endurance = PARENT.endurance
	// using the same list as the parent as adding new items is what creates a new list
	CHILD.commuts = PARENT.commuts
	if(MUT) CHILD.mutation = new MUT.type(CHILD)

proc/HYPgeneticanalysis(var/mob/user as mob,var/obj/scanned,var/datum/plant/P,var/datum/plantgenes/DNA)
	// This is the proc plant analyzers use to pop up their readout for the player.
	// Should be mostly self-explanatory to read through.
	//
	// I made some tweaks here for calls in the global scan_plant() proc (Convair880).
	if(!user || !DNA) return

	var/datum/plantmutation/MUT = DNA.mutation
	var/generation = 0

	if(P.cantscan)
		boutput(user, "<span class='alert'><B>ERROR:</B> Genetic structure not recognized. Cannot scan.</span>")
		return

	if(istype(scanned, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = scanned
		generation = PP.generation
	if(istype(scanned, /obj/item/seed/))
		var/obj/item/seed/S = scanned
		generation = S.generation
	if(istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = scanned
		generation = F.generation

	//would it not be better to put this information in the scanner itself?
	var/message = {"
		<table style='border-collapse: collapse; border: 1px solid black; margin: 0 0.25em; width: 100%;'>
			<caption>Analysis of \the <b>[scanned.name]</b></caption>
			<tr>
				<th style='white-space: nowrap;' width=0>Species</th><td colspan='3'>[P.name] ([DNA.d_species ? "D" : "r"])</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Generation</th><td style='text-align: right; white-space: nowrap;'>[generation]</td><td colspan=2 width=100%>&nbsp;</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Maturation Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.growtime]</td>
				<td width=0 style='text-align: center;'>[DNA.d_growtime ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.growtime), 0, 100)]%; background-color: [DNA.growtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Production Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvtime]</td>
				<td width=0 style='text-align: center;'>[DNA.d_harvtime ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvtime), 0, 100)]%; background-color: [DNA.harvtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Lifespan</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvests]</td>
				<td width=0 style='text-align: center;'>[DNA.d_harvests ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvests), 0, 100)]%; background-color: [DNA.harvests > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Yield</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.cropsize]</td>
				<td width=0 style='text-align: center;'>[DNA.d_cropsize ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.cropsize), 0, 100)]%; background-color: [DNA.cropsize > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Potency</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.potency]</td>
				<td width=0 style='text-align: center;'>[DNA.d_potency ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.potency), 0, 100)]%; background-color: [DNA.potency > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Endurance</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.endurance]</td>
				<td width=0 style='text-align: center;'>[DNA.d_endurance ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.endurance), 0, 100)]%; background-color: [DNA.endurance > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
		</table>
	[MUT ? "<font color='red'>Abnormal genetic patterns detected.</font>" : ""]
	"}

	if(DNA.commuts)
		var/list/gene_strains = list()
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			gene_strains += "[X.name] [X.strain_type]"
		if(gene_strains.len)
			message += "[MUT ? "" : "<br>"]<font color='red'><b>Gene strains detected:</b> [gene_strains.Join(", ")]</font>"

	boutput(user, message)
	return

proc/HYPnewmutationcheck(var/datum/plant/P,var/datum/plantgenes/DNA,var/obj/machinery/plantpot/PP, var/frequencymult = 1, var/obj/item/seed/S = null)
	// The check to see if a new mutation will be generated. The criteria check for whether
	// or not the mutation will actually appear is HYPmutationcheck_full.
	if(!P || !DNA)
		return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer))
		return
	if(P.mutations.len)
		for (var/datum/plantmutation/MUT in P.mutations)
			var/chance = MUT.chance
			if(DNA.commuts)
				for (var/datum/plant_gene_strain/mutations/M in DNA.commuts)
					if(M.negative)
						chance -= M.chance_mod
					else
						chance += M.chance_mod
			chance = clamp(chance*frequencymult, 0, 100)
			if(prob(chance))
				if(HYPmutationcheck_full(P,DNA,MUT))
					DNA.mutation = HY_get_mutation_from_path(MUT.type)
					if(PP)
						playsound(PP, MUT.mutation_sfx, 10, 1)
						PP.UpdateIcon()
						PP.update_name()
						animate_wiggle_then_reset(PP, 1, 2)
					else if(S)
						// If it is not in a pot, it is most likely in PlantMaster Mk3
						playsound(S, MUT.mutation_sfx, 20, 1)
					break

proc/HYPCheckCommut(var/datum/plantgenes/DNA,var/searchtype)
	// This just checks to see if we have a paticular gene strain active.
	if(!DNA || !searchtype) return 0
	if(DNA.commuts)
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			if(X.type == searchtype) return 1
	return 0

proc/HYPnewcommutcheck(var/datum/plant/P,var/datum/plantgenes/DNA, var/frequencymult = 1)
	// This is the proc for checking if a new random gene strain will appear in the plant.
	if(!P || !DNA) return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer))
		return
	if(P.commuts.len > 0)
		var/datum/plant_gene_strain/MUT = null
		for (var/datum/plant_gene_strain/X in P.commuts)
			if(HYPCheckCommut(DNA,X.type))
				continue
			if(prob(X.chance*frequencymult))
				MUT = X
				break
		if(MUT)
			// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
			if(DNA.commuts)
				// new list containing same items as original, plus new mutation
				DNA.commuts = DNA.commuts + MUT
			else
				// new list containing new mutation
				DNA.commuts = list(MUT)

proc/HYPaddCommut(var/datum/plant/P,var/datum/plantgenes/DNA,var/commut)
	// And this one is for forcibly adding specific strains.
	if(!P || !DNA || !commut) return
	if(!ispath(commut)) return
	if(DNA.commuts)
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			if(X.type == commut)
				return
	// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
	if(DNA.commuts)
		DNA.commuts = DNA.commuts + HY_get_strain_from_path(commut)
	else
		DNA.commuts = list(HY_get_strain_from_path(commut))

proc/HYPmutateDNA(var/datum/plantgenes/DNA,var/severity = 1)
	// This proc jumbles up the variables in a plant's genes. It's fundamental to breeding.
	if(!DNA) return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer))
		return
	DNA.growtime += rand(-10 * severity,10 * severity)
	DNA.harvtime += rand(-10 * severity,10 * severity)
	DNA.cropsize += rand(-2 * severity,2 * severity)
	if(prob(33)) DNA.harvests += rand(-1 * severity,1 * severity)
	DNA.potency += rand(-5 * severity,5 * severity)
	DNA.endurance += rand(-3 * severity,3 * severity)

proc/HYPmutationcheck_full(var/datum/plant/growing,var/datum/plantgenes/DNA,var/datum/plantmutation/MUT)
	// This proc iterates through all of the various boundaries and requirements a mutation must
	// have to appear, and if all of them are matchedit gives the green light to go ahead and
	// add it - though there's still a % chance involved after this check passes which is handled
	// where this check is called, usually.
	if(!HYPmutationcheck_sub(MUT.GTrange[1],MUT.GTrange[2],DNA.growtime)) return FALSE
	if(!HYPmutationcheck_sub(MUT.HTrange[1],MUT.HTrange[2],DNA.harvtime)) return FALSE
	if(!HYPmutationcheck_sub(MUT.HVrange[1],MUT.HVrange[2],DNA.harvests)) return FALSE
	if(!HYPmutationcheck_sub(MUT.CZrange[1],MUT.CZrange[2],DNA.cropsize)) return FALSE
	if(!HYPmutationcheck_sub(MUT.PTrange[1],MUT.PTrange[2],DNA.potency)) return FALSE
	if(!HYPmutationcheck_sub(MUT.ENrange[1],MUT.ENrange[2],DNA.endurance)) return FALSE
	if(MUT.commut && !HYPCheckCommut(DNA,MUT.commut)) return FALSE
	if(MUT.required_mutation && !istype(DNA.mutation, MUT.required_mutation)) return FALSE
	return TRUE

proc/HYPmutationcheck_sub(var/lowerbound,var/upperbound,var/checkedvariable)
	// Part of mutationcheck_full. Just a simple mathematical check to keep the prior proc
	// more compact and efficient.
	if(lowerbound || upperbound)
		if(lowerbound && checkedvariable < lowerbound) return 0
		if(upperbound && checkedvariable > upperbound) return 0
		return 1
	else return 1

// Machines created specifically to interact with plantpots, kind of abandoned experimental
// shit for the time being for the most part.

/obj/machinery/hydro_growlamp
	name = "\improper UV Grow Lamp"
	desc = "A special lamp that emits ultraviolet light to help plants grow quicker."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "growlamp0" // sprites by Clarks
	density = 1
	anchored = 0
	mats = 6
	var/active = 0
	var/datum/light/light
	power_usage = 100

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(1)
		light.set_height(1)
		light.set_color(0.7, 0.2, 1)
		if(src.active)
			light.enable()
		else
			light.disable()


	process()
		..()
		if(src.active && powered())
			for (var/obj/machinery/plantpot/P in view(2,src))
				if(!P.current || P.dead)
					continue
				P.growth += 2
				if(istype(P.plantgenes,/datum/plantgenes/))
					var/datum/plantgenes/DNA = P.plantgenes
					if(HYPCheckCommut(DNA,/datum/plant_gene_strain/photosynthesis))
						P.growth += 4
			use_power(power_usage)

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		src.active = !src.active
		user.visible_message("<b>[user]</b> switches [src.name] [src.active ? "on" : "off"].")
		src.icon_state = "growlamp[src.active]"
		if(src.active && !HAS_FLAG(status, (NOPOWER|BROKEN)))
			light.enable()
		else
			light.disable()

	power_change()
		. = ..()
		if(HAS_FLAG(status, NOPOWER))
			light.disable()
		else if(src.active)
			light.enable()


	attackby(obj/item/W, mob/user)
		if(isscrewingtool(W) || iswrenchingtool(W))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = !src.anchored

/obj/machinery/hydro_mister
	name = "\improper Botanical Mister"
	desc = "A device that constantly sprays small amounts of chemical onto nearby plants."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fogmachine0"
	density = 1
	anchored = 0
	mats = 6
	var/active = 0
	var/mode = 1

	New()
		..()
		src.create_reagents(5000)
		reagents.add_reagent("water", 1000)

	get_desc()
		var/reag_list = ""
		for(var/current_id in src.reagents.reagent_list)
			var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
			reag_list += "[reag_list ? ", " : " "][current_reagent.name]"
		return "<br>It's [!src.active ? "off" : (!src.mode ? "on low" : "on high")]. It's about [round(src.reagents.total_volume / src.reagents.maximum_volume * 100, 1)]% full. It seems to contain [reag_list]."

	process()
		..()
		if(src.active)
			for (var/obj/machinery/plantpot/P in view(2,src))
				if(P.reagents.get_reagent_amount("water") >= 195)
					continue
				src.reagents.trans_to(P, 1 + (mode * 4))
			if(src.reagents.total_volume < 10)
				src.visible_message("\The [src] sputters and runs out of liquid.")
				src.active = 0
				src.mode = 0

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/))
			// Not just watering cans - any kind of glass can be used to pour stuff in.
			if(!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")
				return
			else
				user.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if(!W.reagents.total_volume) boutput(user, "<span class='alert'><b>[W] is now empty.</b></span>")


	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		if(!src.active)
			src.active = 1
			src.mode = 0
			user.visible_message("<b>[user]</b> switches [src.name] on to low power mode.")
			src.visible_message("\The [src] starts to hum, emitting a fine mist.")
		else
			if(!src.mode)
				src.mode = 1
				user.visible_message("<b>[user]</b> switches [src.name] to high power mode.")
				src.visible_message("\The [src] starts to <em>really</em> emit a fine mist!")
			else
				src.active = 0
				src.mode = 0
				user.visible_message("<b>[user]</b> switches [src.name] off.")
				src.visible_message("\The [src] goes quiet.")

		src.icon_state = "fogmachine[src.active]"
		playsound(src, 'sound/misc/lightswitch.ogg', 50, 1)

	is_open_container()
		return 1 // :I
