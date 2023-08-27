/obj/item/plant/tumbling_creeper
	name = "tumbling creeper"
	crop_prefix = "tumbling "
	desc = "A tumbler made of creeper. A highly invasive plant known for destroying many ecological systems. If planted onto the ground with a garden trowel, it serves as a prickly trap."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "Tumbling_Creeper-Unplanted"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "tumbling_creeper"
	flags = TABLEPASS | FPRINT | NOSPLASH
	w_class = W_CLASS_NORMAL
	force = 3
	throwforce = 0
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	var/datum/plant/planttype = /datum/plant/artifact/creeper
	var/datum/plantgenes/plantgenes = null
	var/generation = 0 // For genetics tracking.
	var/armed = FALSE //! This determinates if the trap is armed or not
	var/armed_force = 8 //! how much damage the trap does when stepped upon. Will be set when harvested
	var/crashed_force = 20 //! how much damage the trap does when crashed into. Will be set when harvested
	var/reagent_storage = 5 //! How much the max amount of chems is the trap should be able to hold
	var/target_zone = "chest" //! which zone the trap tries to target and calculate the damage resist from


/obj/item/plant/tumbling_creeper/New()

	..()
	processing_items |= src

	if(ispath(src.planttype))
		var/datum/plant/species = HY_get_species_from_path(src.planttype, src)
		if (species)
			src.planttype = species

	src.plantgenes = new /datum/plantgenes(src)

	src.reagents.maximum_volume = src.reagent_storage

/obj/item/plant/tumbling_creeper/HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)

	var/endurance_for_max = 150 // how much endurance is needed to reach max damage with the trap
	var/potency_for_max = 250 // how much potency is needed to generate the max injection-multiplier
	var/armed_force_min = 8 // how much damage the trap does when stepped upon with 0 endurance
	var/armed_force_max = 18 // how much damage the trap does when stepped upon with the maximum endurance
	var/crashed_force_min = 16 // how much damage the trap does when stepped upon with 0 endurance
	var/crashed_force_max = 30 // how much damage the trap does when stepped upon with the maximum endurance
	var/reagent_storage_min = 5 // How much the max amount of chems is the trap should be able to hold	at 0 potency
	var/reagent_storage_max = 40 // How much the max amount of chems is the trap should be able to hold	at max potency
	var/reagent_generation_multiplier = 1 //! How much percentage of the volume should be filled with assoc_reagents when harvested

	var/datum/plantgenes/creeper_genes = src.plantgenes
	src.planttype = HYPgenerateplanttypecopy(src, origin_plant)
	src.generation = src.generation
	HYPpassplantgenes(passed_genes,creeper_genes)

	// raise the reagent storage limit linear from 0 potency to max potency
	src.reagent_storage = clamp(
		round(reagent_storage_min + (creeper_genes?.get_effective_value("potency") / potency_for_max) * (reagent_storage_max - reagent_storage_min)),
		reagent_storage_min,
		reagent_storage_max)

	src.reagents.maximum_volume = src.reagent_storage

	//add chemicals until reagent_generation_multiplier percentage of the storage is filled
	if (src.planttype)
		//we build a list out of all chems in assoc_reagents and commuts
		var/list/put_reagents = list()
		put_reagents = src.planttype.assoc_reagents
		//theoretically the tumbling creeper got no assoc_reagents, but for the case that will change at some point
		if(creeper_genes.mutation)
			put_reagents = put_reagents | creeper_genes.mutation.assoc_reagents
		if(creeper_genes.commuts)
			for (var/datum/plant_gene_strain/reagent_adder/R in creeper_genes.commuts)
				put_reagents |= R.reagents_to_add
		// Now we add each reagent into the tumbling creeper
		if (length(put_reagents) > 0)
			var/volume_to_fill = src.reagent_storage * reagent_generation_multiplier
			var/to_add = volume_to_fill / length(put_reagents)
			for (var/plant_reagent in put_reagents)
				src.reagents.add_reagent(plant_reagent, to_add)

	// raise the damage of the plant linear from 0 endurance to max endurance
	src.crashed_force = clamp(
		round(crashed_force_min + (creeper_genes?.get_effective_value("endurance") / endurance_for_max) * (crashed_force_max - crashed_force_min)),
		crashed_force_min,
		crashed_force_max)

	src.armed_force = clamp(
		round(armed_force_min + (creeper_genes?.get_effective_value("endurance") / endurance_for_max) * (armed_force_max - armed_force_min)),
		armed_force_min,
		armed_force_max)

	return src

/obj/item/plant/tumbling_creeper/disposing()

	processing_items -= src
	src.plantgenes = null
	..()

/obj/item/plant/tumbling_creeper/examine()

	. = ..()
	if (src.armed)
		. += "<span class='alert'>It looks like it's planted into the ground.</span>"

/obj/item/plant/tumbling_creeper/get_help_message(dist, mob/user)

	if (src.armed)
		return "You can use <b>wirecutters</b> to uproot the creeper from the ground, disarming it."
	else
		return "You can use a <b>garden trowel</b> to plant it into the ground, arming it."

/obj/item/plant/tumbling_creeper/process()

	var/tumbling_cooldown = 15 SECONDS // how long the item should take at minimum before it begins tumbling again
	var/tumbling_distance_max = 6 // how many tiles the item tries to move at most when tumbling
	var/tumbling_distance_min = 3 // how many tiles the item tries to move at least when tumbling
	var/tumbling_speed = 0.3 // how fast the throw while tumbling should be
	var/tumbling_flip_duration = 1.25 SECONDS // how long a flip of the tumbler should take
	var/tumbling_chance = 20 // the chance in % the item tries to thumble on each process tick
	var/plantpot_damage_chance = 20 // the chance for an armed tumbler to damage a plant in percent
	var/plantpot_damage_amount = 6 // the amount of damage the armed tumbler should deal to the plant

	. = ..()
	// This handles the creepers invasive behaviour.
	// When unarmed, it can randomly move. When armed, it starts attacking and planting creeper seeds into the trays
	if (!src.armed)
		//Let's see if our fellow creeper moves on their own
		//this checks if the item is on the ground and on simulated ground
		if (prob(tumbling_chance) && istype(src.loc, /turf) && issimulatedturf(get_turf(src)))
			if (!ON_COOLDOWN(src, "tumbling_fun", tumbling_cooldown))
				//the thumbler tries to randomly pick a cardinal direction and throws itself towards it
				//It takes a random direction on purpose. Tumbling weeds likes to get stuck
				var/target_direction = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
				var/target_distance = rand(tumbling_distance_min, tumbling_distance_max)
				var/turf/target_turf = get_ranged_target_turf(get_turf(src), target_direction, target_distance * 32)
				animate_spin(src, pick( "R" , "L"), tumbling_flip_duration, 2)
				src.throw_at(target_turf, target_distance, tumbling_speed)
	else
		if (prob(plantpot_damage_chance))
		//we look at plantpots around is if the creep is able to spread
			for (var/obj/machinery/plantpot/other_plantpot in range(1,src))
				var/datum/plant/growing = other_plantpot.current
				if (!other_plantpot.dead && other_plantpot.current && !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/artifact/creeper))
					other_plantpot.HYPdamageplant("physical", plantpot_damage_amount,1)
				else if (other_plantpot.dead)
					other_plantpot.HYPdestroyplant()
				else if (!other_plantpot.current && src.plantgenes && !HYPCheckCommut(src.plantgenes, /datum/plant_gene_strain/seedless))
					//we create a new seed now
					var/obj/item/seed/temporary_seed = HYPgenerateseedcopy(src.plantgenes, src.planttype, src.generation)
					//we now devolve the seed to not make tumbler spread like wildfire
					var/datum/plantgenes/New_DNA = temporary_seed.plantgenes
					New_DNA.mutation = null
					// now we are able to plant the seed
					other_plantpot.HYPnewplant(temporary_seed)
					spawn(0.5 SECONDS)
						qdel(temporary_seed)

/obj/item/plant/tumbling_creeper/HY_set_species(var/datum/plant/species)

	if (species)
		src.planttype = species
	else
		if (ispath(src.planttype))
			src.planttype = new src.planttype(src)
		else
			qdel(src)
			return


/obj/item/plant/tumbling_creeper/attackby(obj/item/used_item, mob/user)

	var/disarming_time = 3 SECONDS // how long disarming with a wirecutter should take
	var/arming_time = 2 SECONDS // how long arming should take

	if(istype(used_item,/obj/item/gardentrowel) && !src.armed)
		if (ON_COOLDOWN(user, "arming_tumbling_creeper", user.combat_click_delay))
			return
		for(var/obj/item/iterated_item in get_turf(src))
			if (istype(iterated_item, /obj/item/plant/tumbling_creeper))
				var/obj/item/plant/tumbling_creeper/other_creeper = iterated_item
				if (other_creeper.armed)
					boutput(user, "<span class='alert'>A creeper is already planted here!</span>")
					return
		user.show_text("You start to plant the creeper onto the ground...", "blue")
		var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
			user,
			src,
			arming_time,
			/obj/item/plant/tumbling_creeper/proc/arm,
			\list(user),
			src.icon,
			src.icon_state,
			"[user] finishes planting [src]")
		actions.start(action_bar, user)
		return
	if(issnippingtool(used_item))
		if (src.armed)
			if (ON_COOLDOWN(user, "disarming_tumbling_creeper", user.combat_click_delay))
				return
			playsound(src.loc, 'sound/items/Scissor.ogg', 60)
			user.visible_message("[user] starts to cut the roots of [src]...")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
				user,
				src,
				disarming_time,
				/obj/item/plant/tumbling_creeper/proc/disarm,\list(user),
				used_item.icon,
				used_item.icon_state,
				"[user] finishes cutting out [src]")
			actions.start(action_bar, user)
			return
	..()

/obj/item/plant/tumbling_creeper/ex_act(severity)

	//no reuseable explosive chem traps, sorry
	qdel(src)

/obj/item/plant/tumbling_creeper/proc/arm(mob/user)

	if (!src)
		return
	for(var/obj/item/iterated_item in get_turf(src))
		if (istype(iterated_item, /obj/item/plant/tumbling_creeper))
			var/obj/item/plant/tumbling_creeper/other_creeper = iterated_item
			if (other_creeper.armed)
				boutput(user, "<span class='alert'>A creeper is already planted here!</span>")
				return
	if (!src.armed)
		logTheThing(LOG_COMBAT, user, "planted [src] at [src.loc]")
		set_icon_state("Tumbling_Creeper-Planted")
		if (istype(src.loc, /mob))
			var/mob/owning_mob = src.loc
			owning_mob.drop_item(src)
		else
			src.set_loc(get_turf(src))
		src.armed = TRUE
		src.anchored = TRUE

/obj/item/plant/tumbling_creeper/proc/disarm(mob/user)

	if (!src)
		return
	if (src.armed)
		set_icon_state("Tumbling_Creeper-Unplanted")
		logTheThing(LOG_COMBAT, user, "uprooted [src] at [src.loc]")
		src.armed = FALSE
		src.anchored = FALSE


/obj/item/plant/tumbling_creeper/throw_impact(atom/hit_atom, datum/thrown_thing/thr)

	var/self_assemly_chance = 50 // the chance in percent for the trap to auto-arm when it gets flung against a plantpot

	//now the tumbler reaches its destination
	if (istype(hit_atom, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/hit_plantpot = hit_atom
		var/datum/plant/growing = hit_plantpot.current
		if (!hit_plantpot.current || !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/artifact/creeper))
			if (prob(self_assemly_chance))
				src.arm()


/obj/item/plant/tumbling_creeper/hitby(atom/movable/targeted_atom, datum/thrown_thing/thr)

	..()
	if (src.armed && ishuman(targeted_atom) && targeted_atom.throwing)
		var/mob/living/carbon/human/victim = targeted_atom
		//crashes into the creeper when being thrown/slipped at it
		victim.visible_message("<span class='alert'><B>[victim] crashes into the planted [src]!</B></span>",\
		"<span class='alert'><B>You crash into the planted [src]!</B></span>")
		crash_into(victim)
		qdel(src) //if crashed into, destroys the creeper

/obj/item/plant/tumbling_creeper/Crossed(atom/movable/targeted_mob as mob|obj)

	..()
	if (src.armed && ishuman(targeted_mob))
		var/mob/living/carbon/human/victim = targeted_mob
		//crawling or just walking between the sticks is a viable counter
		//getting thrown at the trap has a different effect we want to check seperately
		if(victim.lying || victim.throwing || !victim.running_check(walking_matters = 1, ignore_actual_delay = 1))
			return
		//If any checks failed, well, you step into the trap
		victim.visible_message("<span class='alert'><B>[victim] steps into the planted [src]!</B></span>",\
		"<span class='alert'><B>You step into the planted [src]!</B></span>")
		step_on(victim)

/obj/item/plant/tumbling_creeper/proc/crash_into(mob/living/carbon/human/victim as mob)

	var/crash_transfer_multiplier = 0.4 //! Multiplier to damage to calculate the amount of chems tranferred when crashed into.
	var/crashed_weakened = 3 SECONDS //! how long you are stunned if you crash into the trap

	if (!src || !victim || !src.armed)
		return
	logTheThing(LOG_COMBAT, victim, "crashed into [src] at [log_loc(src)].")
	victim.changeStatus("weakened", crashed_weakened)
	victim.force_laydown_standup()
	src.trap_damage(victim, src.crashed_force, crash_transfer_multiplier)
	playsound(victim.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 80, 1)
	victim.UpdateDamageIcon()


/obj/item/plant/tumbling_creeper/proc/step_on(mob/living/carbon/human/victim as mob)

	var/armed_weakened = 2 SECONDS // how long you are weakened after stepping into the trap
	var/stepon_transfer_multiplier = 0.5 // Multiplier to damage to calculate the amount of chems tranferred when stepped into.

	if (!src || !victim || !src.armed)
		return
	logTheThing(LOG_COMBAT, victim, "stepped into [src] at [log_loc(src)].")
	victim.changeStatus("weakened", armed_weakened)
	victim.force_laydown_standup()
	src.trap_damage(victim, src.armed_force, stepon_transfer_multiplier)
	playsound(victim.loc, 'sound/impact_sounds/Flesh_stab_1.ogg', 80, 1)
	if (src.material)
		src.material.triggerOnAttack(src, null, victim)
	victim.UpdateDamageIcon()

/obj/item/plant/tumbling_creeper/proc/trap_damage(mob/living/carbon/human/victim as mob, damage, transfer_multiplier)

	if (!src || !victim)
		return
	var/target = "All"
	if (victim.organHolder[src.target_zone])
		target = src.target_zone
	// we need this to calculate how much chems get transfered
	// This means damage against the zone, reduced by melee protection, multiplied by transfer multiplier and then rounded
	var/injected_amount = max(0, round((damage - victim.get_melee_protection(target, DAMAGE_STAB))*transfer_multiplier))
	victim.TakeDamageAccountArmor(target, damage, 0, 0, DAMAGE_STAB)
	// If injected_amount is greater than 0 and there are reagents in the trap, inject the victim
	if (src.reagents && src.reagents.total_volume && injected_amount > 0)
		logTheThing(LOG_COMBAT, src, "injected [victim] at [log_loc(src)] with [min(injected_amount, src.reagents.total_volume)]u of reagents.")
		src.reagents.trans_to(victim, injected_amount)
