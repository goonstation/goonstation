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
// obj/machinery/hydroponic_machines.dm: the botanical mister and UV lamp can be found here
// modules/hydroponics/hydroponics_misc_procs.dm: Here misc procs which are used on multiple places in botany code can be found


TYPEINFO(/obj/machinery/plantpot)
	mats = 2

/obj/machinery/plantpot
	// The central object for Hydroponics. All plant growing and most of everything goes on in
	// this object - that said you don't want to have too many of them on the map because they
	// get kind of resource intensive past a certain point.
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "tray"
	anchored = UNANCHORED
	density = 1
	event_handler_flags = null
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

	var/datum/plantgrowth_tick/current_tick //! the plantgrowth_tick the plantpot will resolve next. This can be accessed and modifed by machinery like e.g. UV-lamps

	var/report_freq = FREQ_HYDRO //Radio channel to report plant status/death/whatever.
	var/net_id = null

	var/base_cropcount_consistency = 70 // The base lower-bounds for cropcount consistency, used during harvesting.
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
	var/more_info = FALSE // debug tray: show more info

/obj/machinery/plantpot/New()
	..()
	src.plantgenes = new /datum/plantgenes(src)
	src.create_reagents(400)
	// The plantpot can store 400 reagents in total, we want a bit more than the max water
	// level since we can put other additives in the pot for various effects.
	src.reagents.add_reagent("water", 200)
	// 200 is the exact maximum amount of water a plantpot can hold before it is considered
	// to have too much water, which stunts plant growth speed.
	src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi', "wat-[src.water_level]")
	src.plant_sprite = image('icons/obj/hydroponics/plants_weed.dmi', "")
	UpdateIcon()

	if(!src.net_id)
		src.net_id = generate_net_id(src)
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, report_freq)

	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "scan plant", PROC_REF(mechcompScanPlant))

/obj/machinery/plantpot/get_desc(dist, mob/user)
	. = ..()
	if (dist >= 5)
		return
	HYPphytoscopic_scan(user, src)

/obj/machinery/plantpot/proc/post_alert(var/list/alert_data)
	if(src.status & (NOPOWER|BROKEN)) return
	if(!alert_data) return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = 1
	// merge the alert data with the signal data to combine them
	// signal.data["data"] = alert_msg
	signal.data += alert_data
	signal.data["netid"] = src.net_id
	signal.data["address_tag"] = "plantpot_listener" // prevents unnecessarily sending to other plantpots

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)
	// the alert data is a list of fields already, so just send that as a signal
	SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, list2params(alert_data))


/obj/machinery/plantpot/proc/mechcompScanPlant(var/datum/mechanicsMessage/input)
	if (!input) return
	if (!src.current)
		input.signal = "error=noplant"
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		return
	if (src.current.cantscan)
		input.signal = "error=cantscan"
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		return

	var/list/plant_data = new
	plant_data["event"] = "scan"
	plant_data["plant"] = src.current.name
	plant_data["generation"] = src.generation
	plant_data["mat_rate"] = src.plantgenes.growtime
	plant_data["prod_rate"] = src.plantgenes.harvtime
	plant_data["yield"] = src.plantgenes.cropsize
	plant_data["lifespan"] = src.plantgenes.harvests
	plant_data["potency"] = src.plantgenes.potency
	plant_data["endurance"] = src.plantgenes.endurance
	plant_data["reagent_level"] = (src.reagents ? src.reagents.total_volume : 0)
	plant_data["water_level"] = (src.reagents ? src.reagents.get_reagent_amount("water") : 0)

	if (src.more_info)
		// for the debug tray
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/growthlimit = growing.HYPget_growth_to_matured(DNA)
		plant_data["hp"] = src.health
		plant_data["hpmax"] = growing.starthealth
		plant_data["growth"] = src.growth
		plant_data["growthmax"] = growthlimit

	input.signal = list2params(plant_data)
	SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)

/obj/machinery/plantpot/proc/get_current_growth_stage()
	if(!current || src.dead)
		return HYP_GROWTH_DEAD
	return src.current.HYPget_growth_stage(src.plantgenes, src.growth)

/obj/machinery/plantpot/proc/update_water_level() //checks reagent contents of the pot, then returns the cuurent water level
	var/list/water_substitutes = src.get_available_water_subsitutes()
	var/current_total_volume = (src.reagents ? src.reagents.total_volume : 0)
	var/current_water_level = (src.reagents ? src.reagents.get_reagent_amount("water") : 0)
	for (var/substitute in water_substitutes)
		current_water_level += (src.reagents ? src.reagents.get_reagent_amount(substitute) : 0)
	switch(current_water_level)
		if(0 to 0) current_water_level = 1
		if(0 to 40) current_water_level = 2
		if(40 to 100) current_water_level = 3
		if(100 to 200.1) current_water_level = 4
		if(200.1 to INFINITY) current_water_level = 5
	if(current_water_level != src.water_level)
		src.water_level = current_water_level
		src.do_update_water_icon = 1
	if(!src.current)
		switch(current_total_volume)
			if(0 to 0) current_total_volume = 1
			if(0 to 40) current_total_volume = 2
			if(40 to 100) current_total_volume = 3
			if(100 to 200.1) current_total_volume = 4
			if(200.1 to INFINITY) current_total_volume = 5
		if(current_total_volume != src.total_volume)
			src.total_volume = current_total_volume
			src.do_update_water_icon = 1

	if(src.do_update_water_icon)
		src.update_water_icon()
		src.do_update_water_icon = 0

	return current_water_level

/obj/machinery/plantpot/proc/get_available_water_subsitutes()
	var/list/output = list("poo","water_holy")
	if (src.current?.growthmode == "carnivore")
		output += "blood"
	return output


/obj/machinery/plantpot/EnteredProximity(atom/movable/AM)
	if(!src.current || src.dead)
		return
	src.current?.ProximityProc(src, AM)
	return

/obj/machinery/plantpot/on_reagent_change()
	..()
	src.do_update_water_icon = 1
	src.update_water_level()

/obj/machinery/plantpot/power_change()
	. = ..()
	src.UpdateIcon()

/obj/machinery/plantpot/was_deconstructed_to_frame(mob/user)
	src.current = null // Dont think this would lead to any frustrations, considering like, youre chopping the machine up of course itd destroy the plant.
	//we also get rid of the current plantgrowth_tick, since there is no plant to access it
	qdel(src.current_tick)
	src.current_tick = null
	boutput( user, SPAN_ALERT("In the process of deconstructing the tray you destroy the plant.") )

/obj/machinery/plantpot/process()
	..()

	if(!src.current || src.dead)
		return
		// If the plantpot is empty or contains a dead plant, we don't need to do anything
		// more in the process loop since that'd be pointless and silly.

	var/datum/plant/growing = src.current
	var/datum/plantgenes/DNA = src.plantgenes
	// We obtain the current plant type in the plantpot, and the genes of the individual plant.
	// We'll be referencing these a lot!

	// REAGENT PROCESSING
	if(growing.simplegrowth)
		src.growth++
		// Simplegrowth is used pretty much only for crystals. It essentially skips all
		// simulation whatsoever and just adds one growth point per tick, ignoring all
		// reagents and everything else going on.
	else
		// For proper simulation, we have created a plantgrowth_tick to hold all data which affect the growth of the plant
		// For cases in which this proc doesnt exist, we create it to be able to proceed with effects of chems and the such
		if (!src.current_tick)
			src.current_tick = new /datum/plantgrowth_tick(src)
		// Now we look through every reagent currently in the plantpot and call the reagent's
		// on_plant_life proc. These are defined in the chemistry reagents file on each reagent
		// for the sake of efficiency.
		if(src.reagents) //Wire: Fix for: Cannot read null.reagent_list
			for(var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				if(current_reagent)
					current_reagent.on_plant_life(src, src.current_tick)
		// similary, we call all process ticks of the gene strains the plant currently has and let them modify the current plantgrowth tick
		if(DNA.commuts)
			for (var/datum/plant_gene_strain/X in DNA.commuts)
				X.on_process(src, src.current_tick)
		// last, but not least, we resolve the plantgrowth_tick and apply all changes to the plant
		src.HYPresolve_plantgrowth_tick(src.current_tick)
		// after the plantgrowth_tick was resolved and deleted, we store a new one we prepare to resolve next
		src.current_tick = new /datum/plantgrowth_tick(src)

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

	if(src.current == null) //synthcats can just get up and walk away. check for that
		return

	// Have we lost all health or growth, or used up all available harvests? If so, this plant
	// should now die. Sorry, that's just life! Didn't they teach you the curds and the peas?
	if((src.health < 1 || src.growth < 0) || (growing.harvestable && src.harvests < 1))
		src.HYPkillplant()
		return

	var/current_growth_level = src.get_current_growth_stage()
	// This is entirely for updating the icon. Check how far the plant has grown and update
	// if it's gone a level beyond what the tracking says it is.

	var/do_update_icon = FALSE
	if(current_growth_level != src.grow_level)
		src.grow_level = current_growth_level
		do_update_icon = TRUE

	if(!harvest_warning && HYPcheck_if_harvestable())
		src.harvest_warning = 1
		do_update_icon = TRUE
		post_alert(list("event" = "harvestable", "plant" = src.current.name))
		src.HYPplant_matured()
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
		src.UpdateIcon()
		src.update_name()

/obj/machinery/plantpot/attackby(obj/item/W, mob/user)
	if(src.current)
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		// Inside this if block we'll handle reactions for specific kinds of plant.
		// General reactions from the plantpot itself come after these.
		if(istype(growing,/datum/plant/maneater))
			var/datum/plant/maneater/Manipulated_Maneater = growing
			// We want to be able to feed stuff to maneaters, such as meat, people, etc.
			if(istype(W, /obj/item/grab) && ishuman(W:affecting) && W:state >= GRAB_AGGRESSIVE)
				if(src.get_current_growth_stage() < HYP_GROWTH_MATURED)
					boutput(user, SPAN_ALERT("It's not big enough to eat that yet."))
					// It doesn't make much sense to feed a full man to a dinky little plant.
					return
				var/mob/living/carbon/human/checked_human = W:affecting
				if (checked_human.decomp_stage > 3 || checked_human.bioHolder?.HasEffect("husk"))
					boutput(user, SPAN_ALERT("That corpse is not fresh enough for the plant."))
					return
				user.visible_message(SPAN_ALERT("[user] starts to feed [checked_human] to the plant!"))
				logTheThing(LOG_COMBAT, user, "attempts to feed [constructTarget(checked_human,"combat")] to a man-eater at [log_loc(src)].") // Some logging would be nice (Convair880).
				message_admins("[key_name(user)] attempts to feed [key_name(checked_human, 1)] ([isdead(checked_human) ? "dead" : "alive"]) to a man-eater at [log_loc(src)].")
				src.add_fingerprint(user)
				if(!(user in src.contributors))
					src.contributors += user
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
				user,
				src,
				3 SECONDS,
				/datum/plant/maneater/proc/feed_maneater,
				\list(src, user, checked_human),
				'icons/mob/screen1.dmi',
				"grabbed",
				"[user] offers [checked_human] to the plant.",
				INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION,
				Manipulated_Maneater)
				actions.start(action_bar, user)
				return
			else if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat))
				if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat) || istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat/fish))
					//we blacklist two very easy avaible types of meat in botany here
					boutput(user, SPAN_ALERT("That meat is not suitable for this plant."))
					return
				src.reagents.add_reagent("blood", 5)
				boutput(user, SPAN_ALERT("You toss the [W] to the plant."))
				qdel (W)
				DNA.endurance += rand(2, 4)
				if(!(user in src.contributors))
					src.contributors += user
			else if(istype(W, /obj/item/organ/brain) || istype(W, /obj/item/clothing/head/butt))
				src.reagents.add_reagent("blood", 20)
				boutput(user, SPAN_ALERT("You toss the [W] to the plant."))
				qdel (W)
				DNA.endurance += rand(4, 6)
				if(!(user in src.contributors))
					src.contributors += user

	// From here on out we handle item reacions of the plantpot itself rather than specific
	// special kinds of plant.

	if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
		// These allow you to unanchor the plantpots to move them around, or re-anchor them.
		if(src.anchored)
			user.visible_message("<b>[user]</b> unbolts the [src] from the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = UNANCHORED
		else
			user.visible_message("<b>[user]</b> secures the [src] to the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = ANCHORED

	else if(isweldingtool(W) || istype(W, /obj/item/device/light/zippo) || istype(W, /obj/item/device/igniter))
		// These are for burning down plants with.
		if(isweldingtool(W) && !W:try_weld(user, 3, noisy = 0, burn_eyes = 1))
			return
		else if(istype(W, /obj/item/device/light/zippo) && !W:on)
			boutput(user, SPAN_ALERT("It would help if you lit it first, dumbass!"))
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
				src.visible_message(SPAN_ALERT("[src] goes up in flames!"))
				src.reagents.add_reagent("ash", src.growth)
				src.HYPdestroyplant()
				// Ashes in the plantpot I guess.
			else
				if(!HYPdamageplant("fire",150)) src.visible_message(SPAN_ALERT("[src] resists the fire!"))

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
				src.visible_message(SPAN_ALERT("[src] is destroyed by [user.name]'s [W.name]!"))
				src.HYPdestroyplant()
				return
			else
				src.HYPdamageplant("physical",150,1)
				src.visible_message(SPAN_ALERT("[user.name] cuts at [src] with [W]!"))

	else if(istype(W, /obj/item/seed/))
		// Planting a seed in the tray. This one should be self-explanatory really.
		var/obj/item/seed/SEED = W
		if(src.current)
			boutput(user, SPAN_ALERT("Something is already in that tray."))
			return
		user.visible_message(SPAN_NOTICE("[user] plants a seed in the [src]."))
		if(SEED.planttype)
			logTheThing(LOG_STATION, user, "plants a [SEED.planttype?.name] [SEED.planttype?.type] (reagents: [json_encode(HYPget_assoc_reagents(SEED.planttype, SEED.plantgenes))]) seed at [log_loc(src)].")
			src.HYPnewplant(SEED)
			SEED.charges--
			if (SEED.charges < 1)
				user.u_equip(SEED)
				qdel(SEED)
			else SEED.inventory_counter.update_number(SEED.charges)
			if(!(user in src.contributors))
				src.contributors += user
		else
			boutput(user, SPAN_ALERT("You plant the seed, but nothing happens."))
			user.u_equip(SEED)
			qdel(SEED)
		return

	else if(istype(W, /obj/item/seedplanter/))
		var/obj/item/seedplanter/SP = W
		if(src.current)
			boutput(user, SPAN_ALERT("Something is already in that tray."))
			return
		if(!SP.selected)
			boutput(user, SPAN_ALERT("You need to select something to plant first."))
			return
		var/obj/item/seed/SEED
		if(SP.selected.unique_seed)
			SEED = new SP.selected.unique_seed
		else
			SEED = new /obj/item/seed
		SEED.generic_seed_setup(SP.selected, FALSE)
		if(SEED.planttype)
			src.HYPnewplant(SEED)
			logTheThing(LOG_STATION, user, "plants a [SEED.planttype?.name] [SEED.planttype?.type] seed at [log_loc(src)] using the seedplanter.")
			if(!(user in src.contributors))
				src.contributors += user
		else
			boutput(user, SPAN_ALERT("You plant the seed, but nothing happens."))
		qdel(SEED)

	else if(istype(W, /obj/item/reagent_containers/glass/) && W.is_open_container(FALSE))
		// Not just watering cans - any kind of glass can be used to pour stuff in.
		if(!W.reagents.total_volume)
			boutput(user, SPAN_ALERT("There is nothing in [W] to pour!"))
			return
		else
			//corrects the amount of reagents shown to have been used when pouring into a tray
			var/trans = W.reagents.trans_to(src, W:amount_per_transfer_from_this)
			user.visible_message(SPAN_NOTICE("[user] pours [trans] units of [W]'s contents into [src]."))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			if(!(user in src.contributors))
				src.contributors += user
			if(!W.reagents.total_volume) boutput(user, SPAN_ALERT("<b>[W] is now empty.</b>"))
			src.UpdateIcon()
			return


	else if((istype(W, /obj/item/raw_material/shard) && W.material?.getID() == "plasmaglass") && !current)
		// Planting a plasmaglass shard puts a crystal seed inside the plant pot for
		// a moment, spawns a new plant from it, then removes the seed and one shard.
		user.visible_message(SPAN_NOTICE("[user] plants a plasmaglass shard in the tray."))
		var/obj/item/seed/crystal/WS = new /obj/item/seed/crystal
		WS.set_loc(src)
		src.HYPnewplant(WS)
		W.change_stack_amount(-1)
		sleep(0.5 SECONDS)
		qdel(WS)
		if(!(user in src.contributors))
			src.contributors += user

	else if(istype(W, /obj/item/satchel/hydro))
		// Harvesting directly into a satchel.
		if(!src.current)
			boutput(user, SPAN_ALERT("There's no plant here to harvest!"))
			return
		if(src.dead)
			boutput(user, SPAN_ALERT("The plant is dead and cannot be harvested!"))
			return
		var/datum/plant/growing = src.current
		if(!growing.harvestable)
			boutput(user, SPAN_ALERT("You doubt this plant is going to grow anything worth harvesting..."))
			return

		if(HYPcheck_if_harvestable())
			src.HYPharvesting(user,W)
		else
			boutput(user, SPAN_ALERT("The plant isn't ready to be harvested yet!"))
			return

	else ..()

/obj/machinery/plantpot/attack_ai(mob/user as mob)
	if(isrobot(user) && BOUNDS_DIST(src, user) == 0) return src.Attackhand(user)

/obj/machinery/plantpot/attack_hand(var/mob/user)
	if(isAI(user) || isobserver(user)) return // naughty AIs used to be able to harvest plants
	src.add_fingerprint(user)
	if(src.current)
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantmutation/MUT = DNA.mutation

		if(src.dead)
			boutput(user, SPAN_NOTICE("You clear the dead plant out of the tray."))
			src.HYPdestroyplant()
			return

		if(HYPcheck_if_harvestable())
			src.HYPharvesting(user,null)

			// If the plant is ready for harvest, do that. Otherwise, check it's condition.
		else
			boutput(user, "You check [src.name] and the tray.")

			if(src.recently_harvested) boutput(user, "This plant has been harvested recently. It needs some time to regenerate.")
			if(!src.reagents.has_reagent("water")) boutput(user, SPAN_ALERT("The tray is completely dry."))
			else
				if(src.reagents.get_reagent_amount("water") > 200)  boutput(user, SPAN_ALERT("The tray has too much water."))
				if(src.reagents.get_reagent_amount("water") < 40) boutput(user, SPAN_ALERT("The tray's water level looks a little low."))
			if(src.health >= growing.starthealth * 4) boutput(user, SPAN_NOTICE("The plant is flourishing!"))
			else if(src.health >= growing.starthealth * 2) boutput(user, SPAN_NOTICE("The plant looks very healthy."))
			else if(src.health <= growing.starthealth / 2) boutput(user, SPAN_ALERT("The plant is in poor condition."))
			if(MUT) boutput(user, SPAN_ALERT("The plant looks strange..."))

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

/obj/machinery/plantpot/mouse_drop(over_object, src_location, over_location)
	..()
	if(!isliving(usr) || isintangible(usr) || isghostcritter(usr)) return // ghosts&ghost critter killing plants fix
	if(BOUNDS_DIST(src, usr) > 0)
		boutput(usr, SPAN_ALERT("You need to be closer to empty the tray out!"))
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
					boutput(usr, SPAN_ALERT("Weeds still infest the tray. You'll need something a bit more thorough to get rid of them."))
					src.growth = 0
					src.reagents.clear_reagents()
					// The idea here is you gotta use weedkiller or something else to get rid of the
					// weeds since you can't just clear them out by hand.
		else
			if(tgui_alert(usr, "Clear this tray?", "Clear tray", list("Yes", "No")) == "Yes")
				if(!QDELETED(current) && !QDELETED(src))
					usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
					src.reagents.clear_reagents()
					logTheThing(LOG_COMBAT, usr, "cleared a hydroponics tray containing [current?.name] at [log_loc(src)]")
					src.HYPdestroyplant()
	else
		if(tgui_alert(usr, "Clear this tray?", "Clear tray", list("Yes", "No")) == "Yes")
			if(!QDELETED(src))
				usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
				logTheThing(LOG_STATION, usr, "cleared a hydroponics tray containing [current?.name] at [log_loc(src)]")
				src.reagents.clear_reagents()
				src.UpdateIcon()
				src.update_name()

/obj/machinery/plantpot/MouseDrop_T(atom/over_object as obj, mob/user as mob) // ty to Razage for the initial code
	if(BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, over_object) > 0 || is_incapacitated(user) || isAI(user))
		return
	if(istype(over_object, /obj/item/seed))  // Checks to make sure it's a seed being dragged onto the tray.
		if(BOUNDS_DIST(user, src) > 0)
			boutput(user, SPAN_ALERT("You need to be closer to the tray!"))
			return
		if(BOUNDS_DIST(user, over_object) > 0)
			boutput(user, SPAN_ALERT("[over_object] is too far away!"))
			return
		src.Attackby(over_object, user)  // Activates the same command as would be used with a seed in hand on the tray.
		return
	else // if it's not a seed...
		return ..() // call our parents and ask what to do.

/obj/machinery/plantpot/temperature_expose(null, temp, volume)
	if(reagents) reagents.temperature_reagents(temp, volume)
	if(temp >= 360)
		if(src.current)
			if(src.dead)
				src.reagents.add_reagent("saltpetre", src.growth)
				src.HYPdestroyplant()
			else src.HYPdamageplant("fire",temp - 360)

/obj/machinery/plantpot/receive_signal(datum/signal/signal)
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

/obj/machinery/plantpot/proc/update_water_icon()
	var/datum/color/average
	src.water_sprite = image('icons/obj/hydroponics/machines_hydroponics.dmi',"wat-[src.total_volume]")
	src.water_sprite.layer = 3
	src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
	if(src.reagents.total_volume)
		average = src.reagents.get_average_color()
		src.water_sprite.color = average.to_rgba()

	src.AddOverlays(src.water_sprite, "water_fluid")
	src.AddOverlays(src.water_meter, "water_meter")

/obj/machinery/plantpot/update_icon() //plant icon stuffs
	src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
	src.AddOverlays(water_meter, "water_meter")
	if(!src.current)
		src.ClearSpecificOverlays("harvest_display", "health_display", "plant", "plantdeath", "plantoverlay")
		if(status & (NOPOWER|BROKEN))
			src.ClearSpecificOverlays("water_meter")
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
		src.AddOverlays(hydro_controls.pot_death_display, "plantdeath")
		src.ClearSpecificOverlays("harvest_display", "health_display")
	else
		src.ClearSpecificOverlays("plantdeath")
		if(src.harvest_warning)
			src.AddOverlays(hydro_controls.pot_harvest_display, "harvest_display")
		else
			src.ClearSpecificOverlays("harvest_display")

		if(src.health_warning)
			src.AddOverlays(hydro_controls.pot_health_display, "health_display")
		else
			src.ClearSpecificOverlays("health_display")

	var/planticon = growing.getIconState(src.grow_level, MUT)

	src.plant_sprite.icon = iconname
	src.plant_sprite.icon_state = planticon
	src.plant_sprite.layer = 4
	src.AddOverlays(plant_sprite, "plant")

	var/plantoverlay = growing.getIconOverlay(src.grow_level, MUT)
	if(plantoverlay)
		src.AddOverlays(image(iconname, plantoverlay, 5), "plantoverlay")
	else
		src.ClearSpecificOverlays("plantoverlay")

	if(status & (NOPOWER|BROKEN))
		src.ClearSpecificOverlays("water_meter", "harvest_display", "health_display", "plantdeath")

/obj/machinery/plantpot/proc/update_name()
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

/obj/machinery/plantpot/disposing()
	qdel(src.current_tick)
	src.current_tick = null
	. = ..()


/obj/machinery/plantpot/proc/HYPcheck_if_harvestable()
	// Pretty much figure out if we can harvest the plant yet or not. This is used for
	// updating the sprite and obviously handling harvesting when a player clicks
	// on the plant pot.
	if(!src.current || !src.plantgenes || src.health < 1 || src.harvests < 1 || src.recently_harvested) return FALSE
	if(src.plantgenes.mutation)
		var/datum/plantmutation/MUT = src.plantgenes.mutation
		if(MUT.harvest_override && MUT.crop)
			if(src.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE) return TRUE
			else return FALSE
	if(!src.current.crop || !src.current.harvestable) return FALSE

	if(src.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE) return TRUE
	else return FALSE

/obj/machinery/plantpot/proc/HYPresolve_plantgrowth_tick()
	if(!src.current_tick)
		return
	var/datum/plantgenes/DNA = src.plantgenes
	var/current_water_level = src.update_water_level()
	var/final_growth_rate = src.current_tick.growth_rate
	var/final_health_change = src.current_tick.health_change
	if(current_water_level)
		//if there is enough water, we check the max water limit and apply the bonus for keeping the plant in optimal water range
		if(current_water_level <= src.current_tick.bonus_growth_water_limit)
			final_health_change += src.current_tick.bonus_growth_rate
			final_growth_rate  += src.current_tick.bonus_health_rate
	else
		// If there's no water in the plant pot, we damage the plant and apply the thirst growth multiplier
		src.HYPdamageplant("drought", HYPstat_rounding(src.current_tick.thirst_damage * src.current_tick.tick_multiplier))
		final_growth_rate *= src.current_tick.thirst_growth_rate_multiplier
	// now we calculate the final values of growthrate and health changes
	final_growth_rate *= src.current_tick.tick_multiplier
	final_health_change *= src.current_tick.tick_multiplier

	// now we apply the changes by the plantgrowth_tick
	// health and growth
	if (final_health_change < 0)
		src.HYPdamageplant("frailty", HYPstat_rounding(final_health_change * -1))
	else
		src.health += HYPstat_rounding(final_health_change)
	src.growth += HYPstat_rounding(final_growth_rate)
	// damage-sources
	if (src.current_tick.fire_damage > 0)
		src.HYPdamageplant("fire", HYPstat_rounding(src.current_tick.fire_damage * src.current_tick.tick_multiplier))
	if (src.current_tick.poison_damage > 0)
		src.HYPdamageplant("poison", HYPstat_rounding(src.current_tick.poison_damage * src.current_tick.tick_multiplier))
	if (src.current_tick.radiation_damage > 0)
		src.HYPdamageplant("poison", HYPstat_rounding(src.current_tick.radiation_damage * src.current_tick.tick_multiplier))
	if (src.current_tick.acid_damage > 0)
		src.HYPdamageplant("radiation", HYPstat_rounding(src.current_tick.acid_damage * src.current_tick.tick_multiplier))
	// plant-stats
	if (DNA)
		DNA.growtime += HYPstat_rounding(src.current_tick.growtime_bonus * src.current_tick.tick_multiplier)
		DNA.harvtime += HYPstat_rounding(src.current_tick.harvtime_bonus * src.current_tick.tick_multiplier)
		DNA.cropsize += HYPstat_rounding(src.current_tick.cropsize_bonus * src.current_tick.tick_multiplier)
		DNA.harvests += HYPstat_rounding(src.current_tick.harvests_bonus * src.current_tick.tick_multiplier)
		DNA.potency += HYPstat_rounding(src.current_tick.potency_bonus * src.current_tick.tick_multiplier)
		DNA.endurance += HYPstat_rounding(src.current_tick.endurance_bonus * src.current_tick.tick_multiplier)
	// Now we modify chems in the tray
	if (src.reagents)
		src.reagents?.remove_any_except(src.current_tick.water_consumption * src.current_tick.tick_multiplier, "nectar")
		// This is where drink_rate does its thing. It will remove a bit of all reagents to meet
		// it's quota, except nectar because that's supposed to stay in the plant pot.
		// We give off nectar and should check our nectar levels
		if(src.current.nectarlevel)
			var/current_level = src.reagents.get_reagent_amount("nectar")
			if(current_level < src.current.nectarlevel)
				src.reagents.add_reagent("nectar", src.current.nectarlevel * randfloat(0.2, 0.5) * src.current_tick.tick_multiplier * src.current_tick.nectar_generation_multiplier_bonus)
		// This keeps the nectar at the amount specified in the plant's datum.
	//Now, we apply mutagenic chemicals
	//since mutation chems can stack via their severity, we use this in this case
	var/final_mutation_severity = HYPstat_rounding(src.current_tick.mutation_severity * src.current_tick.tick_multiplier)
	if (final_mutation_severity > 0)
		src.HYPmutateplant(final_mutation_severity)
	// At last, growth_tick isn't usefull anymore, so we can get rid of it
	qdel(src.current_tick)


/obj/machinery/plantpot/proc/HYPharvesting(var/mob/living/user,var/obj/item/satchel/SA)
	// This proc is where the harvesting actually happens. Again it shouldn't need tweaking
	// with since i've tried to account for most special circumstances that might come up.
	if(!user) return
	if(SA)
		if(length(SA.contents) >= SA.maxitems)
			boutput(user, SPAN_ALERT("Your satchel is already full! Free some space up first."))
			return
		else
			if(!HYPcheck_if_harvestable())
				return
	// it's okay if we don't have a satchel at all since it'll just harvest by hand instead

	// setup harvesting data to make it easier to pass around data related to this harvest
	var/datum/HYPharvesting_data/h_data = new()
	h_data.growing = src.current
	h_data.DNA = src.plantgenes
	h_data.MUT = h_data.DNA.mutation
	h_data.pot = src
	h_data.user = user
	// This is a modular thing suggested by Cogwerks that can affect the final quality
	// of produce such as making fruit make you sick or herbs have less reagents.
	h_data.base_quality_score = 1

	if(!h_data.growing)
		logTheThing(LOG_DEBUG, user, "<b>Hydro Controls</b>: Plant pot at \[[x],[y],[z]] used by ([user]) attempted a harvest without having a current plant.")
		return

	if(h_data.growing.harvested_proc)
		// Does this plant react to being harvested? If so, do it - it also functions as
		// a check since harvesting will stop here if this returns anything other than 0.
		if(h_data.growing.HYPharvested_proc(src,user)) return
		if(h_data.MUT?.HYPharvested_proc_M(src,user)) return
		//it can happen during HYPharvested_proc that the planttype in the pot gets replaced, we account for that here
		h_data.growing = src.current

	// Setup global stuff from hydro_controls
	if(hydro_controls)
		src.recently_harvested = 1
		src.harvest_warning = 0
		h_data.harvest_cap = hydro_controls.max_harvest_cap
		SPAWN(hydro_controls.delay_between_harvests)
			src.recently_harvested = 0
	else
		logTheThing(LOG_DEBUG, null, "<b>Hydro Controls</b>: Could not access Hydroponics Controller to get Delay or Harvest cap.")

	// Replace default harvest cap with mutation override if applicable
	if(h_data.MUT?.harvest_cap)
		h_data.harvest_cap = h_data.MUT.harvest_cap

	// Reset the growth back to the beginning of maturation so we can wait out the
	// harvest time again.
	src.growth = max(0, h_data.growing.HYPget_growth_to_matured(h_data.DNA))
	// setup initial crop size
	h_data.cropcount = h_data.growing.cropsize
	// handle bonuses and negatives to do with the plant's health
	HYPharvesting_health_bonuses(h_data)
	// Figure out what crop we use - the base crop or a mutation crop.
	HYPharvesting_mutated_crops(h_data)
	// handle bonuses and negatives to do with gene strains
	HYPharvesting_gene_strains(h_data)
	// Finalise cropcount, making sure it's in accordance with maximums
	HYPharvesting_finalise_cropcount(h_data)

	if(h_data.cropcount < 1)
		boutput(user, SPAN_ALERT("You aren't able to harvest anything worth salvaging."))
		// We just don't bother if the output is below one.
	else if(!h_data.getitem)
		boutput(user, SPAN_ALERT("You can't seem to find anything that looks harvestable."))
		// mostly a fix for a runtime error if getitem was null
	else
		// Generate harvest products
		HYPharvesting_generate_products(h_data)
		// Handle seed outputs
		HYPharvesting_seeds(h_data)
		// Handle experience gains
		HYPharvesting_experience(h_data)

		boutput(user, SPAN_NOTICE("You harvest [h_data.cropcount] item[s_es(h_data.cropcount)][h_data.seedcount ? " and [h_data.seedcount] seed[s_es(h_data.seedcount)]" : ""]."))
		post_alert(list("event" = "harvest", "plant" = src.current.name, "produce" = h_data.cropcount, "seeds" = h_data.seedcount))
#ifdef DATALOGGER
		game_stats.Increment("hydro_harvests")
		game_stats.IncrementBy("hydro_produce", h_data.cropcount)
#endif

		// Mostly for dangerous produce (explosive tomatoes etc) that should show up somewhere in the logs (Convair880).
		if(istype(h_data.MUT,/datum/plantmutation/))
			logTheThing(LOG_STATION, user, "harvests [h_data.cropcount] items from a [h_data.MUT.name] plant ([h_data.MUT.type]) at [log_loc(src)].")
		else
			logTheThing(LOG_STATION, user, "harvests [h_data.cropcount] items from a [h_data.growing.name] plant ([h_data.growing.type]) at [log_loc(src)].")

		// At this point all the harvested items are inside the plant pot, and this is the
		// part where we decide where they're going and get them out.
		HYPharvesting_produce_output(h_data, SA)

	// Now we determine the harvests remaining or grant extra ones.
	HYPharvesting_remaining_harvests(h_data)

	//do we have to run the next life tick manually? maybe
	playsound(src.loc, "rustle", 50, 1, -5, 2)
	src.UpdateIcon()
	src.update_name()

//////////////////////////////////
// HYPharvesting helper methods //
//////////////////////////////////
// Could move some of these to var/datum/plant if plants ever wanted more control over how their produce is harvested

/// Returns a generic quality score based on the given plant genes
/obj/machinery/plantpot/proc/get_quality_score(datum/HYPharvesting_data/h_data)
	var/quality_score = h_data.base_quality_score
	quality_score += rand(-2,2)
	// Just a bit of natural variance to make it interesting
	if(h_data.DNA?.get_effective_value("potency"))
		quality_score += round(h_data.DNA?.get_effective_value("potency") / 6)
	if(h_data.DNA?.get_effective_value("endurance"))
		quality_score += round(h_data.DNA?.get_effective_value("endurance") / 6)
	if(HYPCheckCommut(h_data.DNA,/datum/plant_gene_strain/unstable))
		quality_score += rand(-7,7)
	return quality_score

/// Updates a quality status and score list based. 'quality' expects list("score" = num, "status" = text).
/obj/machinery/plantpot/proc/get_quality_and_status(datum/HYPharvesting_data/h_data, list/quality)
	//This calculates produce quality and quality status. We need this for changing the name of the produce
	//since quality status can override each other, they apply to quality status modifier first
	if (!h_data)
		return
	var/quality_score_cache = quality["score"]

	switch(quality_score_cache)
		if(25 to INFINITY)
			// as quality approaches 115, rate of getting jumbo increases
			if(prob(min(100, quality["score"] - 15)))
				quality["status"] = "jumbo"
				quality["score"] += quality_score_cache
		if(20 to 24)
			if(prob(4))
				quality["status"] = "jumbo"
				quality["score"] += quality_score_cache
		if(-9999 to -11)
			quality["status"] = "rotten"
			quality["score"] += - 20
	if(HYPCheckCommut(h_data.DNA,/datum/plant_gene_strain/unstable) && prob(33))
		// The unstable gene can do weird shit to your produce and happily stomp on your jumbo produce.
		quality["status"] = "malformed"
		quality["score"] += rand(10,-10)

/// helper method for picking the item type of produce
/obj/machinery/plantpot/proc/pick_type(datum/HYPharvesting_data/h_data)
	var/itemtype = null
	if(istype(h_data.getitem, /list))
		itemtype = pick(h_data.getitem)
	else
		itemtype = h_data.getitem
	return itemtype

/// Handles the generation of mobs/items during harvests
/obj/machinery/plantpot/proc/HYPharvesting_generate_products(datum/HYPharvesting_data/h_data)
	for (var/_ in 1 to h_data.cropcount)
		// Start up the loop of grabbing all our produce. Remember, each iteration of
		// this loop is for one item each.

		//Now we define some variables for quality calculation.
		var/list/quality = list("status" = "", "score" = 0)
		quality["score"] = get_quality_score(h_data)
		get_quality_and_status(h_data, quality)

		//Now we can create an item or mob
		// Marquesas: I thought of everything and couldn't find another way, but we need this for synthlimbs.
		// Okay, I meanwhile realized there might be another way but this looks cleaner. IMHO.
		var/itemtype = pick_type(h_data)
		var/atom/CROP = new itemtype

		if(istype(CROP, /obj))
			var/obj/CROP_ITEM = CROP
			CROP_ITEM.set_loc(h_data.pot)

			//We call HYPsetup_DNA on each item created before we manipulate it further
			//This proc handles all crop-related scaling and quirks of produce
			//This proc also on some items remove the respectable produce and returns a new one, which we will handle further as CROP
			//This proc calls HYPadd_harvest_reagents on it's respectable items
			if(istype(CROP_ITEM, /obj/item))
				var/obj/item/manipulated_item = CROP_ITEM
				CROP_ITEM = manipulated_item.HYPsetup_DNA(h_data.DNA, h_data.pot, h_data.growing, quality["status"])

			//last but not least, we give the mob a proper name
			CROP_ITEM.name = HYPgenerate_produce_name(CROP_ITEM, h_data.pot, h_data.growing, quality["score"], quality["status"], h_data.dont_rename_crop)

			CROP_ITEM.quality = quality["score"]

			if(!h_data.growing.stop_size_scaling) //Keeps plant sprite from scaling if variable is enabled.
				CROP_ITEM.transform = matrix() * clamp((quality["score"] + 100) / 100, 0.35, 2)

			if(istype(CROP_ITEM,/obj/critter/))
				// If it's a critter we don't need to do reagents or shit like that but
				// we do need to make sure they don't attack the botanist that grew it.
				var/obj/critter/C = CROP_ITEM
				C.friends = C.friends | h_data.pot.contributors


		if(istype(CROP, /mob))
			// Start up the loop of grabbing all our produce. Remember, each iteration of
			// this loop is for one item each.
			var/obj/CROP_MOB = CROP
			CROP_MOB.set_loc(h_data.pot)

			//We call HYPsetup_DNA on each mob created before we manipulate it further
			//This proc handles all crop-related scaling and quirks of produce
			//This proc also on some mobs remove the respectable produce and returns a new one, which we will handle further as CROP_MOB
			if (istype(CROP_MOB, /mob/living/critter/plant))
				var/mob/living/critter/plant/manipulated_critter = CROP_MOB
				CROP_MOB = manipulated_critter.HYPsetup_DNA(h_data.DNA, h_data.pot, h_data.growing, quality["status"])

			//last but not least, we give the mob a proper name
			CROP_MOB.name = HYPgenerate_produce_name(CROP_MOB, h_data.pot, h_data.growing, quality["score"], quality["status"], h_data.dont_rename_crop)

		if(((h_data.growing.isgrass || (h_data.growing.force_seed_on_harvest > 0 )) && prob(80)) && !istype(h_data.getitem,/obj/item/seed/) && !HYPCheckCommut(h_data.DNA,/datum/plant_gene_strain/seedless) && (h_data.growing.force_seed_on_harvest >= 0 ))
			// Same shit again. This isn't so much the crop as it is giving you seeds
			// incase you couldn't get them otherwise, though.
			h_data.seedcount++

/// Give XP based on base quality of crop harvest.
/obj/machinery/plantpot/proc/HYPharvesting_experience(datum/HYPharvesting_data/h_data)
	// Will make better later, like so more plants harvasted and stuff, this is just for testing.
	// This is only reached if you actually got anything harvested.
	// (tmp_crop here was causing runtimes in a lot of cases, so changing to just use it like this)
	// Base quality score:
	//   1: base
	// -12: if HP <=  50% w/ 70% chance
	// + 5: if HP >= 200% w/ 30% chance
	// +10: if HP >= 400% w/ 30% chance
	// Mutations can add or remove this, of course
	// @TODO adjust this later, this is just to fix runtimes and make it slightly consistent
	if (h_data.base_quality_score >= 1 && prob(30))
		if (h_data.base_quality_score >= 11)
			JOB_XP(h_data.user, "Botanist", 4)
		else if (h_data.base_quality_score >= 6)
			JOB_XP(h_data.user, "Botanist", 2)
		else
			JOB_XP(h_data.user, "Botanist", 1)

/// Handles stat bonuses and negatives associated with gene strains
/obj/machinery/plantpot/proc/HYPharvesting_gene_strains(datum/HYPharvesting_data/h_data)
	if(h_data.DNA.commuts)
		for(var/datum/plant_gene_strain/G in h_data.DNA.commuts)
			// And ones that mess with the quality of crops.
			// Unstable isn't here because it'd be less random outside the loop.
			if (istype(G, /datum/plant_gene_strain/quality))
				var/datum/plant_gene_strain/quality/Q = G
				if(Q.negative)
					h_data.base_quality_score -= Q.quality_mod
				else
					h_data.base_quality_score += Q.quality_mod
			// Gene strains that boost or penalize the cap.
			else if (istype(G, /datum/plant_gene_strain/yield))
				var/datum/plant_gene_strain/yield/Y = G
				if(Y.negative)
					if(h_data.harvest_cap == 0 || Y.yield_mult == 0)
						continue
					else
						h_data.harvest_cap /= Y.yield_mult
						h_data.harvest_cap -= Y.yield_mod
				else
					h_data.harvest_cap *= Y.yield_mult
					h_data.harvest_cap += Y.yield_mod

/// Handles mutation crop produce
/obj/machinery/plantpot/proc/HYPharvesting_mutated_crops(datum/HYPharvesting_data/h_data)
	// Figure out what crop we use - the base crop or a mutation crop.
	if(h_data.growing.crop || h_data.MUT?.crop)
		if(h_data.MUT)
			if(h_data.MUT.crop)
				h_data.getitem = h_data.MUT.crop
				h_data.dont_rename_crop = h_data.MUT.dont_rename_crop
			else
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Hydroponics:</b> Plant mutation [h_data.MUT] crop is not properly configured")
				h_data.getitem = h_data.growing.crop
		else
			h_data.getitem = h_data.growing.crop
			h_data.dont_rename_crop = h_data.growing.dont_rename_crop

/// Handles bonuses and negatives associated with plant health
/obj/machinery/plantpot/proc/HYPharvesting_health_bonuses(datum/HYPharvesting_data/h_data)
	if(h_data.pot.health >= h_data.growing.starthealth * 2 && prob(30))
		boutput(h_data.user, SPAN_NOTICE("This looks like a good harvest!"))
		h_data.base_quality_score += 5
		h_data.cropcount += 1
		h_data.harvest_cap += 1
		h_data.cropcount_consistency += 10
		// Good health levels bump the harvest amount up a bit and increase jumbo chances.
	if(h_data.pot.health >= h_data.growing.starthealth * 4 && prob(30))
		boutput(h_data.user, SPAN_NOTICE("It's a bumper crop!"))
		h_data.base_quality_score += 10
		h_data.cropcount += 2
		h_data.harvest_cap += 2
		h_data.cropcount_consistency += 20
		// This is if the plant health is absolutely excellent.
	if(h_data.pot.health <= h_data.growing.starthealth / 2 && prob(70))
		boutput(h_data.user, SPAN_ALERT("This is kind of a crappy harvest..."))
		h_data.base_quality_score -= 12
		h_data.cropcount *= 0.6
		h_data.harvest_cap -= h_data.cropcount
		h_data.cropcount_consistency -= 20
		// And this is if you've neglected the plant!

/// Handles the tracking of future harvests for the plant
/obj/machinery/plantpot/proc/HYPharvesting_remaining_harvests(datum/HYPharvesting_data/h_data)
	if(!HYPCheckCommut(h_data.DNA,/datum/plant_gene_strain/immortal))
		// Immortal is a gene strain that means infinite harvests as long as the plant
		// is kept alive, it's on melons usually.
		if(h_data.pot.health >= h_data.growing.starthealth * 4)
			// If we have excellent health, its a +20% chance for an extra harvest.
			h_data.extra_harvest_chance += 20
			h_data.extra_harvest_chance = clamp(h_data.extra_harvest_chance, 0, 100)
			if(prob(h_data.extra_harvest_chance))
				boutput(h_data.user, SPAN_NOTICE("The plant glistens with good health!"))
				// We got the bonus so don't reduce harvests.
			else
				// No bonus, harvest is decremented as usual.
				h_data.pot.harvests--
		else if(prob(33) && HYPCheckCommut(h_data.DNA, /datum/plant_gene_strain/variable_harvest))
			if(prob(10))
				h_data.pot.harvests++
			else if(prob(33))
				h_data.pot.harvests -= 2
			// else just don't reduce the harvests
		else
			h_data.pot.harvests--

	if(h_data.growing.isgrass || h_data.pot.harvests <= 0)
		// Vegetable-style plants always die after one harvest irregardless of harvests
		// remaining, though they do get bonuses for having a good harvests gene.
		h_data.pot.HYPkillplant()

/// Handles where the output of the harvest goes
/obj/machinery/plantpot/proc/HYPharvesting_produce_output(datum/HYPharvesting_data/h_data, obj/item/satchel/SA)
	if(SA)
		// If we're putting stuff in a satchel, this is where we do it.
		for(var/obj/item/I in h_data.pot.contents)
			if(length(SA.contents) >= SA.maxitems)
				boutput(h_data.user, SPAN_ALERT("Your satchel is full! You dump the rest on the floor."))
				break
			if(istype(I,/obj/item/seed/))
				continue
			else
				if(SA.check_valid_content(I))
					I.set_loc(SA)
					I.add_fingerprint(h_data.user)
		SA.UpdateIcon()
		SA.tooltip_rebuild = TRUE
	// if the satchel got filled up this will dump any unharvested items on the floor
	// if we're harvesting by hand it'll just default to this anyway! truly magical~
	for(var/obj/I in h_data.pot.contents)
		I.set_loc(h_data.user.loc)
		I.add_fingerprint(h_data.user)
	// we got to do the same for mobs
	for(var/mob/I in h_data.pot.contents)
		I.set_loc(h_data.user.loc)
		I.add_fingerprint(h_data.user)

/// Handles the generation of seed items
/obj/machinery/plantpot/proc/HYPharvesting_seeds(datum/HYPharvesting_data/h_data)
	if (h_data.seedcount > 0) HYPgenerateseedcopy(h_data.pot.plantgenes, h_data.growing, h_data.pot.generation,
													h_data.pot, h_data.seedcount)

/// Handles the finalisation of cropcount
/obj/machinery/plantpot/proc/HYPharvesting_finalise_cropcount(datum/HYPharvesting_data/h_data)
	var/cropsize = h_data.DNA?.get_effective_value("cropsize")
	h_data.cropcount *= (1 + ((cropsize * h_data.growing.yield_multi) / 100))
	// A higher output for plants with higher base output helps retains some personality.
	h_data.harvest_cap += h_data.growing.cropsize
	// Introduce some variance at the end.
	h_data.cropcount = src.harvest_consistency(h_data)
	// Max harvest amount for all plants is capped. If we've got higher output
	// than the cap it's probably through gene manipulation, so reward the player
	// with greater chances for an extra harvest if this is the case.
	// The cap is defined in hydro_controls and can be edited by coders on the fly.
	if(h_data.cropcount > h_data.harvest_cap)
		h_data.extra_harvest_chance += h_data.cropcount - h_data.harvest_cap
		h_data.cropcount = h_data.harvest_cap

	h_data.cropcount = round(max(h_data.cropcount, 0), 1)

/// Handles how consistency affects cropcount
/obj/machinery/plantpot/proc/harvest_consistency(datum/HYPharvesting_data/h_data)
	// Get a random number between the minimum possible variance and the uncapped cropcount, to use as the varianced cropcount.
	// This means variance always has a chance to reduce the cropcount by the maximum amount, but that increasing yield past the cap will also
	// always increase the chances of a bigger harvest.
	var/total_consistency = src.base_cropcount_consistency + h_data.cropcount_consistency
	if (total_consistency >= 100)
		return h_data.cropcount
	var/lower_bound = round(min(h_data.cropcount, h_data.harvest_cap) * (total_consistency / 100), 1)
	var/upper_bound = round(h_data.cropcount, 1)
	return rand(lower_bound, upper_bound)

/////////////////// end of HYPharvesting helper methods ///////////////////

/obj/machinery/plantpot/proc/HYPmutateplant(var/severity = 1)
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

/obj/machinery/plantpot/proc/HYPnewplant(var/obj/item/seed/SEED)
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
		src.health += src.plantgenes?.get_effective_value("harvests") * 2
		// If we have a single-harvest vegetable plant, the harvests gene (which is otherwise
		// useless) adds 2 health for every point. This works negatively also!

	if(growing.proximity_proc) // Activate proximity proc for any tray where a plant that uses it is planted
		src.AddComponent(/datum/component/proximity)

	src.health += SEED.planttype.endurance + SDNA?.get_effective_value("endurance")
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
	// now we transfer gene dominance + recessiveness as well
	DNA.d_species = SDNA.d_species
	DNA.d_growtime = SDNA.d_growtime
	DNA.d_harvtime = SDNA.d_harvtime
	DNA.d_cropsize = SDNA.d_cropsize
	DNA.d_harvests = SDNA.d_harvests
	DNA.d_potency = SDNA.d_potency
	DNA.d_endurance = SDNA.d_endurance
	// we use the same list as the seed here, as new lists are created only on mutation to avoid making way more lists than we need
	DNA.commuts = SDNA.commuts
	if(SDNA.mutation)
		DNA.mutation = HY_get_mutation_from_path(SDNA.mutation.type)
	// Copy over all genes, strains and mutations from the seed.

	// Finally set the harvests, make sure we always have at least one harvest,
	// mutate the genes a little and update the pot sprite.
	if(growing.harvestable) src.harvests = growing.harvests + DNA?.get_effective_value("harvests")
	if(src.harvests < 1) src.harvests = 1
	if (!SEED.dont_mutate)
		src.HYPmutateplant(1)
	src.post_alert(list("event" = "new", "plant" = src.current.name))
	src.recently_harvested = 0
	src.UpdateIcon()
	src.update_name()
	src.growth_rate = 2
	// with the new plant created, we give it a plantgrowth_tick, if it is not a simple crystal
	if (!growing.simplegrowth)
		src.current_tick = new /datum/plantgrowth_tick(src)
	// at the end, we update the water overlay of the plant, because some plants consider different chems as water substitutent (like blood on maneating plants)
	src.update_water_level()

/obj/machinery/plantpot/proc/HYPkillplant()
	// Simple proc to kill the plant without clearing the plantpot out altogether.
	src.health = 0
	src.harvests = 0
	src.dead = 1
	src.recently_harvested = 0
	src.grow_level = 0
	post_alert(list("event" = "death", "plant" = src.current.name))
	src.health_warning = 0
	src.harvest_warning = 0
	src.UpdateIcon()
	src.RemoveComponentsOfType(/datum/component/proximity) // If there's no plant here, there doesn't need to be a check
	src.update_name()
	//we also get rid of the current plantgrowth_tick, since there is no plant to access it
	qdel(src.current_tick)
	src.current_tick = null

/obj/machinery/plantpot/proc/HYPdestroyplant()
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
	src.plantgenes.mutation?.HYPdestroyplant_proc_M(src)
	src.plantgenes = new(random_alleles = FALSE)

	src.generation = 0
	src.UpdateIcon()
	src.RemoveComponentsOfType(/datum/component/proximity)
	src.update_name()
	src.post_alert(list("event" = "cleared"))
	//we also get rid of the current plantgrowth_tick, since there is no plant to access it
	qdel(src.current_tick)
	src.current_tick = null

/obj/machinery/plantpot/proc/HYPdamageplant(var/damage_source, var/damage_amount, var/bypass_resistance = 0)
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

		damage_prob -= growing.endurance + DNA?.get_effective_value("endurance")
		if(damage_prob < 1) return 0
		if(damage_prob > 100) damage_prob = 100

	if(growing.endurance + DNA?.get_effective_value("endurance") < 0) damage_amount -= growing.endurance + DNA?.get_effective_value("endurance")
	if(prob(damage_prob))
		src.health -= damage_amount
		return 1
	else return 0

/obj/machinery/plantpot/proc/HYPplant_matured()
	src.plantgenes?.mutation?.HYPmatured_proc_M(src)


// ---------
// --------Plantpot Subtypes---------
// ---------


/obj/machinery/plantpot/hightech
	name = "high-tech hydroponics tray"
	desc = "A mostly debug-only plant tray that is capable of revealing more information about your plants."
	more_info = TRUE

	New()
		..()

/obj/machinery/plantpot/hightech/proc/update_maptext()
	if (!src.current)
		src.maptext = "<span class='pixel ol c vb'></span>"
		return
	maptext_width = 96
	maptext_y = 32
	maptext_x = -32
	var/datum/plant/growing = src.current
	var/datum/plantgenes/DNA = src.plantgenes
	var/growth_pct = round(src.growth / growing.HYPget_growth_to_harvestable(DNA) * 100)
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

/obj/machinery/plantpot/hightech/get_desc()
	if(!src.current)
		return

	var/datum/plant/growing = src.current
	var/datum/plantgenes/DNA = src.plantgenes
	var/growthlimit = growing.HYPget_growth_to_harvestable(DNA)
	return "Generation [src.generation] - Health: [src.health] / [growing.starthealth] - Growth: [src.growth] / [growthlimit] - Harvests: [src.harvests] left."

/obj/machinery/plantpot/hightech/process()
	..()
	update_maptext()

/obj/machinery/plantpot/kudzu
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife... Made of plants."
	icon_state = "kudzutray"
	power_usage = 0

/obj/machinery/plantpot/kudzu/attackby(var/obj/item/W, var/mob/user)
	//Can only attempt to destroy the plant pot if the plant in it is dead or empty.
	if(!src.current || src.dead)
		if (destroys_kudzu_object(src, W, user))
			if (prob(40))
				user.visible_message(SPAN_ALERT("[user] savagely attacks [src] with [W]!"))
			else
				user.visible_message(SPAN_ALERT("[user] savagely attacks [src] with [W], destroying it!"))
				qdel(src)
				return
		else
			return ..()
	..()

TYPEINFO(/obj/machinery/plantpot/bareplant)
	mats = 0

/obj/machinery/plantpot/bareplant
	name = "arable soil"
	desc = "A small mound of arable soil for planting and plant based activities."
	anchored = ANCHORED
	deconstruct_flags = DECON_NONE
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

/obj/machinery/plantpot/bareplant/New(newLoc, obj/item/seed/initial_seed)
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

			S.generic_seed_setup(P, FALSE)
			src.HYPnewplant(S)

			for(var/commutes in spawn_commuts)
				HYPaddCommut(src.plantgenes, commutes)

			if(spawn_growth)
				src.grow_level = spawn_growth
			else
				src.grow_level = pick(HYP_GROWTH_MATURED,HYP_GROWTH_HARVESTABLE,HYP_GROWTH_HARVESTABLE)
			switch(grow_level)
				if(HYP_GROWTH_GROWING)
					src.growth = src.current.HYPget_growth_to_growing(src.plantgenes)
				if(HYP_GROWTH_MATURED)
					src.growth = src.current.HYPget_growth_to_matured(src.plantgenes)
				if(HYP_GROWTH_HARVESTABLE)
					src.growth = src.current.HYPget_growth_to_harvestable(src.plantgenes)
			UpdateIcon()
		else
			if(!src.current)
				qdel(src)

/obj/machinery/plantpot/bareplant/attackby(obj/item/W, mob/user)
	// Filter out the following item interactions
	if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
		boutput(user, SPAN_ALERT("[W] does not seem like the right tool for the job."))
	else if(istype(W, /obj/item/seed/) || istype(W, /obj/item/seedplanter/))
		boutput(user, SPAN_ALERT("Something is already growing there."))
	else
		..()

/obj/machinery/plantpot/bareplant/attack_hand(var/mob/user)

	if(isAI(user) || isobserver(user)) return // naughty AIs used to be able to harvest plants
	src.add_fingerprint(user)
	if(src.current)
		if(src.dead)
			boutput(user, SPAN_NOTICE("You clear the dead plant."))
			HYPdestroyplant()
			return

		if(HYPcheck_if_harvestable())
			HYPharvesting(user,null)


/obj/machinery/plantpot/bareplant/HYPdestroyplant()
	..()
	qdel(src)

/obj/machinery/plantpot/bareplant/update_water_icon()
	return

/obj/machinery/plantpot/bareplant/process()
	..()
	if(auto_water)
		if(src.reagents && !src.reagents.has_reagent("water", 50))
			src.reagents.add_reagent("water", 200)

/obj/machinery/plantpot/bareplant/flower

/obj/machinery/plantpot/bareplant/flower/New()
	spawn_plant = pick(/datum/plant/flower/rose, /datum/plant/flower/gardenia, /datum/plant/flower/hydrangea)
	..()

/obj/machinery/plantpot/bareplant/crop

/obj/machinery/plantpot/bareplant/crop/New()
	spawn_plant = pick(/datum/plant/crop/cotton, /datum/plant/crop/oat, /datum/plant/crop/peanut, /datum/plant/veg/soy)
	..()

/obj/machinery/plantpot/bareplant/tree

/obj/machinery/plantpot/bareplant/tree/New()
	spawn_plant = pick(/datum/plant/crop/tree, /datum/plant/fruit/cherry, /datum/plant/fruit/apple, /datum/plant/fruit/peach)
	..()

/obj/machinery/plantpot/bareplant/weed

/obj/machinery/plantpot/bareplant/weed/New()
	spawn_plant = pick(/datum/plant/artifact/creeper, /datum/plant/weed/lasher, /datum/plant/weed/slurrypod, /datum/plant/artifact/pukeplant)
	..()

/// Holds harvest-specific variables during HYPharvesting() execution.
/datum/HYPharvesting_data
	// The mob that initiated the harvest
	var/mob/living/user
	/// The plantpot associated with this harvest
	var/obj/machinery/plantpot/pot
	/// The plant associated with this harvest
	var/datum/plant/growing
	/// The plantgenes of the plant associated with this harvest
	var/datum/plantgenes/DNA
	/// The plant mutation of the plant associated with this harvest
	var/datum/plantmutation/MUT
	/// The item or list of items that the plant can produce
	var/getitem
	/// Whether or not the produce should be renamed
	var/dont_rename_crop
	/// The number of items this harvest produces
	var/cropcount = 0
	// Addition to the lower bounds of the cropcount variance. A value of 1 reduces the max possible loss by 1%, negative values do the opposite.
	var/cropcount_consistency = 0
	/// The maximum number of items that this harvest produces
	var/harvest_cap = 10
	/// The number of seeds this harvest produced
	var/seedcount = 0
	/// The base quality score of all produce from the plant
	var/base_quality_score
	/// The chance that a multi-harvest plant won't reduce in harvest-count
	var/extra_harvest_chance = 0
